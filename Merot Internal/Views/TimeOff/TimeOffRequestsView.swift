import SwiftUI

struct TimeOffRequestsView: View {
    @StateObject private var vm = TimeOffViewModel()
    @State private var confirmAction: (id: Int, action: String)?

    var body: some View {
        VStack(spacing: 0) {
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
                if let msg = vm.successMessage {
                    SuccessBanner(message: msg)
                }
                if let error = vm.error {
                    ErrorBanner(message: error)
                }

                if vm.requests.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "calendar.badge.clock", title: "No time off requests", subtitle: vm.statusFilter == "pending" ? "All caught up!" : nil)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.requests) { request in
                            requestRow(request)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Time Off Requests")
        .brandNavBar()
        .refreshable { await vm.load() }
        .alert("Confirm Action", isPresented: Binding(
            get: { confirmAction != nil },
            set: { if !$0 { confirmAction = nil } }
        )) {
            Button("Cancel", role: .cancel) { confirmAction = nil }
            Button(confirmAction?.action == "approve" ? "Approve" : "Deny",
                   role: confirmAction?.action == "deny" ? .destructive : nil) {
                if let ca = confirmAction {
                    Task {
                        if ca.action == "approve" { await vm.approve(id: ca.id) }
                        else { await vm.deny(id: ca.id) }
                    }
                }
                confirmAction = nil
            }
        } message: {
            Text("Are you sure you want to \(confirmAction?.action ?? "") this request?")
        }
        .task { await vm.load() }
    }

    private func requestRow(_ r: TimeOffRequest) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(r.employee?.full_name ?? "Unknown")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                    if let type = r.time_off_record?.leave_type ?? r.time_off_record?.name {
                        Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    HStack(spacing: 4) {
                        Text(formatDateShort(r.start_date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.3))
                        Text(formatDateShort(r.end_date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if let days = r.days {
                        Text("\(days)d")
                            .font(.system(.body, design: .monospaced)).bold()
                            .foregroundColor(.accent)
                    }
                    StatusBadge(status: r.approval_status ?? "pending")
                }
            }
            .padding(12)

            // Actions for pending
            if r.approval_status == "pending" {
                Divider().background(Color.white.opacity(0.08))
                HStack(spacing: 0) {
                    Button {
                        confirmAction = (id: r.id, action: "approve")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle").font(.caption2)
                            Text("Approve").font(.caption).fontWeight(.medium)
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }

                    Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 24)

                    Button {
                        confirmAction = (id: r.id, action: "deny")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle").font(.caption2)
                            Text("Deny").font(.caption).fontWeight(.medium)
                        }
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
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
