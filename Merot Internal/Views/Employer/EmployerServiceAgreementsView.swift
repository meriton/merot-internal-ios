import SwiftUI

struct EmployerServiceAgreementsView: View {
    @State private var agreements: [EmployerServiceAgreement] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        List {
            if let error {
                ErrorBanner(message: error)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            if agreements.isEmpty && !isLoading {
                EmptyStateView(icon: "signature", title: "No service agreements")
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            ForEach(agreements) { agreement in
                NavigationLink(value: agreement.id) {
                    agreementRow(agreement)
                }
                .listRowBackground(Color.white.opacity(0.06))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Service Agreements")
        .brandNavBar()
        .refreshable { await loadAgreements() }
        .task { await loadAgreements() }
        .navigationDestination(for: Int.self) { id in
            EmployerServiceAgreementDetailView(agreementId: id)
        }
        .overlay {
            if isLoading && agreements.isEmpty {
                LoadingView()
            }
        }
    }

    private func agreementRow(_ agreement: EmployerServiceAgreement) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Service Agreement #\(agreement.id)")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                StatusBadge(status: agreement.contract_status ?? "active")
            }
            HStack(spacing: 12) {
                if let eff = agreement.effective_date {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar").font(.caption2).foregroundColor(.white.opacity(0.3))
                        Text(formatDate(eff))
                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                    }
                }
                if let exp = agreement.expiration_date {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.exclamationmark").font(.caption2).foregroundColor(.white.opacity(0.3))
                        Text(formatDate(exp))
                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            if let sig = agreement.signature_status {
                HStack(spacing: 4) {
                    Image(systemName: sig == "completed" ? "checkmark.seal.fill" : "clock")
                        .font(.caption2)
                        .foregroundColor(sig == "completed" ? .green : .yellow)
                    Text("Signature: \(sig.capitalized)")
                        .font(.caption2).foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func loadAgreements() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerServiceAgreementsResponse = try await APIService.shared.request("GET", "/employers/service_agreements", query: ["per_page": "50"])
            agreements = res.data?.service_agreements ?? []
        } catch {
            self.error = "Failed to load service agreements"
            #if DEBUG
            print("[EmployerAgreements] \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Service Agreement Detail

struct EmployerServiceAgreementDetailView: View {
    let agreementId: Int
    @State private var agreement: EmployerServiceAgreementFull?
    @State private var addendums: [EmployerAgreementAddendum] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ScrollView {
            if isLoading && agreement == nil {
                LoadingView()
            } else if let error {
                VStack(spacing: 16) {
                    ErrorBanner(message: error)
                    Button("Retry") { Task { await load() } }
                        .foregroundColor(.accent)
                }
                .padding(.top, 40)
            } else if let ag = agreement {
                VStack(spacing: 12) {
                    // Header
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Service Agreement #\(ag.id)")
                                    .font(.title3).bold().foregroundColor(.white)
                                Spacer()
                                StatusBadge(status: ag.contract_status ?? "active")
                            }
                        }
                    }

                    // Details
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Agreement Details").font(.headline).foregroundColor(.white.opacity(0.7))
                            if let eff = ag.effective_date {
                                InfoRow(icon: "calendar", label: "Effective Date", value: formatDate(eff))
                            }
                            if let exp = ag.expiration_date {
                                InfoRow(icon: "calendar.badge.exclamationmark", label: "Expiration Date", value: formatDate(exp))
                            }
                            if let sig = ag.signature_status {
                                InfoRow(icon: "signature", label: "Signature Status", value: sig.capitalized)
                            }
                            if let count = ag.addendums_count {
                                InfoRow(icon: "doc.on.doc", label: "Addendums", value: "\(count)")
                            }
                            InfoRow(icon: "clock", label: "Created", value: formatDate(ag.created_at))
                        }
                    }

                    // Addendums
                    if !addendums.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Addendums").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(addendums) { addendum in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Addendum #\(addendum.addendum_number ?? 0)")
                                                .font(.subheadline).foregroundColor(.white)
                                            Spacer()
                                            Text(formatDate(addendum.created_at))
                                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                                        }
                                        if let emp = addendum.employee {
                                            HStack(spacing: 4) {
                                                Image(systemName: "person.fill")
                                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                                                Text(emp.full_name ?? "-")
                                                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                                            }
                                        }
                                        if let eff = addendum.effective_date {
                                            HStack(spacing: 4) {
                                                Image(systemName: "calendar")
                                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                                                Text("Effective: \(formatDate(eff))")
                                                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    if addendum.id != addendums.last?.id {
                                        Divider().overlay(Color.white.opacity(0.1))
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
        .navigationTitle("Agreement")
        .brandNavBar()
        .refreshable { await load() }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerServiceAgreementDetailResponse = try await APIService.shared.request("GET", "/employers/service_agreements/\(agreementId)")
            agreement = res.data?.service_agreement
            addendums = res.data?.addendums ?? []
        } catch {
            self.error = "Failed to load agreement details"
            #if DEBUG
            print("[EmployerAgreementDetail] \(error)")
            #endif
        }
        isLoading = false
    }
}
