import SwiftUI

struct PersonalInfoRequestsView: View {
    @StateObject private var vm = PersonalInfoViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.statusOptions, id: \.self) { status in
                        filterChip(status.capitalized, isSelected: vm.statusFilter == status) {
                            vm.statusFilter = status
                            Task { await vm.load() }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            ScrollView {
                if let msg = vm.successMessage {
                    SuccessBanner(message: msg)
                }
                if let error = vm.error {
                    ErrorBanner(message: error)
                }

                if vm.requests.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "person.text.rectangle", title: "No personal info requests", subtitle: vm.statusFilter == "submitted" ? "All caught up!" : nil)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.requests) { request in
                            NavigationLink(destination: PersonalInfoDetailView(requestId: request.id)) {
                                requestRow(request)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Personal Info Requests")
        .brandNavBar()
        .refreshable { await vm.load() }
        .task { await vm.load() }
    }

    private func requestRow(_ r: PersonalInfoRequest) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(r.employee?.full_name ?? "Unknown")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                if let email = r.employee?.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
                Text(formatDate(r.created_at))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: r.status ?? "pending")
                if let changes = r.changed_fields, !changes.isEmpty {
                    Text("\(changes.count) changes")
                        .font(.caption2)
                        .foregroundColor(.accent.opacity(0.7))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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

struct PersonalInfoDetailView: View {
    let requestId: Int
    @StateObject private var vm = PersonalInfoDetailViewModel()
    @State private var showRejectSheet = false
    @State private var rejectionComment = ""

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.request == nil {
                LoadingView()
            } else if let req = vm.request {
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
                            Text(req.employee?.full_name ?? "Unknown")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            StatusBadge(status: req.status ?? "pending")
                            Text("Submitted \(formatDate(req.created_at))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Changes diff
                    if let changes = req.changed_fields, !changes.isEmpty,
                       let submitted = req.submitted_data,
                       let current = req.current_data {
                        CardView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Changes").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(changes, id: \.self) { field in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(field.replacingOccurrences(of: "_", with: " ").capitalized)
                                            .font(.caption).bold()
                                            .foregroundColor(.white.opacity(0.6))
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Current")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.red.opacity(0.6))
                                                Text(current[field] ?? "-")
                                                    .font(.caption)
                                                    .foregroundColor(.red.opacity(0.8))
                                                    .padding(6)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color.red.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                            .frame(maxWidth: .infinity)

                                            Image(systemName: "arrow.right")
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.3))
                                                .padding(.horizontal, 4)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("New")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.green.opacity(0.6))
                                                Text(submitted[field] ?? "-")
                                                    .font(.caption)
                                                    .foregroundColor(.green.opacity(0.8))
                                                    .padding(6)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color.green.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                    if field != changes.last {
                                        Divider().background(Color.white.opacity(0.06))
                                    }
                                }
                            }
                        }
                    }

                    // ID Photos
                    if req.has_photo_changes == true {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Updated ID Photos").font(.headline).foregroundColor(.white.opacity(0.7))
                                HStack(spacing: 12) {
                                    if let front = req.id_front_photo_url, let url = URL(string: front) {
                                        VStack {
                                            Text("Front").font(.caption2).foregroundColor(.white.opacity(0.4))
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFit()
                                            } placeholder: {
                                                ProgressView().tint(.white)
                                            }
                                            .frame(maxHeight: 100)
                                            .cornerRadius(6)
                                        }
                                    }
                                    if let back = req.id_back_photo_url, let url = URL(string: back) {
                                        VStack {
                                            Text("Back").font(.caption2).foregroundColor(.white.opacity(0.4))
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFit()
                                            } placeholder: {
                                                ProgressView().tint(.white)
                                            }
                                            .frame(maxHeight: 100)
                                            .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Actions
                    if req.status == "submitted" {
                        CardView {
                            VStack(spacing: 10) {
                                Button {
                                    Task { await vm.approve(id: requestId) }
                                } label: {
                                    HStack {
                                        if vm.isActioning { ProgressView().tint(.white) }
                                        else { Image(systemName: "checkmark.circle.fill"); Text("Approve Changes") }
                                    }
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.brandGreen)
                                    .cornerRadius(10)
                                }
                                .disabled(vm.isActioning)

                                Button { showRejectSheet = true } label: {
                                    HStack { Image(systemName: "xmark.circle.fill"); Text("Reject") }
                                        .font(.subheadline).fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.red.opacity(0.8))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Reviewer info
                    if let reviewer = req.reviewer {
                        CardView {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Reviewed By").font(.headline).foregroundColor(.white.opacity(0.7))
                                Text(reviewer.full_name ?? "Unknown")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                if let at = req.reviewed_at {
                                    Text(formatDate(at))
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Info Request")
        .brandNavBar()
        .refreshable { await vm.load(id: requestId) }
        .sheet(isPresented: $showRejectSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Rejection Comment (optional)")
                        .font(.caption).foregroundColor(.white.opacity(0.5))
                    TextField("", text: $rejectionComment, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                    Button {
                        Task {
                            await vm.reject(id: requestId, comment: rejectionComment.isEmpty ? nil : rejectionComment)
                            showRejectSheet = false
                        }
                    } label: {
                        Text("Reject").fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.brand.ignoresSafeArea())
                .navigationTitle("Reject Request")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.brand, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showRejectSheet = false }.foregroundColor(.white)
                    }
                }
            }
        }
        .task { await vm.load(id: requestId) }
    }
}
