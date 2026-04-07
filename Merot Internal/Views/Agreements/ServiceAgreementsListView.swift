import SwiftUI

struct ServiceAgreementsListView: View {
    @StateObject private var vm = ServiceAgreementsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                TextField("Search agreements...", text: $vm.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await vm.load() } }
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

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
                if vm.agreements.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "handshake", title: "No service agreements")
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.agreements) { a in
                            agreementRow(a)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Service Agreements")
        .brandNavBar()
        .refreshable { await vm.load() }
        .task { await vm.load() }
    }

    private func agreementRow(_ a: ServiceAgreement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(a.employer_name ?? "Unknown")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Spacer()
                StatusBadge(status: a.signature_status ?? "draft")
            }
            HStack {
                if let date = a.effective_date {
                    Text("From \(formatDate(date))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
                if let months = a.term_months {
                    Text("- \(months) months")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                StatusBadge(status: a.status ?? "unknown")
            }
            HStack {
                if let fee = a.base_fee_per_employee, fee > 0 {
                    Text("Fee: \(formatMoney(fee))/employee")
                        .font(.caption)
                        .foregroundColor(.accent.opacity(0.7))
                }
                Spacer()
                if let addendums = a.addendums_count, addendums > 0 {
                    Text("\(addendums) addendums")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
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
