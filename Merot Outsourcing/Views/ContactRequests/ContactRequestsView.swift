import SwiftUI

struct ContactRequestsView: View {
    @StateObject private var vm = ContactRequestsViewModel()
    @State private var selectedRequest: ContactRequest?
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                TextField("Search contacts...", text: $vm.searchText)
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

            // Stats
            if let stats = vm.stats {
                HStack(spacing: 8) {
                    miniStat("Pending", "\(stats.pending ?? 0)", .yellow)
                    miniStat("Replied", "\(stats.replied ?? 0)", .blue)
                    miniStat("Done", "\(stats.completed ?? 0)", .green)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }

            ScrollView {
                if let msg = vm.successMessage {
                    SuccessBanner(message: msg)
                }
                if let error = vm.error {
                    ErrorBanner(message: error)
                }

                if vm.requests.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "envelope", title: "No contact requests")
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.requests) { request in
                            Button {
                                selectedRequest = request
                                showDetail = true
                            } label: {
                                requestRow(request)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Contact Requests")
        .brandNavBar()
        .refreshable { await vm.load() }
        .sheet(isPresented: $showDetail) {
            if let req = selectedRequest {
                contactDetailSheet(req)
            }
        }
        .task { await vm.load() }
    }

    private func requestRow(_ r: ContactRequest) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(r.name ?? "Unknown")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Spacer()
                StatusBadge(status: r.status ?? "pending")
            }
            if let company = r.company_name, !company.isEmpty {
                Text(company)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            Text(r.message ?? "")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .lineLimit(2)
            Text(formatDate(r.created_at))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func contactDetailSheet(_ req: ContactRequest) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            InfoRow(icon: "person.fill", label: "Name", value: req.name ?? "-")
                            InfoRow(icon: "envelope.fill", label: "Email", value: req.email ?? "-")
                            if let company = req.company_name, !company.isEmpty {
                                InfoRow(icon: "building.2.fill", label: "Company", value: company)
                            }
                            InfoRow(icon: "calendar", label: "Date", value: formatDate(req.created_at))
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Message").font(.headline).foregroundColor(.white.opacity(0.7))
                            Text(req.message ?? "No message")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    // Status actions
                    if req.status != "completed" {
                        CardView {
                            VStack(spacing: 10) {
                                Text("Update Status").font(.headline).foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity, alignment: .leading)

                                if req.status == "pending" {
                                    statusButton("Mark as Replied", status: "replied", color: .blue, id: req.id)
                                }
                                if req.status == "pending" || req.status == "replied" {
                                    statusButton("Mark as Completed", status: "completed", color: .green, id: req.id)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Contact Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showDetail = false }.foregroundColor(.white)
                }
            }
        }
    }

    private func statusButton(_ label: String, status: String, color: Color, id: Int) -> some View {
        Button {
            Task {
                await vm.updateStatus(id: id, status: status)
                showDetail = false
            }
        } label: {
            Text(label)
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color.opacity(0.8))
                .cornerRadius(10)
        }
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
