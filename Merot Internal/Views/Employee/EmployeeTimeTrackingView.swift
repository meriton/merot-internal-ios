import SwiftUI

struct EmployeeTimeTrackingView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var isClockedIn = false
    @State private var isLoading = false
    @State private var records: [EmpTimeKeepingRecord] = []
    @State private var isLoadingHistory = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Clock In/Out Section
                    CardView {
                        VStack(spacing: 16) {
                            Image(systemName: isClockedIn ? "clock.badge.checkmark.fill" : "clock.fill")
                                .font(.system(size: 48))
                                .foregroundColor(isClockedIn ? .brandGreen : .white.opacity(0.5))

                            Text(isClockedIn ? "Clocked In" : "Clocked Out")
                                .font(.title3).fontWeight(.bold)
                                .foregroundColor(.white)

                            Button {
                                Task { await toggleClock() }
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text(isClockedIn ? "Clock Out" : "Clock In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(isClockedIn ? Color.red.opacity(0.8) : Color.brandGreen)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Time Tracking History
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Activity")
                            .font(.headline).foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 4)

                        if isLoadingHistory && records.isEmpty {
                            CardView {
                                HStack {
                                    Spacer()
                                    ProgressView().tint(.white)
                                    Spacer()
                                }
                            }
                        } else if records.isEmpty {
                            CardView {
                                EmptyStateView(icon: "clock", title: "No records yet")
                            }
                        } else {
                            ForEach(records) { record in
                                CardView {
                                    HStack(spacing: 12) {
                                        VStack(spacing: 4) {
                                            Image(systemName: "calendar")
                                                .font(.caption).foregroundColor(.accent)
                                            Text(formatDateShort(record.time_in))
                                                .font(.caption2).foregroundColor(.white.opacity(0.5))
                                        }
                                        .frame(width: 50)

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .font(.caption2).foregroundColor(.brandGreen)
                                                Text(formatTime(record.time_in))
                                                    .font(.subheadline).foregroundColor(.white)
                                            }
                                            HStack(spacing: 6) {
                                                Image(systemName: "arrow.left.circle.fill")
                                                    .font(.caption2).foregroundColor(.red.opacity(0.7))
                                                Text(record.time_out != nil ? formatTime(record.time_out) : "--:--")
                                                    .font(.subheadline).foregroundColor(.white.opacity(0.7))
                                            }
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(String(format: "%.1fh", record.hours_worked ?? 0))
                                                .font(.title3).bold().foregroundColor(.accent)
                                            Text("hours")
                                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Time Tracking")
            .brandNavBar()
            .refreshable { await loadAll() }
            .task { await loadAll() }
        }
    }

    private func loadAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loadStatus() }
            group.addTask { await loadHistory() }
        }
    }

    private func loadStatus() async {
        if let res: APIResponse<[String: Bool]> = try? await APIService.shared.request("GET", "/employees/time_tracking/status") {
            isClockedIn = res.data?["clocked_in"] ?? false
        }
    }

    private func loadHistory() async {
        isLoadingHistory = true
        do {
            let res: EmpTimeTrackingResponse = try await APIService.shared.request("GET", "/employees/time_tracking", query: ["per_page": "30"])
            records = res.data?.time_keeping_records ?? []
        } catch {
            #if DEBUG
            print("[EmpTimeTracking] \(error)")
            #endif
        }
        isLoadingHistory = false
    }

    private func toggleClock() async {
        isLoading = true
        let endpoint = isClockedIn ? "/employees/clock_out" : "/employees/clock_in"
        let _: APIResponse<String>? = try? await APIService.shared.request("POST", endpoint)
        isClockedIn.toggle()
        isLoading = false
        await loadHistory()
    }
}

// MARK: - Time Formatter

private func formatTime(_ iso: String?) -> String {
    guard let iso = iso else { return "--:--" }
    // Extract time portion from ISO 8601
    if let tIndex = iso.firstIndex(of: "T") {
        let timeStr = iso[iso.index(after: tIndex)...]
        let parts = timeStr.split(separator: ":")
        if parts.count >= 2 {
            return "\(parts[0]):\(parts[1])"
        }
    }
    return "--:--"
}
