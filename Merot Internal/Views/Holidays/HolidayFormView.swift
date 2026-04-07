import SwiftUI

struct HolidayFormView: View {
    let holiday: Holiday?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = HolidaysViewModel()

    @State private var name = ""
    @State private var date = Date()
    @State private var holidayType = "public"
    @State private var applicableCountry = "MK"
    @State private var isSaving = false
    @State private var error: String?

    let holidayTypes = ["public", "religious", "national", "company", "other"]
    let countries = ["MK", "XK"]

    var isEditing: Bool { holiday != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error {
                        ErrorBanner(message: error)
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Holiday Details")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Name").font(.caption).foregroundColor(.white.opacity(0.5))
                                TextField("Holiday name", text: $name)
                                    .foregroundColor(.white)
                                    .autocorrectionDisabled()
                                    .padding(10)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date").font(.caption).foregroundColor(.white.opacity(0.5))
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Holiday Type").font(.caption).foregroundColor(.white.opacity(0.5))
                                Picker("Type", selection: $holidayType) {
                                    ForEach(holidayTypes, id: \.self) { t in
                                        Text(t.capitalized).tag(t)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.accent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Country").font(.caption).foregroundColor(.white.opacity(0.5))
                                Picker("Country", selection: $applicableCountry) {
                                    ForEach(countries, id: \.self) { c in
                                        Text(c).tag(c)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text(isEditing ? "Update Holiday" : "Create Holiday").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(name.isEmpty || isSaving)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Holiday" : "New Holiday")
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
        guard let h = holiday else { return }
        name = h.name ?? ""
        holidayType = h.holiday_type ?? "public"
        applicableCountry = h.applicable_country ?? "MK"
        if let d = h.dateValue { date = d }
    }

    private func save() async {
        isSaving = true
        error = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let body: [String: Any] = [
            "name": name,
            "date": dateFormatter.string(from: date),
            "holiday_type": holidayType,
            "applicable_country": applicableCountry
        ]

        if isEditing, let h = holiday {
            let success = await vm.update(id: h.id, body: body)
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
}
