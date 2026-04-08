import SwiftUI

struct InvoiceFormView: View {
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = InvoicesViewModel()
    @StateObject private var employersVM = EmployersViewModel()
    @StateObject private var employeesVM = EmployeesViewModel()

    @State private var selectedEmployerId: Int?
    @State private var issueDate = Date()
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var billingPeriodStart = Date()
    @State private var billingPeriodEnd = Date()
    @State private var currency = "USD"
    @State private var description = ""
    @State private var notes = ""
    @State private var paymentTerms = "Net 30"
    @State private var lineItems: [LineItemEntry] = [LineItemEntry()]
    @State private var isSaving = false
    @State private var error: String?

    let currencies = ["USD"]

    struct LineItemEntry: Identifiable {
        let id = UUID()
        var description: String = ""
        var quantity: String = "1"
        var unitPrice: String = ""
        var employeeName: String = ""
        var lineItemType: String = "service"
    }

    let lineItemTypes = ["service", "salary", "fee", "reimbursement", "bonus", "other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error {
                        ErrorBanner(message: error)
                    }

                    // Employer picker
                    formSection("Employer") {
                        if employersVM.employers.isEmpty {
                            Text("Loading employers...")
                                .font(.caption).foregroundColor(.white.opacity(0.4))
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Employer").font(.caption).foregroundColor(.white.opacity(0.5))
                                Picker("Employer", selection: $selectedEmployerId) {
                                    Text("Select...").tag(nil as Int?)
                                    ForEach(employersVM.employers) { emp in
                                        Text(emp.name ?? "Unknown").tag(emp.id as Int?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.accent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(8)
                            }
                        }
                    }

                    // Dates
                    formSection("Dates") {
                        dateField("Issue Date", date: $issueDate)
                        dateField("Due Date", date: $dueDate)
                        dateField("Billing Period Start", date: $billingPeriodStart)
                        dateField("Billing Period End", date: $billingPeriodEnd)
                    }

                    // Details
                    formSection("Details") {
                        pickerField("Currency", selection: $currency, options: currencies)
                        textField("Payment Terms", text: $paymentTerms)
                        textField("Description (optional)", text: $description)
                        multilineField("Notes (optional)", text: $notes)
                    }

                    // Line Items
                    formSection("Line Items") {
                        ForEach($lineItems) { $item in
                            lineItemRow($item)
                            if item.id != lineItems.last?.id {
                                Divider().background(Color.white.opacity(0.1))
                            }
                        }

                        Button {
                            lineItems.append(LineItemEntry())
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Line Item")
                            }
                            .font(.caption).fontWeight(.medium)
                            .foregroundColor(.accent)
                        }
                        .padding(.top, 4)
                    }

                    // Total preview
                    let total = lineItems.compactMap { item -> Double? in
                        guard let qty = Double(item.quantity), let price = Double(item.unitPrice) else { return nil }
                        return qty * price
                    }.reduce(0, +)

                    if total > 0 {
                        HStack {
                            Text("Estimated Total")
                                .font(.subheadline).foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(formatMoney(total, currency: currency))
                                .font(.title3).bold().foregroundColor(.accent)
                        }
                        .padding(.horizontal, 4)
                    }

                    // Save button
                    Button {
                        Task { await save() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text("Create Invoice").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(selectedEmployerId == nil || lineItems.allSatisfy { $0.unitPrice.isEmpty } || isSaving)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white)
                }
            }
            .task {
                await employersVM.load()
                await employeesVM.load()
            }
        }
    }

    private func lineItemRow(_ item: Binding<LineItemEntry>) -> some View {
        VStack(spacing: 8) {
            HStack {
                textField("Description", text: item.description)
                if lineItems.count > 1 {
                    Button {
                        lineItems.removeAll { $0.id == item.wrappedValue.id }
                    } label: {
                        Image(systemName: "trash").font(.caption).foregroundColor(.red.opacity(0.7))
                    }
                }
            }
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Qty").font(.caption2).foregroundColor(.white.opacity(0.4))
                    TextField("1", text: item.quantity)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                        .frame(width: 60)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unit Price").font(.caption2).foregroundColor(.white.opacity(0.4))
                    TextField("0.00", text: item.unitPrice)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                }
            }
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Type").font(.caption2).foregroundColor(.white.opacity(0.4))
                    Picker("Type", selection: item.lineItemType) {
                        ForEach(lineItemTypes, id: \.self) { t in
                            Text(t.capitalized).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Employee (optional)").font(.caption2).foregroundColor(.white.opacity(0.4))
                    TextField("Employee name", text: item.employeeName)
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                }
            }
        }
    }

    private func save() async {
        isSaving = true
        error = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var body: [String: Any] = [
            "employer_id": selectedEmployerId ?? 0,
            "issue_date": dateFormatter.string(from: issueDate),
            "due_date": dateFormatter.string(from: dueDate),
            "billing_period_start": dateFormatter.string(from: billingPeriodStart),
            "billing_period_end": dateFormatter.string(from: billingPeriodEnd),
            "currency": currency,
            "payment_terms": paymentTerms
        ]
        if !description.isEmpty { body["description"] = description }
        if !notes.isEmpty { body["notes"] = notes }

        let items: [[String: Any]] = lineItems.compactMap { item in
            guard let price = Double(item.unitPrice), !item.description.isEmpty else { return nil }
            var dict: [String: Any] = [
                "description": item.description,
                "quantity": Double(item.quantity) ?? 1,
                "unit_price": price,
                "line_item_type": item.lineItemType
            ]
            if !item.employeeName.isEmpty { dict["employee_name"] = item.employeeName }
            return dict
        }
        body["invoice_line_items_attributes"] = items

        let success = await vm.create(body: body)
        if success {
            onSave()
            dismiss()
        } else {
            error = vm.error
        }
        isSaving = false
    }

    // MARK: - Form Components

    private func formSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                content()
            }
        }
    }

    private func textField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            TextField("", text: text)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(8)
        }
    }

    private func multilineField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            TextField("", text: text, axis: .vertical)
                .lineLimit(2...4)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(8)
        }
    }

    private func dateField(_ label: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)
        }
    }

    private func pickerField(_ label: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            Picker(label, selection: selection) {
                ForEach(options, id: \.self) { opt in
                    Text(opt).tag(opt)
                }
            }
            .pickerStyle(.menu)
            .tint(.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)
            .background(Color.white.opacity(0.08))
            .cornerRadius(8)
        }
    }
}
