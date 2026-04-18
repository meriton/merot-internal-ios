import SwiftUI

struct EmployeeDashboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var data: EmployeeDashData?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading && data == nil {
                    LoadingView()
                } else if let d = data {
                    VStack(spacing: 12) {
                        // Welcome
                        CardView {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(d.employee?.full_name ?? auth.user?.full_name ?? "")")
                                    .font(.headline).foregroundColor(.white)
                                if let emp = d.employment {
                                    Text(emp.position ?? "")
                                        .font(.caption).foregroundColor(.accent)
                                    if let name = emp.employer?.name {
                                        Text(name)
                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                        }

                        // Stats row
                        HStack(spacing: 10) {
                            StatCard(icon: "clock", title: "Hours/Week", value: String(format: "%.1f", d.time_tracking?.total_hours_this_week ?? 0))
                            StatCard(icon: "calendar", title: "Hours/Month", value: String(format: "%.1f", d.time_tracking?.total_hours_this_month ?? 0))
                            StatCard(icon: "sun.max", title: "Days Off", value: "\(Int(d.time_off?.available_days ?? 0))")
                        }

                        // Clock status
                        if let tt = d.time_tracking {
                            CardView {
                                HStack {
                                    Image(systemName: tt.currently_clocked_in == true ? "clock.badge.checkmark.fill" : "clock")
                                        .foregroundColor(tt.currently_clocked_in == true ? .green : .white.opacity(0.4))
                                    Text(tt.currently_clocked_in == true ? "Currently Clocked In" : "Not Clocked In")
                                        .font(.subheadline).foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }

                        // Last Paystub
                        if let pay = d.last_paystub {
                            CardView {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Last Paystub").font(.caption).foregroundColor(.white.opacity(0.4))
                                    HStack {
                                        Text(formatMoney(pay.net_salary, currency: pay.currency))
                                            .font(.title3).bold().foregroundColor(.accent)
                                        Spacer()
                                        Text("gross: \(formatMoney(pay.gross_salary, currency: pay.currency))")
                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    }
                                    if let period = pay.period {
                                        Text(period).font(.caption2).foregroundColor(.white.opacity(0.3))
                                    }
                                }
                            }
                        }

                        // Next Holiday
                        if let h = d.next_holiday {
                            CardView {
                                HStack {
                                    Image(systemName: "calendar").foregroundColor(.accent)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(h.name ?? "Holiday").font(.subheadline).foregroundColor(.white)
                                        Text("\(h.date ?? "") - \(h.day_of_week ?? "")")
                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    if let days = h.days_until {
                                        Text(days == 0 ? "Today" : "\(days)d")
                                            .font(.caption).bold().foregroundColor(.accent)
                                    }
                                }
                            }
                        }

                        // Pending Time Off
                        if let pending = d.time_off?.pending_requests, !pending.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Pending Time Off").font(.caption).foregroundColor(.white.opacity(0.4))
                                    ForEach(pending, id: \.id) { req in
                                        HStack {
                                            Text("\(req.start_date?.prefix(10) ?? "") - \(req.end_date?.prefix(10) ?? "")")
                                                .font(.caption).foregroundColor(.white)
                                            Spacer()
                                            Text("\(req.days ?? 0) days")
                                                .font(.caption2).foregroundColor(.accent)
                                            StatusBadge(status: req.approval_status ?? "pending")
                                        }
                                    }
                                }
                            }
                        }

                        // Leave Balances
                        if let balances = d.time_off?.balances, !balances.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Leave Balances").font(.caption).foregroundColor(.white.opacity(0.4))
                                    ForEach(balances, id: \.id) { b in
                                        HStack {
                                            Text((b.leave_type ?? "").replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(.caption).foregroundColor(.white)
                                            Spacer()
                                            Text("\(Int(b.balance ?? 0))/\(Int(b.days ?? 0))")
                                                .font(.caption).bold().foregroundColor(.accent)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .brandNavBar()
            .refreshable { await loadDashboard() }
            .task { await loadDashboard() }
        }
    }

    private func loadDashboard() async {
        isLoading = true
        do {
            let res: APIResponse<EmployeeDashData> = try await APIService.shared.request("GET", "/employees/dashboard")
            data = res.data
        } catch {
            #if DEBUG
            print("[EmpDash] Error: \(error)")
            #endif
        }
        isLoading = false
    }
}
