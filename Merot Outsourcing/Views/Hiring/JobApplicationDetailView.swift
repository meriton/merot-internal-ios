import SwiftUI

struct JobApplicationsListContent: View {
    @StateObject private var vm = JobApplicationsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                TextField("Search applications...", text: $vm.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await vm.load() } }
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.statusOptions, id: \.self) { status in
                        chipButton(status.capitalized, isSelected: vm.statusFilter == status) {
                            vm.statusFilter = status
                            Task { await vm.load() }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            List {
                if let error = vm.error {
                    ErrorBanner(message: error)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                if vm.applications.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "person.crop.rectangle.stack", title: "No applications")
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(vm.applications) { app in
                        NavigationLink(destination: JobApplicationDetailView(applicationId: app.id)) {
                            appRow(app)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .refreshable { await vm.load() }
        }
        .task { await vm.load() }
    }

    private func appRow(_ a: JobApplication) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String((a.first_name ?? "?").prefix(1) + (a.last_name ?? "").prefix(1)).uppercased())
                        .font(.caption).bold()
                        .foregroundColor(.accent)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(a.full_name ?? "Unknown")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                if let posting = a.job_posting {
                    Text(posting.title ?? "")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
                Text(formatDate(a.created_at))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
            }
            Spacer()
            StatusBadge(status: a.status ?? "new")
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func chipButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .brand : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accent : Color.white.opacity(0.08))
                .cornerRadius(16)
        }
    }
}

