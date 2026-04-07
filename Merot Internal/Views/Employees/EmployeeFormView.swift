import SwiftUI

struct EmployeeFormView: View {
    let employee: EmployeeFullJSON?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @StateObject private var detailVM = EmployeeDetailViewModel()
    @StateObject private var listVM = EmployeesViewModel()

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var department = ""
    @State private var title = ""
    @State private var employeeType = "full_time"
    @State private var status = "active"
    @State private var country = "MK"
    @State private var city = ""
    @State private var address = ""
    @State private var personalIdNumber = ""
    @State private var isSaving = false
    @State private var error: String?

    let employeeTypes = ["full_time", "part_time", "contractor", "intern"]
    let statuses = ["active", "terminated", "suspended"]
    let countries = ["MK", "XK", "US", "AL", "DE", "Other"]
    let departments = ["Engineering", "Design", "Marketing", "Sales", "Operations", "Finance", "HR", "Legal", "Support", "Other"]

    var isEditing: Bool { employee != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error {
                        ErrorBanner(message: error)
                    }

                    formSection("Basic Information") {
                        formField("First Name", text: $firstName)
                        formField("Last Name", text: $lastName)
                        formField("Email", text: $email, keyboard: .emailAddress)
                        formField("Phone", text: $phone, keyboard: .phonePad)
                    }

                    formSection("Employment") {
                        pickerField("Department", selection: $department, options: departments)
                        formField("Title / Position", text: $title)
                        pickerField("Employee Type", selection: $employeeType, options: employeeTypes)
                        if isEditing {
                            pickerField("Status", selection: $status, options: statuses)
                        }
                    }

                    formSection("Location") {
                        pickerField("Country", selection: $country, options: countries)
                        formField("City", text: $city)
                        formField("Address", text: $address)
                    }

                    if isEditing {
                        formSection("Personal") {
                            formField("Personal ID Number", text: $personalIdNumber)
                        }
                    }

                    // Save button
                    Button {
                        Task { await save() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text(isEditing ? "Update Employee" : "Create Employee").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty || isSaving)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Employee" : "New Employee")
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
        guard let emp = employee else { return }
        firstName = emp.first_name ?? ""
        lastName = emp.last_name ?? ""
        email = emp.email ?? ""
        phone = emp.phone_number ?? ""
        department = emp.department ?? ""
        title = emp.title ?? ""
        employeeType = emp.employee_type ?? "full_time"
        status = emp.status ?? "active"
        country = emp.country ?? "MK"
        city = emp.city ?? ""
        address = emp.address ?? ""
        personalIdNumber = emp.personal_id_number ?? ""
    }

    private func save() async {
        isSaving = true
        error = nil

        var body: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "employee_type": employeeType
        ]
        if !phone.isEmpty { body["phone_number"] = phone }
        if !department.isEmpty { body["department"] = department }
        if !title.isEmpty { body["title"] = title }
        if !country.isEmpty { body["country"] = country }
        if !city.isEmpty { body["city"] = city }
        if !address.isEmpty { body["address"] = address }

        if isEditing {
            body["status"] = status
            if !personalIdNumber.isEmpty { body["personal_id_number"] = personalIdNumber }
            if let emp = employee {
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
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
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
