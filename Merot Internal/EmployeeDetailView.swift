import SwiftUI

struct EmployeeDetailView: View {
    let employee: Employee
    @StateObject private var apiService = APIService()
    @State private var detailedEmployee: Employee?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let displayEmployee = detailedEmployee ?? Optional(employee) {
                        // Header Section
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.merotBlue.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(displayEmployee.fullName.prefix(2).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.merotBlue)
                                )
                            
                            VStack(spacing: 8) {
                                Text(displayEmployee.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(displayEmployee.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                StatusBadge(status: displayEmployee.status)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        
                        // Basic Information
                        InfoSection(title: "Basic Information") {
                            if let employeeId = displayEmployee.employeeId {
                                InfoRow(label: "Employee ID", value: employeeId)
                            }
                            
                            if let department = displayEmployee.department {
                                InfoRow(label: "Department", value: department)
                            }
                            
                            if let title = displayEmployee.title {
                                InfoRow(label: "Title", value: title)
                            }
                            
                            if let location = displayEmployee.location {
                                InfoRow(label: "Location", value: location)
                            }
                            
                            if let phone = displayEmployee.phoneNumber {
                                InfoRow(label: "Phone", value: phone)
                            }
                            
                            if let country = displayEmployee.country {
                                InfoRow(label: "Country", value: country.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                        }
                        
                        // Employment Information
                        if let employment = displayEmployee.employment {
                            InfoSection(title: "Employment Details") {
                                if let position = employment.employmentPosition {
                                    InfoRow(label: "Position", value: position)
                                }
                                
                                if let startDate = employment.startDate {
                                    InfoRow(label: "Start Date", value: DateFormatter.displayDate.string(from: startDate))
                                }
                                
                                if let endDate = employment.endDate {
                                    InfoRow(label: "End Date", value: DateFormatter.displayDate.string(from: endDate))
                                }
                                
                                if let status = employment.employmentStatus {
                                    InfoRow(label: "Employment Status", value: status.capitalized)
                                }
                                
                                if let grossSalary = employment.grossSalary {
                                    InfoRow(label: "Gross Salary", value: "$\(Int(grossSalary))")
                                }
                                
                                // Employment Fee from salary detail merot_fee
                                if let salaryDetail = displayEmployee.salaryDetail,
                                   let merotFee = salaryDetail.merotFee {
                                    InfoRow(label: "Employment Fee", value: "$\(Int(merotFee))")
                                }
                            }
                        }
                        
                        // Salary Details
                        if let salaryDetail = displayEmployee.salaryDetail {
                            InfoSection(title: "Salary Details") {
                                if let baseSalary = salaryDetail.baseSalary {
                                    InfoRow(label: "Base Salary", value: "$\(Int(baseSalary))")
                                }
                                
                                if let grossSalary = salaryDetail.grossSalary {
                                    InfoRow(label: "Gross Salary", value: "$\(Int(grossSalary))")
                                }
                                
                                if let netSalary = salaryDetail.netSalary {
                                    InfoRow(label: "Net Salary", value: "$\(Int(netSalary))")
                                }
                                
                                if let seniority = salaryDetail.seniority {
                                    InfoRow(label: "Seniority", value: String(format: "%.1f years", seniority))
                                }
                                
                                if let onMaternity = salaryDetail.onMaternity {
                                    InfoRow(label: "On Maternity", value: onMaternity ? "Yes" : "No")
                                }
                                
                                if let bankName = salaryDetail.bankName {
                                    InfoRow(label: "Bank", value: bankName)
                                }
                                
                                if let bankAccount = salaryDetail.bankAccountNumber {
                                    InfoRow(label: "Bank Account", value: "***\(bankAccount.suffix(4))")
                                }
                            }
                        }
                        
                        // Join Date
                        InfoSection(title: "Account Information") {
                            InfoRow(label: "Joined", value: DateFormatter.displayDate.string(from: displayEmployee.createdAt))
                        }
                        
                    } else if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage) {
                            Task {
                                await loadEmployeeDetails()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Employee Details")
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
            // Always start with the basic employee data immediately
            detailedEmployee = employee
            
            // Then load detailed data in the background
            Task {
                await loadEmployeeDetails()
            }
        }
    }
    
    private func loadEmployeeDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            detailedEmployee = try await apiService.getEmployee(id: employee.id)
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to the basic employee data if detailed fetch fails
            detailedEmployee = employee
        }
        
        isLoading = false
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}


extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}