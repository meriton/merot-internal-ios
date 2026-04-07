import SwiftUI

struct PayrollListView: View {
    @StateObject private var vm = PayrollViewModel()

    var body: some View {
        ScrollView {
            if let error = vm.error {
                ErrorBanner(message: error)
            }

            if vm.batches.isEmpty && !vm.isLoading {
                EmptyStateView(icon: "banknote", title: "No payroll batches")
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(vm.batches) { batch in
                        NavigationLink(destination: PayrollDetailView(batchId: batch.id)) {
                            batchRow(batch)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Payroll")
        .brandNavBar()
        .refreshable { await vm.load() }
        .task { await vm.load() }
    }

    private func batchRow(_ b: PayrollBatch) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(b.periodLabel)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(b.records_count ?? 0) records")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: b.approved == true ? "approved" : "draft")
                if let gross = b.total_mkd_gross, gross > 0 {
                    Text("\(formatMoney(gross)) MKD")
                        .font(.caption2)
                        .foregroundColor(.accent.opacity(0.7))
                }
                if let gross = b.total_eur_gross, gross > 0 {
                    Text("\(formatMoney(gross)) EUR")
                        .font(.caption2)
                        .foregroundColor(.accent.opacity(0.7))
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct PayrollDetailView: View {
    let batchId: Int
    @StateObject private var vm = PayrollDetailViewModel()

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.batch == nil {
                LoadingView()
            } else if let batch = vm.batch {
                VStack(spacing: 16) {
                    if let msg = vm.successMessage {
                        SuccessBanner(message: msg)
                    }
                    if let err = vm.error {
                        ErrorBanner(message: err)
                    }

                    // Header
                    CardView {
                        VStack(spacing: 10) {
                            Text(batchPeriodLabel(batch))
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            HStack(spacing: 16) {
                                VStack {
                                    Text("\(batch.payroll_records?.count ?? 0)")
                                        .font(.title2).bold()
                                        .foregroundColor(.accent)
                                    Text("Records")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                if let wh = batch.working_hours?.value {
                                    VStack {
                                        Text("\(Int(wh))")
                                            .font(.title2).bold()
                                            .foregroundColor(.white)
                                        Text("Work Hours")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                            StatusBadge(status: batch.approved == true ? "approved" : "draft")

                            if batch.approved != true {
                                Button {
                                    Task { await vm.approve(id: batchId) }
                                } label: {
                                    HStack {
                                        if vm.isApproving { ProgressView().tint(.white) }
                                        else { Text("Approve Batch").fontWeight(.semibold) }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.brandGreen)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(vm.isApproving)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Records
                    if let records = batch.payroll_records, !records.isEmpty {
                        SectionHeader(title: "Employee Records")
                        ForEach(records) { record in
                            payrollRecordRow(record)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Payroll Batch")
        .brandNavBar()
        .refreshable { await vm.load(id: batchId) }
        .task { await vm.load(id: batchId) }
    }

    private func batchPeriodLabel(_ batch: PayrollBatchWithRecords) -> String {
        let months = ["", "January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        if let m = batch.month, let mi = Int(m), mi >= 1 && mi <= 12, let y = batch.year {
            return "\(months[mi]) \(y)"
        }
        return "\(batch.month ?? "") \(batch.year ?? 0)"
    }

    private func payrollRecordRow(_ r: PayrollRecord) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(r.employee_name ?? "Unknown")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                    Spacer()
                    if let country = r.country {
                        Text(country.uppercased())
                            .font(.caption2).bold()
                            .foregroundColor(.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accent.opacity(0.15))
                            .cornerRadius(4)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Net")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                        Text(formatMoney(r.net_salary))
                            .font(.system(.body, design: .monospaced)).bold()
                            .foregroundColor(.accent)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Gross")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                        Text(formatMoney(r.gross_salary))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }

                // Extra details
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                    if let ot = r.overtime_hours, ot > 0 {
                        detailItem("OT Hours", "\(Int(ot.value))h")
                    }
                    if let otp = r.overtime_pay, otp > 0 {
                        detailItem("OT Pay", formatMoney(otp))
                    }
                    if let pt = r.personal_tax, pt > 0 {
                        detailItem("Tax", formatMoney(pt))
                    }
                    if let pen = r.pension_tax, pen > 0 {
                        detailItem("Pension", formatMoney(pen))
                    }
                }
            }
        }
    }

    private func detailItem(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.caption2).foregroundColor(.white.opacity(0.4))
            Spacer()
            Text(value).font(.caption2).foregroundColor(.white.opacity(0.6))
        }
    }
}
