import SwiftUI

struct EmployerTimeOffView: View {
    @State private var requests: [EmployerTimeOffRequest] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var actionError: String?
    @State private var actionSuccess: String?
    @State private var selectedFilter = "all"

    private let filters = ["all", "pending", "approved", "denied"]

    private var filtered: [EmployerTimeOffRequest] {
        if selectedFilter == "all" { return requests }
        return requests.filter { ($0.approval_status ?? "").lowercased() == selectedFilter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter.capitalized)
                                    .font(.caption).fontWeight(.medium)
                                    .foregroundColor(selectedFilter == filter ? .brand : .white.opacity(0.6))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(selectedFilter == filter ? Color.accent : Color.white.opacity(0.08))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                if let msg = actionSuccess {
                    SuccessBanner(message: msg)
                        .padding(.bottom, 4)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                actionSuccess = nil
                            }
                        }
                }
                if let msg = actionError {
                    ErrorBanner(message: msg)
                        .padding(.bottom, 4)
                }

                List {
                    if let error {
                        ErrorBanner(message: error)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    if filtered.isEmpty && !isLoading {
                        EmptyStateView(icon: "calendar.badge.clock", title: "No time off requests")
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    ForEach(filtered) { req in
                        timeOffRow(req)
                            .listRowBackground(Color.white.opacity(0.06))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Time Off")
            .brandNavBar()
            .refreshable { await loadRequests() }
            .task { await loadRequests() }
            .overlay {
                if isLoading && requests.isEmpty {
                    LoadingView()
                }
            }
        }
    }

    private func timeOffRow(_ req: EmployerTimeOffRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(req.employee?.full_name ?? "Employee")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(.white)
                    if let type = req.time_off_record?.name ?? req.time_off_record?.leave_type {
                        Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                    }
                }
                Spacer()
                StatusBadge(status: req.approval_status ?? "pending")
            }

            HStack {
                Image(systemName: "calendar")
                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                Text("\(formatDateShort(req.start_date)) - \(formatDateShort(req.end_date))")
                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                Spacer()
                Text("\(req.days ?? 0) days")
                    .font(.caption).bold().foregroundColor(.accent)
            }

            // Action buttons for pending requests
            if (req.approval_status ?? "").lowercased() == "pending" {
                HStack(spacing: 10) {
                    Button {
                        Task { await approveRequest(req.id) }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text("Approve")
                        }
                        .font(.caption).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.brandGreen)
                        .cornerRadius(8)
                    }

                    Button {
                        Task { await denyRequest(req.id) }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("Deny")
                        }
                        .font(.caption).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadRequests() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerTimeOffResponse = try await APIService.shared.request("GET", "/employers/time_off_requests", query: ["per_page": "100"])
            requests = res.data?.time_off_requests ?? []
        } catch {
            self.error = "Failed to load time off requests"
            #if DEBUG
            print("[EmployerTimeOff] \(error)")
            #endif
        }
        isLoading = false
    }

    private func approveRequest(_ id: Int) async {
        actionError = nil
        actionSuccess = nil
        do {
            let _: APIResponse<String> = try await APIService.shared.request("POST", "/employers/time_off_requests/\(id)/approve")
            actionSuccess = "Request approved"
            await loadRequests()
        } catch {
            actionError = "Failed to approve request"
            #if DEBUG
            print("[EmployerTimeOff] Approve error: \(error)")
            #endif
        }
    }

    private func denyRequest(_ id: Int) async {
        actionError = nil
        actionSuccess = nil
        do {
            let _: APIResponse<String> = try await APIService.shared.request("POST", "/employers/time_off_requests/\(id)/deny")
            actionSuccess = "Request denied"
            await loadRequests()
        } catch {
            actionError = "Failed to deny request"
            #if DEBUG
            print("[EmployerTimeOff] Deny error: \(error)")
            #endif
        }
    }
}
