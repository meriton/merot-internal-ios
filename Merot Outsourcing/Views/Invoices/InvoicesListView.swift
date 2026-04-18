import SwiftUI

struct InvoicesListView: View {
    @StateObject private var vm = InvoicesViewModel()
    @State private var showCreateForm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                    TextField("Search invoices...", text: $vm.searchText)
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .onSubmit { Task { await vm.load() } }
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.statusOptions, id: \.self) { status in
                            filterChip(status.capitalized, isSelected: vm.statusFilter == status) {
                                vm.statusFilter = status
                                Task { await vm.load() }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                ScrollView {
                    if let error = vm.error {
                        ErrorBanner(message: error)
                    }

                    // Stats summary
                    if let stats = vm.stats {
                        statsRow(stats).padding(.horizontal)
                    }

                    if vm.invoices.isEmpty && !vm.isLoading {
                        EmptyStateView(icon: "doc.text", title: "No invoices found")
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(vm.invoices) { invoice in
                                NavigationLink(destination: InvoiceDetailView(invoiceId: invoice.id)) {
                                    invoiceRow(invoice)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Invoices")
            .brandNavBar()
            .refreshable { await vm.load() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showCreateForm = true } label: {
                        Image(systemName: "plus").foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showCreateForm) {
                InvoiceFormView { Task { await vm.load() } }
            }
        }
        .task { await vm.load() }
    }

    private func statsRow(_ stats: InvoiceStats) -> some View {
        HStack(spacing: 10) {
            miniStat("Draft", formatMoney(stats.total_draft), .yellow)
            miniStat("Outstanding", formatMoney(stats.total_outstanding), .orange)
            miniStat("Paid", formatMoney(stats.total_paid), .green)
        }
        .padding(.bottom, 4)
    }

    private func miniStat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.caption, design: .monospaced)).bold()
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white.opacity(0.06))
        .cornerRadius(8)
    }

    private func invoiceRow(_ inv: Invoice) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(inv.invoice_number ?? "#\(inv.id)")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Text(inv.employer_name ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(formatDate(inv.issue_date))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatMoney(inv.total_amount, currency: inv.currency))
                    .font(.subheadline).bold()
                    .foregroundColor(.accent)
                StatusBadge(status: inv.overdue == true ? "overdue" : (inv.status ?? "unknown"))
                if let days = inv.days_overdue, days > 0 {
                    Text("\(days)d overdue")
                        .font(.system(size: 9))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .brand : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accent : Color.white.opacity(0.08))
                .cornerRadius(16)
        }
    }
}
