import SwiftUI

struct EmployeesListView: View {
    @StateObject private var vm = EmployeesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                    TextField("Search employees...", text: $vm.searchText)
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit { Task { await vm.search() } }
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip("All", isSelected: vm.statusFilter == nil) { vm.statusFilter = nil; Task { await vm.load() } }
                        filterChip("Active", isSelected: vm.statusFilter == "active") { vm.statusFilter = "active"; Task { await vm.load() } }
                        filterChip("Terminated", isSelected: vm.statusFilter == "terminated") { vm.statusFilter = "terminated"; Task { await vm.load() } }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                ScrollView {
                    if let error = vm.error {
                        ErrorBanner(message: error)
                    }

                    if vm.employees.isEmpty && !vm.isLoading {
                        EmptyStateView(icon: "person.3", title: "No employees found")
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(vm.employees) { employee in
                                NavigationLink(destination: EmployeeDetailView(employeeId: employee.id)) {
                                    employeeRow(employee)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Employees")
            .brandNavBar()
            .refreshable { await vm.load() }
        }
        .task { await vm.load() }
    }

    private func employeeRow(_ e: Employee) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(e.initials)
                        .font(.caption).bold()
                        .foregroundColor(.accent)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(e.displayName)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    if let title = e.title {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    if let employer = e.employer?.name {
                        Text("- \(employer)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                if let dept = e.department_name ?? e.department {
                    Text(dept)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: e.status ?? "unknown")
                if let salary = e.salary_detail {
                    Text(formatMoney(salary.gross_salary, currency: salary.currency))
                        .font(.caption2)
                        .foregroundColor(.accent.opacity(0.7))
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
