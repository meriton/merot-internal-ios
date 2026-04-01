import SwiftUI

struct JobPostingDetailView: View {
    let jobPosting: JobPosting
    @StateObject private var apiService = APIService()
    @State private var detailedJobPosting: JobPosting?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    let displayJobPosting = detailedJobPosting ?? jobPosting
                    
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(displayJobPosting.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(displayJobPosting.employer.name ?? "Unknown Company")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            if let location = displayJobPosting.location {
                                Label(location, systemImage: "location")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let department = displayJobPosting.department {
                                Label(department, systemImage: "building.2")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        if let employmentType = displayJobPosting.employmentType {
                            HStack {
                                Label(employmentType.replacingOccurrences(of: "_", with: " ").capitalized, systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let experienceLevel = displayJobPosting.experienceLevel {
                                    Label(experienceLevel.capitalized, systemImage: "star")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Salary Information
                    if let salaryMin = displayJobPosting.salaryMin, let salaryMax = displayJobPosting.salaryMax {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Salary Range")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            let currency = displayJobPosting.salaryCurrency ?? "USD"
                            let period = displayJobPosting.salaryPeriod ?? "yearly"
                            Text("$\(Int(salaryMin)) - $\(Int(salaryMax)) \(currency) \(period)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    // Position Information
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Position Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Positions Available:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(displayJobPosting.positionsAvailable)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("Filled:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(displayJobPosting.positionsFilled)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        if let applicationsCount = displayJobPosting.applicationsCount {
                            HStack {
                                Text("Total Applications:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(applicationsCount)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                        }
                        
                        if let viewsCount = displayJobPosting.viewsCount {
                            HStack {
                                Text("Views:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(viewsCount)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Job Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(displayJobPosting.description ?? "No description available")
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Requirements
                    if let requirements = displayJobPosting.requirements, !requirements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Requirements")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(requirements)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    // Benefits
                    if let benefits = displayJobPosting.benefits, !benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Benefits")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(benefits)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    // Published Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Posted")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(formatDate(displayJobPosting.publishedAt))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let expiresAt = displayJobPosting.expiresAt {
                            Text("Expires: \(formatDate(expiresAt))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    if let errorMessage = errorMessage {
                        Text("Error loading details: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Job Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadDetailedJobPosting()
            }
        }
    }
    
    private func loadDetailedJobPosting() async {
        isLoading = true
        errorMessage = nil
        
        do {
            detailedJobPosting = try await apiService.getJobPosting(id: jobPosting.id)
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to basic job posting data
            detailedJobPosting = jobPosting
        }
        
        isLoading = false
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    JobPostingDetailView(jobPosting: JobPosting(
        id: 1,
        title: "Senior iOS Developer",
        description: "We are looking for an experienced iOS developer to join our team and help build amazing mobile applications.",
        department: "Engineering",
        status: "active",
        location: "San Francisco, CA",
        employmentType: "full_time",
        experienceLevel: "senior",
        salaryMin: 120000,
        salaryMax: 160000,
        salaryCurrency: "USD",
        salaryPeriod: "yearly",
        positionsAvailable: 2,
        positionsFilled: 0,
        applicationsCount: 15,
        viewsCount: 245,
        requirements: "5+ years of iOS development experience, Swift proficiency",
        benefits: "Health insurance, 401k matching, flexible PTO",
        publishedAt: "2024-01-15T10:00:00Z",
        expiresAt: "2024-03-15T10:00:00Z",
        employer: JobPostingEmployer(id: 1, name: "TechCorp Inc"),
        createdAt: Date(),
        updatedAt: Date()
    ))
}