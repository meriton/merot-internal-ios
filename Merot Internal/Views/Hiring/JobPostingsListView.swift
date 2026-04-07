import SwiftUI

struct JobPostingsListContent: View {
    @StateObject private var vm = JobPostingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                TextField("Search postings...", text: $vm.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await vm.load() } }
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            // Status filter
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
                if let error = vm.error {
                    ErrorBanner(message: error)
                }

                if vm.postings.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "briefcase", title: "No job postings")
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.postings) { posting in
                            NavigationLink(destination: JobPostingDetailView(postingId: posting.id)) {
                                postingRow(posting)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task { await vm.load() }
    }

    private func postingRow(_ p: JobPosting) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(p.title ?? "Untitled")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if let emp = p.employer?.name {
                        Text(emp).font(.caption).foregroundColor(.white.opacity(0.5))
                    }
                    if let loc = p.location {
                        Text("- \(loc)").font(.caption).foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: p.status ?? "draft")
                Text("\(p.applications_count ?? 0) apps")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
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
