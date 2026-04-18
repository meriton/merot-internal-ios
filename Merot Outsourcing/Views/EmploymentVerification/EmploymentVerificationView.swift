import SwiftUI

struct EmploymentVerificationView: View {
    @StateObject private var vm = EmploymentVerificationViewModel()
    @State private var confirmAction: (id: Int, action: String)?
    @State private var rejectId: Int?
    @State private var rejectReason = ""
    @State private var pdfURL: URL?
    @State private var showShareSheet = false

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
                    EmptyStateView(icon: "checkmark.seal", title: "No verification requests")
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
        .navigationTitle("Employment Verification")
        .brandNavBar()
        .refreshable { await vm.load() }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL { ShareSheet(items: [url]) }
        }
        .alert("Issue Verification", isPresented: Binding(
            get: { confirmAction?.action == "issue" },
            set: { if !$0 { confirmAction = nil } }
        )) {
            Button("Cancel", role: .cancel) { confirmAction = nil }
            Button("Issue") {
                if let ca = confirmAction {
                    Task { await vm.issue(id: ca.id) }
                }
                confirmAction = nil
            }
        } message: {
            Text("Issue this employment verification?")
        }
        .alert("Reject Verification", isPresented: Binding(
            get: { rejectId != nil },
            set: { if !$0 { rejectId = nil; rejectReason = "" } }
        )) {
            TextField("Reason (optional)", text: $rejectReason)
            Button("Cancel", role: .cancel) { rejectId = nil; rejectReason = "" }
            Button("Reject", role: .destructive) {
                if let id = rejectId {
                    Task { await vm.reject(id: id, reason: rejectReason.isEmpty ? nil : rejectReason) }
                }
                rejectId = nil
                rejectReason = ""
            }
        } message: {
            Text("Reject this employment verification request?")
        }
        .task { await vm.load() }
    }

    private func requestRow(_ r: EmploymentVerificationRequest) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(r.employee_name ?? "Unknown Employee")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                    if let requester = r.requester_name {
                        Text("Requested by: \(requester)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    if let company = r.requester_company {
                        Text(company)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    if let purpose = r.purpose {
                        Text("Purpose: \(purpose)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    Text(formatDate(r.created_at))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                StatusBadge(status: r.status ?? "pending")
            }
            .padding(12)

            // Actions for pending
            if r.status == "pending" {
                Divider().background(Color.white.opacity(0.08))
                HStack(spacing: 0) {
                    Button {
                        confirmAction = (id: r.id, action: "issue")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal").font(.caption2)
                            Text("Issue").font(.caption).fontWeight(.medium)
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }

                    Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 24)

                    Button {
                        rejectId = r.id
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle").font(.caption2)
                            Text("Reject").font(.caption).fontWeight(.medium)
                        }
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }

                    Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 24)

                    Button {
                        Task {
                            if let url = await vm.downloadPDF(id: r.id) {
                                pdfURL = url
                                showShareSheet = true
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.doc").font(.caption2)
                            Text("PDF").font(.caption).fontWeight(.medium)
                        }
                        .foregroundColor(.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }

            // Actions for issued
            if r.status == "issued" {
                Divider().background(Color.white.opacity(0.08))
                Button {
                    Task {
                        if let url = await vm.downloadPDF(id: r.id) {
                            pdfURL = url
                            showShareSheet = true
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.doc").font(.caption2)
                        Text("Download PDF").font(.caption).fontWeight(.medium)
                    }
                    .foregroundColor(.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
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
