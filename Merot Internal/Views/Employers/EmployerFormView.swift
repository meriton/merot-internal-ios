import SwiftUI

struct EmployerFormView: View {
    let employer: EmployerFull?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @StateObject private var detailVM = EmployerDetailViewModel()
    @StateObject private var listVM = EmployersViewModel()

    @State private var name = ""
    @State private var legalName = ""
    @State private var primaryEmail = ""
    @State private var billingEmail = ""
    @State private var phone = ""
    @State private var website = ""
    @State private var industry = ""
    @State private var taxNumber = ""
    @State private var registrationNumber = ""
    @State private var addressLine1 = ""
    @State private var addressCity = ""
    @State private var addressState = ""
    @State private var addressZip = ""
    @State private var addressCountry = ""
    @State private var status = "active"
    @State private var isSaving = false
    @State private var error: String?

    let statuses = ["active", "suspended", "deactivated"]
    let countryOptions = ["US", "MK", "XK", "AL", "DE", "GB", "Other"]

    var isEditing: Bool { employer != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error {
                        ErrorBanner(message: error)
                    }

                    formSection("Company Information") {
                        formField("Company Name", text: $name)
                        formField("Legal Name", text: $legalName)
                        formField("Industry", text: $industry)
                        if isEditing {
                            pickerField("Status", selection: $status, options: statuses)
                        }
                    }

                    formSection("Contact") {
                        formField("Primary Email", text: $primaryEmail, keyboard: .emailAddress)
                        formField("Billing Email", text: $billingEmail, keyboard: .emailAddress)
                        formField("Phone", text: $phone, keyboard: .phonePad)
                        formField("Website", text: $website, keyboard: .URL)
                    }

                    formSection("Address") {
                        formField("Address Line 1", text: $addressLine1)
                        formField("City", text: $addressCity)
                        formField("State / Region", text: $addressState)
                        formField("ZIP / Postal Code", text: $addressZip)
                        pickerField("Country", selection: $addressCountry, options: countryOptions)
                    }

                    formSection("Tax & Registration") {
                        formField("Tax Number", text: $taxNumber)
                        formField("Registration Number", text: $registrationNumber)
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text(isEditing ? "Update Employer" : "Create Employer").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(name.isEmpty || primaryEmail.isEmpty || isSaving)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Employer" : "New Employer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        guard let emp = employer else { return }
        name = emp.name ?? ""
        legalName = emp.legal_name ?? ""
        primaryEmail = emp.primary_email ?? ""
        billingEmail = emp.billing_email ?? ""
        phone = emp.phone ?? ""
        website = emp.website ?? ""
        industry = emp.industry ?? ""
        taxNumber = emp.tax_number ?? ""
        registrationNumber = emp.registration_number ?? ""
        addressLine1 = emp.address_line1 ?? ""
        addressCity = emp.address_city ?? ""
        addressState = emp.address_state ?? ""
        addressZip = emp.address_zip ?? ""
        addressCountry = emp.address_country ?? ""
        status = emp.status ?? "active"
    }

    private func save() async {
        isSaving = true
        error = nil

        var body: [String: Any] = [
            "name": name,
            "primary_email": primaryEmail
        ]
        if !legalName.isEmpty { body["legal_name"] = legalName }
        if !billingEmail.isEmpty { body["billing_email"] = billingEmail }
        if !phone.isEmpty { body["phone"] = phone }
        if !website.isEmpty { body["website"] = website }
        if !industry.isEmpty { body["industry"] = industry }
        if !taxNumber.isEmpty { body["tax_number"] = taxNumber }
        if !registrationNumber.isEmpty { body["registration_number"] = registrationNumber }
        if !addressLine1.isEmpty { body["address_line1"] = addressLine1 }
        if !addressCity.isEmpty { body["address_city"] = addressCity }
        if !addressState.isEmpty { body["address_state"] = addressState }
        if !addressZip.isEmpty { body["address_zip"] = addressZip }
        if !addressCountry.isEmpty { body["address_country"] = addressCountry }

        if isEditing {
            body["status"] = status
            if let emp = employer {
                let success = await detailVM.update(id: emp.id, body: body)
                if success {
                    onSave()
                    dismiss()
                } else {
                    error = detailVM.error
                }
            }
        } else {
            let success = await listVM.create(body: body)
            if success {
                onSave()
                dismiss()
            } else {
                error = listVM.error
            }
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

    private func formField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            TextField("", text: text)
                .keyboardType(keyboard)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(keyboard == .emailAddress || keyboard == .URL ? .never : .words)
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(8)
        }
    }

    private func pickerField(_ label: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            Picker(label, selection: selection) {
                ForEach(options, id: \.self) { opt in
                    Text(opt.replacingOccurrences(of: "_", with: " ").capitalized).tag(opt)
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
