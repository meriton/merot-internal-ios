import SwiftUI

struct TimeOffFormView: View {
    let existingRequest: TimeOffRequest?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = TimeOffViewModel()
    @StateObject private var employeesVM = EmployeesViewModel()

    @State private var selectedEmployeeId: Int?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var leaveType = "annual_leave"
    @State private var notes = ""
    @State private var isSaving = false
    @State private var error: String?

    let leaveTypes = ["annual_leave", "sick_leave", "personal_leave", "unpaid_leave", "maternity_leave", "paternity_leave", "bereavement_leave", "other"]

    var isEditing: Bool { existingRequest != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error {
                        ErrorBanner(message: error)
                    }

                    if !isEditing {
                        formSection("Employee") {
                            if employeesVM.employees.isEmpty && employeesVM.isLoading {
                                Text("Loading employees...")
                                    .font(.caption).foregroundColor(.white.opacity(0.4))
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Select Employee").font(.caption).foregroundColor(.white.opacity(0.5))
                                    Picker("Employee", selection: $selectedEmployeeId) {
                                        Text("Select...").tag(nil as Int?)
                                        ForEach(employeesVM.employees) { emp in
                                            Text(emp.displayName).tag(emp.id as Int?)
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
                    }

                    formSection("Details") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Leave Type").font(.caption).foregroundColor(.white.opacity(0.5))
                            Picker("Leave Type", selection: $leaveType) {
                                ForEach(leaveTypes, id: \.self) { type in
                                    Text(type.replacingOccurrences(of: "_", with: " ").capitalized).tag(type)
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

                    formSection("Dates") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Date").font(.caption).foregroundColor(.white.opacity(0.5))
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("End Date").font(.caption).foregroundColor(.white.opacity(0.5))
                            DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                    }

                    formSection("Notes") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes (optional)").font(.caption).foregroundColor(.white.opacity(0.5))
                            TextField("", text: $notes, axis: .vertical)
                                .lineLimit(2...4)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(8)
                        }
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text(isEditing ? "Update Request" : "Create Request").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled((!isEditing && selectedEmployeeId == nil) || isSaving)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Time Off" : "New Time Off")
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
                if !isEditing {
                    await employeesVM.load()
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        guard let req = existingRequest else { return }
        if let empId = req.employee?.id { selectedEmployeeId = empId }
        leaveType = req.time_off_record?.leave_type ?? "annual_leave"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let sd = req.start_date, let d = dateFormatter.date(from: String(sd.prefix(10))) { startDate = d }
        if let ed = req.end_date, let d = dateFormatter.date(from: String(ed.prefix(10))) { endDate = d }
    }

    private func save() async {
        isSaving = true
        error = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var body: [String: Any] = [
            "start_date": dateFormatter.string(from: startDate),
            "end_date": dateFormatter.string(from: endDate),
            "leave_type": leaveType
        ]
        if !notes.isEmpty { body["notes"] = notes }
        if let empId = selectedEmployeeId { body["employee_user_id"] = empId }

        if isEditing, let req = existingRequest {
            let success = await vm.update(id: req.id, body: body)
            if success {
                onSave()
                dismiss()
            } else {
                error = vm.error
            }
        } else {
            let success = await vm.create(body: body)
            if success {
                onSave()
                dismiss()
            } else {
                error = vm.error
            }
        }
        isSaving = false
    }

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
}
