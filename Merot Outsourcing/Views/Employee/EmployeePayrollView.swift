import SwiftUI

struct EmployeePayrollView: View {
    @State private var records: [EmpPayrollRecord] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                if let error {
                    ErrorBanner(message: error).listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                if records.isEmpty && !isLoading {
                    EmptyStateView(icon: "banknote", title: "No payroll records").listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                ForEach(records) { r in
                    NavigationLink(destination: EmployeePayrollDetailView(recordId: r.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(r.payroll_batch?.period ?? r.period_label ?? r.period ?? "Payroll")
                                    .font(.subheadline).bold().foregroundColor(.white)
                                Spacer()
                                Text(r.country?.replacingOccurrences(of: "_", with: " ").capitalized ?? "")
                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                            }
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Net").font(.caption2).foregroundColor(.white.opacity(0.4))
                                    Text(formatMoney(r.net_pay)).font(.headline).foregroundColor(.accent)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Gross").font(.caption2).foregroundColor(.white.opacity(0.4))
                                    Text(formatMoney(r.gross_pay)).font(.subheadline).foregroundColor(.white.opacity(0.7))
                                }
                            }
                            if r.overtime_hours ?? 0 > 0 {
                                Text("OT: \(String(format: "%.1f", r.overtime_hours ?? 0))h")
                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.white.opacity(0.06))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Payroll")
            .brandNavBar()
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmpPayrollResponse = try await APIService.shared.request("GET", "/employees/payroll_records", query: ["per_page": "50"])
            records = res.data?.payroll_records ?? []
        } catch {
            self.error = "Failed to load payroll"
            #if DEBUG
            print("[EmpPayroll] \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Payroll Detail View

struct EmployeePayrollDetailView: View {
    let recordId: Int
    @State private var record: EmpPayrollRecord?
    @State private var isLoading = true
    @State private var error: String?
    @State private var isDownloading = false
    @State private var showShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        ScrollView {
            if isLoading && record == nil {
                LoadingView()
            } else if let err = error, record == nil {
                ErrorBanner(message: err)
            } else if let r = record {
                VStack(spacing: 12) {
                    // Period header
                    CardView {
                        VStack(spacing: 8) {
                            Text(r.payroll_batch?.period ?? r.period_label ?? "Payroll Record")
                                .font(.title3).bold().foregroundColor(.white)
                            if let payDate = r.payroll_batch?.pay_date {
                                Text("Pay date: \(formatDate(payDate))")
                                    .font(.caption).foregroundColor(.white.opacity(0.4))
                            }
                            if let wh = r.payroll_batch?.working_hours {
                                Text("Working hours: \(wh)h")
                                    .font(.caption).foregroundColor(.white.opacity(0.4))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Net / Gross summary
                    HStack(spacing: 10) {
                        StatCard(icon: "banknote", title: "Net Pay", value: formatMoney(r.net_pay), color: .accent)
                        StatCard(icon: "chart.bar", title: "Gross Pay", value: formatMoney(r.gross_pay), color: .white.opacity(0.6))
                    }

                    // Earnings breakdown
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Earnings").font(.headline).foregroundColor(.white.opacity(0.7))
                            salaryRow("Base Salary", value: r.base_salary)
                            if r.overtime_hours ?? 0 > 0 {
                                salaryRow("Overtime (\(String(format: "%.1f", r.overtime_hours ?? 0))h)", value: r.overtime_pay)
                            }
                            if r.night_hours ?? 0 > 0 {
                                salaryRow("Night (\(String(format: "%.1f", r.night_hours ?? 0))h)", value: r.night_pay)
                            }
                            if r.holiday_hours ?? 0 > 0 {
                                salaryRow("Holiday (\(String(format: "%.1f", r.holiday_hours ?? 0))h)", value: r.holiday_pay)
                            }
                            if r.sunday_hours ?? 0 > 0 {
                                salaryRow("Sunday (\(String(format: "%.1f", r.sunday_hours ?? 0))h)", value: r.sunday_pay)
                            }
                            if r.seniority ?? 0 > 0 {
                                salaryRow("Seniority Bonus", value: r.seniority)
                            }
                        }
                    }

                    // Taxes / Deductions
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Deductions").font(.headline).foregroundColor(.white.opacity(0.7))
                            salaryRow("Pension", value: r.pension_tax, isDeduction: true)
                            salaryRow("Health Insurance", value: r.health_insurance_tax, isDeduction: true)
                            if r.disability_insurance_tax ?? 0 > 0 {
                                salaryRow("Disability Insurance", value: r.disability_insurance_tax, isDeduction: true)
                            }
                            if r.employment_insurance_tax ?? 0 > 0 {
                                salaryRow("Employment Insurance", value: r.employment_insurance_tax, isDeduction: true)
                            }
                            salaryRow("Personal Tax", value: r.personal_tax, isDeduction: true)
                            Divider().background(Color.white.opacity(0.1))
                            HStack {
                                Text("Total Deductions")
                                    .font(.subheadline).bold().foregroundColor(.white)
                                Spacer()
                                Text(formatMoney(r.all_taxes))
                                    .font(.subheadline).bold().foregroundColor(.red.opacity(0.8))
                            }
                        }
                    }

                    // Download Paystub
                    Button {
                        Task { await downloadPaystub() }
                    } label: {
                        HStack {
                            if isDownloading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "arrow.down.doc.fill")
                                Text("Download Paystub")
                            }
                        }
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .cornerRadius(12)
                    }
                    .disabled(isDownloading)
                    .padding(.top, 4)
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Paystub")
        .brandNavBar()
        .task { await loadDetail() }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }

    private func salaryRow(_ label: String, value: Double?, isDeduction: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline).foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(formatMoney(value))
                .font(.subheadline).foregroundColor(isDeduction ? .red.opacity(0.7) : .white)
        }
    }

    private func loadDetail() async {
        isLoading = true
        error = nil
        do {
            let res: EmpPayrollDetailResponse = try await APIService.shared.request("GET", "/employees/payroll_records/\(recordId)")
            record = res.data?.payroll_record
        } catch {
            self.error = "Failed to load payroll detail"
            #if DEBUG
            print("[EmpPayrollDetail] \(error)")
            #endif
        }
        isLoading = false
    }

    private func downloadPaystub() async {
        isDownloading = true
        do {
            let data = try await APIService.shared.requestData("GET", "/employees/payroll_records/\(recordId)/paystub_pdf")
            pdfData = data
            showShareSheet = true
        } catch {
            self.error = "Failed to download paystub"
            #if DEBUG
            print("[EmpPaystubPDF] \(error)")
            #endif
        }
        isDownloading = false
    }
}

