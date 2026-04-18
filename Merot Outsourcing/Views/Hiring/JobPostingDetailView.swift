import SwiftUI

struct JobPostingDetailView: View {
    let postingId: Int
    @StateObject private var vm = JobPostingDetailViewModel()

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.posting == nil {
                LoadingView()
            } else if let posting = vm.posting {
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
                            Text(posting.title ?? "Untitled")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            if let emp = posting.employer?.name {
                                Text(emp)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            StatusBadge(status: posting.status ?? "draft")
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Details
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Details").font(.headline).foregroundColor(.white.opacity(0.7))
                            if let dept = posting.department { InfoRow(icon: "building.2", label: "Department", value: dept) }
                            if let loc = posting.location { InfoRow(icon: "mappin.circle", label: "Location", value: loc) }
                            if let type = posting.employment_type { InfoRow(icon: "briefcase", label: "Type", value: type.replacingOccurrences(of: "_", with: " ").capitalized) }
                            if let level = posting.experience_level { InfoRow(icon: "chart.bar", label: "Level", value: level.capitalized) }
                            if let min = posting.salary_min?.value, let max = posting.salary_max?.value, min > 0 {
                                InfoRow(icon: "dollarsign.circle", label: "Salary Range", value: "\(formatMoney(min)) - \(formatMoney(max)) \(posting.salary_currency ?? "")")
                            }
                            InfoRow(icon: "person.3", label: "Positions", value: "\(posting.positions_filled ?? 0)/\(posting.positions_available ?? 0)")
                            InfoRow(icon: "doc.text", label: "Applications", value: "\(posting.applications_count ?? 0)")
                        }
                    }

                    // Actions
                    actionsSection(posting)

                    // Description
                    if let desc = posting.description, !desc.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Description").font(.headline).foregroundColor(.white.opacity(0.7))
                                Text(desc).font(.caption).foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    // Requirements
                    if let req = posting.requirements, !req.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Requirements").font(.headline).foregroundColor(.white.opacity(0.7))
                                Text(req).font(.caption).foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    // Applications
                    if !vm.applications.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Applications (\(vm.applications.count))").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(vm.applications) { app in
                                    NavigationLink(destination: JobApplicationDetailView(applicationId: app.id)) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(app.full_name ?? "Unknown")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Text(app.email ?? "")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.4))
                                            }
                                            Spacer()
                                            StatusBadge(status: app.status ?? "new")
                                        }
                                    }
                                    if app.id != vm.applications.last?.id {
                                        Divider().background(Color.white.opacity(0.08))
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
        .navigationTitle("Job Posting")
        .brandNavBar()
        .refreshable { await vm.load(id: postingId) }
        .task { await vm.load(id: postingId) }
    }

    @ViewBuilder
    private func actionsSection(_ posting: JobPosting) -> some View {
        let status = posting.status ?? ""
        if status == "draft" || status == "published" {
            CardView {
                VStack(spacing: 10) {
                    Text("Actions").font(.headline).foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity, alignment: .leading)
                    if status == "draft" {
                        actionBtn("Publish", icon: "arrow.up.circle.fill", color: .green) {
                            Task { await vm.publish(id: postingId) }
                        }
                    }
                    if status == "published" {
                        actionBtn("Close", icon: "xmark.circle.fill", color: .orange) {
                            Task { await vm.close(id: postingId) }
                        }
                    }
                    actionBtn("Archive", icon: "archivebox.fill", color: .gray) {
                        Task { await vm.archive(id: postingId) }
                    }
                }
            }
        }
    }

    private func actionBtn(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
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
