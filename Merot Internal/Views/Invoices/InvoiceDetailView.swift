import SwiftUI

struct InvoiceDetailView: View {
    let invoiceId: Int
    @StateObject private var vm = InvoiceDetailViewModel()
    @State private var showRecordPayment = false

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.invoice == nil {
                LoadingView()
            } else if let inv = vm.invoice {
                VStack(spacing: 16) {
                    if let msg = vm.successMessage {
                        SuccessBanner(message: msg)
                    }
                    if let err = vm.error {
                        ErrorBanner(message: err)
                    }

                    // Header
                    CardView {
                        VStack(spacing: 12) {
                            Text(inv.invoice_number ?? "#\(inv.id)")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            Text(inv.employer_name ?? "Unknown")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                            StatusBadge(status: inv.overdue == true ? "overdue" : (inv.status ?? "unknown"))
                            Text(formatMoney(inv.total_amount, currency: inv.currency))
                                .font(.system(.title, design: .monospaced)).bold()
                                .foregroundColor(.accent)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Dates
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Details").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "calendar", label: "Issue Date", value: formatDate(inv.issue_date))
                            InfoRow(icon: "calendar.badge.exclamationmark", label: "Due Date", value: formatDate(inv.due_date))
                            if let bp = inv.billing_period_display {
                                InfoRow(icon: "calendar.day.timeline.left", label: "Billing Period", value: bp)
                            }
                            InfoRow(icon: "dollarsign.circle", label: "Subtotal", value: formatMoney(inv.subtotal, currency: inv.currency))
                            InfoRow(icon: "percent", label: "Tax", value: formatMoney(inv.tax_amount, currency: inv.currency))
                            if let lf = inv.late_fee?.value, lf > 0 {
                                InfoRow(icon: "exclamationmark.triangle", label: "Late Fee", value: formatMoney(lf, currency: inv.currency))
                            }
                            if let d = inv.discount_amount?.value, d > 0 {
                                InfoRow(icon: "tag.fill", label: "Discount", value: "-\(formatMoney(d, currency: inv.currency))")
                            }
                            if let terms = inv.payment_terms {
                                InfoRow(icon: "doc.text", label: "Payment Terms", value: terms)
                            }
                        }
                    }

                    // Actions
                    actionsSection(inv)

                    // Line Items
                    if !vm.lineItems.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Line Items (\(vm.lineItems.count))")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                ForEach(vm.lineItems) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.description ?? "Item")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text(formatMoney(item.total_price))
                                                .font(.subheadline).bold()
                                                .foregroundColor(.accent)
                                        }
                                        HStack {
                                            if let type = item.line_item_type {
                                                Text(type.replacingOccurrences(of: "_", with: " "))
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                            Spacer()
                                            if let qty = item.quantity?.value, let price = item.unit_price {
                                                Text("\(Int(qty)) x \(formatMoney(price))")
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.4))
                                            }
                                        }
                                        if let emp = item.employee_name {
                                            Text(emp)
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                    }
                                    if item.id != vm.lineItems.last?.id {
                                        Divider().background(Color.white.opacity(0.08))
                                    }
                                }
                            }
                        }
                    }

                    // Transactions
                    if !vm.transactions.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Transactions").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(vm.transactions) { txn in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(txn.payment_method ?? "Payment")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Text(formatDate(txn.processed_at ?? txn.created_at))
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(formatMoney(txn.amount, currency: txn.currency))
                                                .font(.subheadline).bold()
                                                .foregroundColor(.accent)
                                            StatusBadge(status: txn.status ?? "unknown")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if let notes = inv.notes, !notes.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notes").font(.headline).foregroundColor(.white.opacity(0.7))
                                Text(notes).font(.caption).foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle(vm.invoice?.invoice_number ?? "Invoice")
        .brandNavBar()
        .refreshable { await vm.load(id: invoiceId) }
        .sheet(isPresented: $showRecordPayment) { recordPaymentSheet }
        .task { await vm.load(id: invoiceId) }
    }

    // MARK: - Actions

    @ViewBuilder
    private func actionsSection(_ inv: Invoice) -> some View {
        let status = inv.status ?? ""
        if status == "draft" || status == "approved" || status == "sent" {
            CardView {
                VStack(spacing: 10) {
                    Text("Actions").font(.headline).foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity, alignment: .leading)

                    if status == "draft" {
                        actionButton("Approve", icon: "checkmark.circle.fill", color: .green) {
                            Task { await vm.approve(id: invoiceId) }
                        }
                    }
                    if status == "approved" {
                        actionButton("Mark as Sent", icon: "paperplane.fill", color: .blue) {
                            Task { await vm.markSent(id: invoiceId) }
                        }
                    }
                    if status == "sent" || status == "approved" {
                        actionButton("Mark as Paid", icon: "banknote.fill", color: .green) {
                            Task { await vm.markPaid(id: invoiceId) }
                        }
                        actionButton("Record Payment", icon: "plus.circle.fill", color: .accent) {
                            showRecordPayment = true
                        }
                    }
                    if status == "sent" {
                        actionButton("Send Email", icon: "envelope.fill", color: .blue) {
                            Task { await vm.sendEmail(id: invoiceId) }
                        }
                    }
                    if status != "paid" && status != "cancelled" {
                        actionButton("Cancel Invoice", icon: "xmark.circle.fill", color: .red) {
                            Task { await vm.cancel(id: invoiceId) }
                        }
                    }
                }
            }
        }
    }

    private func actionButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if vm.isActioning {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: icon)
                    Text(label)
                }
            }
            .font(.subheadline).fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.8))
            .cornerRadius(10)
        }
        .disabled(vm.isActioning)
    }

    // MARK: - Record Payment Sheet

    private var recordPaymentSheet: some View {
        RecordPaymentSheet(invoiceId: invoiceId, vm: vm, isPresented: $showRecordPayment)
    }
}

struct RecordPaymentSheet: View {
    let invoiceId: Int
    @ObservedObject var vm: InvoiceDetailViewModel
    @Binding var isPresented: Bool
    @State private var amount = ""
    @State private var method = "bank_transfer"
    @State private var reference = ""

    let methods = ["bank_transfer", "wire", "check", "cash", "credit_card", "other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Amount").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Payment Method").font(.caption).foregroundColor(.white.opacity(0.5))
                        Picker("Method", selection: $method) {
                            ForEach(methods, id: \.self) { m in
                                Text(m.replacingOccurrences(of: "_", with: " ").capitalized).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.accent)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reference Number (optional)").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("", text: $reference)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    Button {
                        Task {
                            await vm.recordPayment(id: invoiceId, amount: Double(amount) ?? 0, method: method, reference: reference.isEmpty ? nil : reference)
                            if vm.error == nil { isPresented = false }
                        }
                    } label: {
                        HStack {
                            if vm.isActioning { ProgressView().tint(.white) }
                            else { Text("Record Payment").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(amount.isEmpty || vm.isActioning)

                    if let err = vm.error {
                        Text(err).font(.caption).foregroundColor(.red)
                    }
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.white)
                }
            }
        }
    }
}
