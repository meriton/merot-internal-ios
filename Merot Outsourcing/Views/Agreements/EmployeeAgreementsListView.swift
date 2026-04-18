import SwiftUI

struct EmployeeAgreementsListView: View {
    @StateObject private var vm = EmployeeAgreementsViewModel()

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
                    EmptyStateView(icon: "doc.text", title: "No employee agreements")
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.agreements) { a in
                            NavigationLink(destination: EmployeeAgreementDetailView(agreementId: a.id)) {
                                agreementRow(a)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Employee Agreements")
        .brandNavBar()
        .refreshable { await vm.load() }
        .task { await vm.load() }
    }

    private func agreementRow(_ a: EmployeeAgreement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(a.employee_name ?? "Unknown")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Spacer()
                StatusBadge(status: a.signature_status ?? "draft")
            }
            HStack(spacing: 12) {
                if let type = a.contract_type_display ?? a.contract_type {
                    Label(type, systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                if let country = a.country_display ?? a.country {
                    Label(country, systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            HStack {
                if let date = a.effective_date {
                    Text("From \(formatDate(date))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
                if let months = a.term_months {
                    Text("- \(months) months")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                StatusBadge(status: a.status ?? "unknown")
            }
            if let comp = a.net_compensation, comp > 0 {
                Text("\(formatMoney(comp)) \(a.currency ?? "")")
                    .font(.caption)
                    .foregroundColor(.accent.opacity(0.7))
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
