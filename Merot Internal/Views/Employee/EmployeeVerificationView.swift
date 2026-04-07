import SwiftUI

struct EmployeeVerificationView: View {
    @State private var requests: [EmpVerificationRequest] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var showCreateSheet = false
    @State private var showShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        NavigationStack {
            List {
                if let error {
                    ErrorBanner(message: error).listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                if requests.isEmpty && !isLoading {
                    EmptyStateView(icon: "doc.text.magnifyingglass", title: "No verification requests", subtitle: "Tap + to request an employment verification letter")
                        .listRowBackground(Color.clear).listRowSeparator(.hidden)
                }
                ForEach(requests) { r in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatReason(r.reason))
                                .font(.subheadline).foregroundColor(.white)
                            if let detail = r.purpose_detail, !detail.isEmpty {
                                Text(detail)
                                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    .lineLimit(2)
                            }
                            Text(formatDate(r.created_at))
                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            StatusBadge(status: r.status ?? "pending")
                            if r.status == "issued" {
                                Button {
                                    Task { await downloadPDF(id: r.id) }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.doc")
                                        Text("PDF")
                                    }
                                    .font(.caption2).bold()
                                    .foregroundColor(.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accent.opacity(0.15))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.white.opacity(0.06))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Verification")
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
                CreateVerificationSheet(isPresented: $showCreateSheet) {
                    Task { await load() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = pdfData {
                    ShareSheet(items: [data])
                }
            }
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmpVerificationListResponse = try await APIService.shared.request("GET", "/employees/employment_verification_requests")
            requests = res.data?.requests ?? []
        } catch {
            self.error = "Failed to load requests"
            #if DEBUG
            print("[EmpVerification] \(error)")
            #endif
        }
        isLoading = false
    }

    private func downloadPDF(id: Int) async {
        do {
            let data = try await APIService.shared.requestData("GET", "/employees/employment_verification_requests/\(id)/pdf")
            pdfData = data
            showShareSheet = true
        } catch {
            self.error = "Failed to download PDF"
            #if DEBUG
            print("[EmpVerificationPDF] \(error)")
            #endif
        }
    }

    private func formatReason(_ reason: String?) -> String {
        guard let r = reason else { return "Verification Request" }
        return r.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Create Verification Sheet

struct CreateVerificationSheet: View {
    @Binding var isPresented: Bool
    var onCreated: () -> Void

    private let reasons = [
        ("bank_loan", "Bank Loan"),
        ("visa", "Visa Application"),
        ("rental", "Rental Application"),
        ("government", "Government"),
        ("insurance", "Insurance"),
        ("education", "Education"),
        ("other", "Other")
    ]

    private let languages = [
        ("native", "Native Language"),
        ("english", "English"),
        ("both", "Both Languages")
    ]

    @State private var selectedReason = "bank_loan"
    @State private var selectedLanguage = "native"
    @State private var purposeDetail = ""
    @State private var isSaving = false
    @State private var error: String?
    @State private var success = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Reason picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reason").font(.caption).foregroundColor(.white.opacity(0.5))
                        VStack(spacing: 0) {
                            ForEach(reasons, id: \.0) { value, label in
                                Button {
                                    selectedReason = value
                                } label: {
                                    HStack {
                                        Text(label)
                                            .font(.subheadline).foregroundColor(.white)
                                        Spacer()
                                        if selectedReason == value {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accent)
                                        }
                                    }
                                    .padding(12)
                                    .background(selectedReason == value ? Color.accent.opacity(0.1) : Color.white.opacity(0.04))
                                }
                                if value != reasons.last?.0 {
                                    Divider().background(Color.white.opacity(0.06))
                                }
                            }
                        }
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    }

                    // Language picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Language").font(.caption).foregroundColor(.white.opacity(0.5))
                        Picker("", selection: $selectedLanguage) {
                            ForEach(languages, id: \.0) { value, label in
                                Text(label).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Purpose detail
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Additional Details (optional)").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextEditor(text: $purposeDetail)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(10)
                    }

                    if let err = error {
                        ErrorBanner(message: err)
                    }

                    if success {
                        SuccessBanner(message: "Verification request submitted")
                    }

                    // Submit
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
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isSaving)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Request Verification")
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

    private func submitRequest() async {
        isSaving = true
        error = nil

        var body: [String: Any] = [
            "reason": selectedReason,
            "language": selectedLanguage
        ]
        if !purposeDetail.isEmpty {
            body["purpose_detail"] = purposeDetail
        }

        do {
            let res: EmpVerificationCreateResponse = try await APIService.shared.request("POST", "/employees/employment_verification_requests", body: body)
            if res.success == true {
                success = true
                onCreated()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isPresented = false
            } else {
                error = res.errors?.first ?? res.message ?? "Failed to submit"
            }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to submit request"
            #if DEBUG
            print("[CreateVerification] \(error)")
            #endif
        }
        isSaving = false
    }
}