struct JobApplicationDetailView: View {
    let applicationId: Int
    @StateObject private var vm = JobApplicationDetailViewModel()
    @State private var showStatusPicker = false
    @State private var showInterviewScheduler = false
    @State private var showAddEvent = false
    @State private var resumeURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.application == nil {
                LoadingView()
            } else if let app = vm.application {
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
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Text(String((app.first_name ?? "?").prefix(1) + (app.last_name ?? "").prefix(1)).uppercased())
                                        .font(.title3).bold()
                                        .foregroundColor(.accent)
                                )
                            Text(app.full_name ?? "Unknown")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            StatusBadge(status: app.status ?? "new")
                            if let posting = app.job_posting {
                                Text(posting.title ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                                if let emp = posting.employer_name {
                                    Text(emp)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Contact
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contact").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "envelope.fill", label: "Email", value: app.email ?? "-")
                            InfoRow(icon: "phone.fill", label: "Phone", value: app.phone ?? "-")
                            if let linkedin = app.linkedin_url { InfoRow(icon: "link", label: "LinkedIn", value: linkedin) }
                            if let portfolio = app.portfolio_url { InfoRow(icon: "globe", label: "Portfolio", value: portfolio) }
                            InfoRow(icon: "calendar", label: "Applied", value: formatDate(app.created_at))
                        }
                    }

                    // Actions
                    CardView {
                        VStack(spacing: 10) {
                            Text("Actions").font(.headline).foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity, alignment: .leading)

                            appActionButton("Update Status", icon: "arrow.triangle.2.circlepath", color: .blue) {
                                showStatusPicker = true
                            }

                            appActionButton("Schedule Interview", icon: "calendar.badge.plus", color: .purple) {
                                showInterviewScheduler = true
                            }

                            if app.has_resume == true {
                                appActionButton("Download Resume", icon: "arrow.down.doc.fill", color: .indigo) {
                                    Task {
                                        if let url = await vm.downloadResume(id: applicationId) {
                                            resumeURL = url
                                            showShareSheet = true
                                        }
                                    }
                                }
                            }

                            appActionButton("Add Note / Event", icon: "note.text.badge.plus", color: .teal) {
                                showAddEvent = true
                            }

                            if app.can_be_converted == true {
                                Button {
                                    Task { await vm.convertToEmployee(id: applicationId) }
                                } label: {
                                    HStack {
                                        if vm.isActioning { ProgressView().tint(.white) }
                                        else { Image(systemName: "person.badge.plus"); Text("Convert to Employee") }
                                    }
                                    .font(.subheadline).fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.brandGreen)
                                    .cornerRadius(10)
                                }
                                .disabled(vm.isActioning)
                            }
                        }
                    }

                    // Cover letter
                    if let cover = app.cover_letter, !cover.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Cover Letter").font(.headline).foregroundColor(.white.opacity(0.7))
                                Text(cover).font(.caption).foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    // Events
                    if !vm.events.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Timeline (\(vm.events.count))").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(vm.events) { event in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle()
                                            .fill(eventColor(event.event_type ?? ""))
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 5)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.event_type?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Event")
                                                .font(.subheadline).bold()
                                                .foregroundColor(.white)
                                            if let notes = event.notes, !notes.isEmpty {
                                                Text(notes)
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                            if let by = event.created_by?.full_name {
                                                Text("by \(by)")
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                            Text(formatDate(event.created_at))
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                    }
                                    if event.id != vm.events.last?.id {
                                        Divider().background(Color.white.opacity(0.06))
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
        .navigationTitle("Application")
        .brandNavBar()
        .refreshable { await vm.load(id: applicationId) }
        .sheet(isPresented: $showStatusPicker) { statusPickerSheet }
        .sheet(isPresented: $showInterviewScheduler) { interviewSchedulerSheet }
        .sheet(isPresented: $showAddEvent) { addEventSheet }
        .sheet(isPresented: $showShareSheet) {
            if let url = resumeURL { ShareSheet(items: [url]) }
        }
        .task { await vm.load(id: applicationId) }
    }

    private func eventColor(_ type: String) -> Color {
        switch type {
        case "status_changed": return .blue
        case "interview": return .purple
        case "note": return .gray
        default: return .white.opacity(0.3)
        }
    }

    private func appActionButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack { Image(systemName: icon); Text(label) }
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color.opacity(0.8))
                .cornerRadius(10)
        }
        .disabled(vm.isActioning)
    }

    // MARK: - Add Event Sheet

    private var addEventSheet: some View {
        AddEventSheet(applicationId: applicationId, vm: vm, isPresented: $showAddEvent)
    }

    // MARK: - Status Picker Sheet

    private var statusPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(["screening", "interviewing", "approved", "hired", "rejected"], id: \.self) { status in
                    Button {
                        Task {
                            await vm.updateStatus(id: applicationId, status: status)
                            showStatusPicker = false
                        }
                    } label: {
                        HStack {
                            Text(status.capitalized)
                                .foregroundColor(.white)
                            Spacer()
                            StatusBadge(status: status)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Update Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showStatusPicker = false }.foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Interview Scheduler Sheet

    private var interviewSchedulerSheet: some View {
        InterviewSchedulerSheet(applicationId: applicationId, vm: vm, isPresented: $showInterviewScheduler)
    }
}

struct AddEventSheet: View {
    let applicationId: Int
    @ObservedObject var vm: JobApplicationDetailViewModel
    @Binding var isPresented: Bool
    @State private var eventType = "note"
    @State private var notes = ""

    let eventTypes = ["note", "phone_screen", "email_sent", "reference_check", "background_check", "offer_sent", "other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event Type").font(.caption).foregroundColor(.white.opacity(0.5))
                        Picker("Type", selection: $eventType) {
                            ForEach(eventTypes, id: \.self) { t in
                                Text(t.replacingOccurrences(of: "_", with: " ").capitalized).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.accent)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("Enter notes...", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    Button {
                        Task {
                            await vm.addEvent(id: applicationId, eventType: eventType, notes: notes.isEmpty ? nil : notes)
                            if vm.error == nil { isPresented = false }
                        }
                    } label: {
                        HStack {
                            if vm.isActioning { ProgressView().tint(.white) }
                            else { Text("Add Event").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(vm.isActioning)

                    if let err = vm.error {
                        Text(err).font(.caption).foregroundColor(.red)
                    }
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Add Event")
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

struct InterviewSchedulerSheet: View {
    let applicationId: Int
    @ObservedObject var vm: JobApplicationDetailViewModel
    @Binding var isPresented: Bool
    @State private var date = Date()
    @State private var meetLink = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date & Time").font(.caption).foregroundColor(.white.opacity(0.5))
                        DatePicker("", selection: $date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Meet Link (optional)").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("https://meet.google.com/...", text: $meetLink)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes (optional)").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("", text: $notes, axis: .vertical)
                            .lineLimit(2...4)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    Button {
                        let formatter = ISO8601DateFormatter()
                        let dateStr = formatter.string(from: date)
                        Task {
                            await vm.scheduleInterview(
                                id: applicationId,
                                scheduledAt: dateStr,
                                meetLink: meetLink.isEmpty ? nil : meetLink,
                                notes: notes.isEmpty ? nil : notes
                            )
                            if vm.error == nil { isPresented = false }
                        }
                    } label: {
                        HStack {
                            if vm.isActioning { ProgressView().tint(.white) }
                            else { Text("Schedule Interview").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(vm.isActioning)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Schedule Interview")
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
