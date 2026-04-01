import SwiftUI

struct HiringView: View {
    @StateObject private var apiService = APIService()
    @State private var jobPostings: [JobPosting] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedJobPosting: JobPosting?
    
    var filteredJobPostings: [JobPosting] {
        if searchText.isEmpty {
            return jobPostings
        } else {
            return jobPostings.filter { jobPosting in
                jobPosting.title.localizedCaseInsensitiveContains(searchText) ||
                jobPosting.description?.localizedCaseInsensitiveContains(searchText) == true ||
                jobPosting.department?.localizedCaseInsensitiveContains(searchText) ?? false ||
                jobPosting.location?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search job postings", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading job postings...")
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await loadJobPostings()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else if filteredJobPostings.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No job postings found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                } else {
                    List(filteredJobPostings) { jobPosting in
                        JobPostingRow(jobPosting: jobPosting) {
                            selectedJobPosting = jobPosting
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Hiring")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadJobPostings()
            }
        }
        .onAppear {
            Task {
                await loadJobPostings()
            }
        }
        .sheet(item: $selectedJobPosting) { jobPosting in
            JobPostingDetailView(jobPosting: jobPosting)
        }
    }
    
    private func loadJobPostings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getJobPostings()
            jobPostings = response.jobPostings
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct JobPostingRow: View {
    let jobPosting: JobPosting
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(jobPosting.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(jobPosting.employer.name ?? "Unknown Company")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if let applicationsCount = jobPosting.applicationsCount {
                            Text("\(applicationsCount) applicants")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(jobPosting.positionsFilled)/\(jobPosting.positionsAvailable) filled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    if let department = jobPosting.department {
                        Label(department, systemImage: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let location = jobPosting.location {
                        Label(location, systemImage: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let employmentType = jobPosting.employmentType {
                        Label(employmentType.replacingOccurrences(of: "_", with: " ").capitalized, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if let salaryMin = jobPosting.salaryMin, let salaryMax = jobPosting.salaryMax {
                    HStack {
                        let period = jobPosting.salaryPeriod ?? "yearly"
                        Text("$\(Int(salaryMin))K - $\(Int(salaryMax/1000))K \(period)")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    HiringView()
}