import SwiftUI

struct EmployeeAgreementDetailView: View {
    let agreementId: Int
    @StateObject private var vm = EmployeeAgreementDetailViewModel()
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var confirmAction: String?

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.agreement == nil {
                LoadingView()
            } else if let agreement = vm.agreement {
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
                            Text(agreement.employee_name ?? "Unknown Employee")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            Text("Employee Agreement #\(agreement.id)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                            HStack(spacing: 8) {
                                StatusBadge(status: agreement.status ?? "unknown")
                                StatusBadge(status: agreement.signature_status ?? "unknown")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Contract Details
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contract Details").font(.headline).foregroundColor(.white.opacity(0.7))
                            if let type = agreement.contract_type_display ?? agreement.contract_type {
                                InfoRow(icon: "doc.text", label: "Contract Type", value: type)
                            }
                            if let empType = agreement.employment_type_display ?? agreement.employment_type {
                                InfoRow(icon: "briefcase", label: "Employment Type", value: empType)
                            }
                            if let country = agreement.country_display ?? agreement.country {
                                InfoRow(icon: "globe", label: "Country", value: country)
                            }
                            if let entity = agreement.legal_entity_display ?? agreement.legal_entity {
                                InfoRow(icon: "building.2", label: "Legal Entity", value: entity)
                            }
                            if let position = agreement.job_position {
                                InfoRow(icon: "person.fill", label: "Position", value: position)
                            }
                            if let comp = agreement.compensation_type {
                                InfoRow(icon: "banknote", label: "Compensation Type", value: comp.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                        }
                    }

                    // Dates & Terms
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Dates & Terms").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "calendar", label: "Effective Date", value: formatDate(agreement.effective_date))
                            InfoRow(icon: "calendar.badge.plus", label: "Start Date", value: formatDate(agreement.start_date))
                            if let end = agreement.end_date {
                                InfoRow(icon: "calendar.badge.minus", label: "End Date", value: formatDate(end))
                            }
                            if let months = agreement.term_months {
                                InfoRow(icon: "clock", label: "Term", value: "\(months) months")
                            }
                            InfoRow(icon: "arrow.triangle.2.circlepath", label: "Auto Renewal", value: agreement.auto_renewal == true ? "Yes" : "No")
                            if agreement.is_trial == true {
                                InfoRow(icon: "exclamationmark.triangle", label: "Trial Period", value: "Yes")
                            }
                        }
                    }

                    // Compensation
                    if let comp = agreement.net_compensation, comp > 0 {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Compensation").font(.headline).foregroundColor(.white.opacity(0.7))
                                HStack {
                                    Text("Net Compensation")
                                        .font(.subheadline).foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                    Text(formatMoney(comp, currency: agreement.currency))
                                        .font(.title3).bold().foregroundColor(.accent)
                                }
                            }
                        }
                    }

                    // Signature Status
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Signature").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "signature", label: "Status", value: (agreement.signature_status ?? "unknown").replacingOccurrences(of: "_", with: " ").capitalized)
                            InfoRow(icon: "doc.richtext", label: "Signed Document", value: agreement.has_signed_document == true ? "Available" : "Not available")
                        }
                    }

                    // Actions
                    actionsCard(agreement)

                    // Addendums
                    if !vm.addendums.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Addendums (\(vm.addendums.count))").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(vm.addendums) { addendum in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(addendum.addendum_type?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Addendum")
                                                .font(.subheadline).foregroundColor(.white)
                                            if let desc = addendum.description {
                                                Text(desc)
                                                    .font(.caption).foregroundColor(.white.opacity(0.5))
                                                    .lineLimit(2)
                                            }
                                            Text("Effective: \(formatDate(addendum.effective_date))")
                                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                                        }
                                        Spacer()
                                        StatusBadge(status: addendum.status ?? "unknown")
                                    }
                                    if addendum.id != vm.addendums.last?.id {
                                        Divider().background(Color.white.opacity(0.08))
                                    }
                                }
                            }
                        }
                    }

                    InfoRow(icon: "calendar", label: "Created", value: formatDate(agreement.created_at))
                        .padding(.horizontal, 4)
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Agreement")
        .brandNavBar()
        .refreshable { await vm.load(id: agreementId) }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL { ShareSheet(items: [url]) }
        }
        .alert("Confirm", isPresented: Binding(
            get: { confirmAction != nil },
            set: { if !$0 { confirmAction = nil } }
        )) {
            Button("Cancel", role: .cancel) { confirmAction = nil }
            Button("Confirm") {
                if let action = confirmAction {
                    Task {
                        switch action {
                        case "send_signature":
                            await vm.sendForSignature(id: agreementId)
                        case "sync_docusign":
                            await vm.syncDocusign(id: agreementId)
                        default: break
                        }
                    }
                }
                confirmAction = nil
            }
        } message: {
            Text(confirmAction == "send_signature" ? "Send this agreement for DocuSign signature?" : "Sync DocuSign status for this agreement?")
        }
        .task { await vm.load(id: agreementId) }
    }

    // MARK: - Actions

    private func actionsCard(_ agreement: EmployeeAgreement) -> some View {
        CardView {
            VStack(spacing: 10) {
                Text("Actions").font(.headline).foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity, alignment: .leading)

                actionButton("Download PDF", icon: "arrow.down.doc.fill", color: .indigo) {
                    Task {
                        if let url = await vm.downloadPDF(id: agreementId) {
                            pdfURL = url
                            showShareSheet = true
                        }
                    }
                }

                if agreement.has_signed_document == true {
                    actionButton("Download Signed", icon: "checkmark.seal.fill", color: .green) {
                        Task {
                            if let url = await vm.downloadSigned(id: agreementId) {
                                pdfURL = url
                                showShareSheet = true
                            }
                        }
                    }
                }

                let sigStatus = agreement.signature_status ?? ""
                if sigStatus == "draft" || sigStatus == "" {
                    actionButton("Send for Signature", icon: "paperplane.fill", color: .blue) {
                        confirmAction = "send_signature"
                    }
                }

                actionButton("Sync DocuSign", icon: "arrow.triangle.2.circlepath", color: .orange) {
                    confirmAction = "sync_docusign"
                }
            }
        }
    }

    private func actionButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if vm.isActioning { ProgressView().tint(.white) }
                else { Image(systemName: icon); Text(label) }
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
}
