import SwiftUI

struct EmployeeTimeOffView: View {
    @State private var requests: [EmpTimeOffReq] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var showCreateSheet = false
    @State private var deleteError: String?

    var body: some View {
        NavigationStack {
            List {
                if let error {
                    ErrorBanner(message: error).listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                if let deleteError {
                    ErrorBanner(message: deleteError).listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                if requests.isEmpty && !isLoading {
                    EmptyStateView(icon: "calendar.badge.clock", title: "No time off requests", subtitle: "Tap + to create a request")
                        .listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                ForEach(requests) { r in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.time_off_record?.name ?? "Time Off")
                                .font(.subheadline).foregroundColor(.white)
                            Text("\(formatDate(r.start_date)) - \(formatDate(r.end_date))")
                                .font(.caption2).foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadge(status: r.approval_status ?? "pending")
                            Text("\(r.days ?? 0) days")
                                .font(.caption2).foregroundColor(.accent)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.white.opacity(0.06))
                }
                .onDelete { indexSet in
                    Task { await deleteRequests(at: indexSet) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Time Off")
            .brandNavBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .refreshable { await load() }
            .task { await load() }
            .sheet(isPresented: $showCreateSheet) {
                CreateTimeOffRequestSheet(isPresented: $showCreateSheet) {
                    Task { await load() }
                }
            }
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        deleteError = nil
        do {
            let res: EmpTimeOffResponse = try await APIService.shared.request("GET", "/employees/time_off_requests")
            requests = res.data?.time_off_requests ?? []
        } catch {
            self.error = "Failed to load time off"
            #if DEBUG
            print("[EmpTimeOff] \(error)")
            #endif
        }
        isLoading = false
    }

    private func deleteRequests(at offsets: IndexSet) async {
        deleteError = nil
        for index in offsets {
            let request = requests[index]
            guard request.approval_status?.lowercased() == "pending" else {
                deleteError = "Only pending requests can be deleted"
                return
            }
            do {
                let _: APIResponse<String> = try await APIService.shared.request("DELETE", "/employees/time_off_requests/\(request.id)")
                requests.remove(at: index)
            } catch {
                deleteError = "Failed to delete request"
                #if DEBUG
                print("[EmpTimeOff] Delete error: \(error)")
                #endif
            }
        }
    }
}

// MARK: - Create Time Off Request Sheet

struct CreateTimeOffRequestSheet: View {
    @Binding var isPresented: Bool
    var onCreated: () -> Void

    @State private var leaveRecords: [EmpTimeOffRecord] = []
    @State private var selectedRecordId: Int?
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400)
    @State private var notes = ""
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var error: String?
    @State private var success = false

    private var dayCount: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(1, days + 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        LoadingView(message: "Loading leave types...")
                    } else {
                        leaveTypePicker
                        datePickersSection
                        durationRow
                        notesSection
                        statusMessages
                        submitButton
                    }
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("New Time Off Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.white)
                }
            }
            .task { await loadLeaveTypes() }
        }
    }

    // MARK: - Sub-views

    private var leaveTypePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Leave Type").font(.caption).foregroundColor(.white.opacity(0.5))
            VStack(spacing: 0) {
                ForEach(leaveRecords) { record in
                    leaveTypeRow(record)
                    if record.id != leaveRecords.last?.id {
                        Divider().background(Color.white.opacity(0.06))
                    }
                }
            }
            .background(Color.white.opacity(0.06))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    private func leaveTypeRow(_ record: EmpTimeOffRecord) -> some View {
        Button {
            selectedRecordId = record.id
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.name ?? "")
                        .font(.subheadline).foregroundColor(.white)
                    Text("Balance: \(record.balance ?? 0)/\(record.total_days ?? 0) days")
                        .font(.caption2).foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                if selectedRecordId == record.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accent)
                }
            }
            .padding(12)
            .background(selectedRecordId == record.id ? Color.accent.opacity(0.1) : Color.white.opacity(0.04))
        }
    }

    private var datePickersSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Start Date").font(.caption).foregroundColor(.white.opacity(0.5))
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.accent)
                    .colorScheme(.dark)
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("End Date").font(.caption).foregroundColor(.white.opacity(0.5))
                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.accent)
                    .colorScheme(.dark)
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
            }
        }
    }

    private var durationRow: some View {
        HStack {
            Text("Duration")
                .font(.caption).foregroundColor(.white.opacity(0.5))
            Spacer()
            Text("\(dayCount) day\(dayCount == 1 ? "" : "s")")
                .font(.subheadline).bold().foregroundColor(.accent)
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(10)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes (optional)").font(.caption).foregroundColor(.white.opacity(0.5))
            TextEditor(text: $notes)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
        }
    }

    @ViewBuilder
    private var statusMessages: some View {
        if let err = error {
            ErrorBanner(message: err)
        }
        if success {
            SuccessBanner(message: "Time off request submitted")
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitRequest() }
        } label: {
            HStack {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Submit Request").fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(selectedRecordId != nil ? Color.brandGreen : Color.brandGreen.opacity(0.4))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isSaving || selectedRecordId == nil)
    }

    // MARK: - Data Loading

    private func loadLeaveTypes() async {
        isLoading = true
        do {
            let res: EmpTimeOffRecordsResponse = try await APIService.shared.request("GET", "/employees/time_off_records")
            leaveRecords = (res.data?.time_off_records ?? []).filter { ($0.balance ?? 0) > 0 }
            if let first = leaveRecords.first {
                selectedRecordId = first.id
            }
        } catch {
            self.error = "Failed to load leave types"
            #if DEBUG
            print("[CreateTimeOff] \(error)")
            #endif
        }
        isLoading = false
    }

    private func submitRequest() async {
        guard let recordId = selectedRecordId else { return }
        isSaving = true
        error = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let body: [String: Any] = [
            "time_off_record_id": recordId,
            "start_date": formatter.string(from: startDate),
            "end_date": formatter.string(from: endDate),
            "notes": notes
        ]

        do {
            let _: APIResponse<String> = try await APIService.shared.request("POST", "/employees/time_off_requests", body: body)
            success = true
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            onCreated()
            isPresented = false
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to submit request"
            #if DEBUG
            print("[CreateTimeOff] \(error)")
            #endif
        }
        isSaving = false
    }
}
