import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    private let networkManager = NetworkManager.shared
    private var cachedIsAdmin: Bool?
    private var adminCheckTask: Task<Bool, Error>?
    
    init() {
        // Clear any potentially incorrect cached admin status
        clearAdminCache()
    }
    
    func getDashboard() async throws -> DashboardData {
        let response: APIResponse<DashboardData> = try await networkManager.get(
            endpoint: "/employers/dashboard",
            responseType: APIResponse<DashboardData>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getEmployerProfile() async throws -> Employer {
        let response: APIResponse<UserProfileWrapperForAPI> = try await networkManager.get(
            endpoint: "/employers/profile",
            responseType: APIResponse<UserProfileWrapperForAPI>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        guard let employer = response.data.user.employer else {
            throw NetworkManager.NetworkError.serverError("No employer profile found for this user")
        }
        return employer
    }
    
    func updateEmployerProfile(_ employer: Employer) async throws -> Employer {
        let updateRequest = ["employer": employer]
        
        let response: APIResponse<Employer> = try await networkManager.put(
            endpoint: "/employers/profile",
            body: updateRequest,
            responseType: APIResponse<Employer>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getEmployees(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil,
        search: String? = nil
    ) async throws -> EmployeeListResponse {
        var endpoint = "/employees?page=\(page)&per_page=\(perPage)"
        
        if let status = status {
            endpoint += "&status=\(status)"
        }
        
        if let search = search, !search.isEmpty {
            endpoint += "&search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        let response: APIResponse<EmployeeListData> = try await networkManager.get(
            endpoint: "/employers" + endpoint,
            responseType: APIResponse<EmployeeListData>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return EmployeeListResponse(
            employees: response.data.employees,
            pagination: response.data.pagination
        )
    }
    
    func getEmployee(id: Int) async throws -> Employee {
        let response: APIResponse<AdminEmployeeResponse> = try await networkManager.get(
            endpoint: "/employers/employees/\(id)",
            responseType: APIResponse<AdminEmployeeResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.employee
    }
    
    func updateEmployee(id: Int, employee: Employee) async throws -> Employee {
        let updateRequest = ["employee": employee]
        
        let response: APIResponse<AdminEmployeeResponse> = try await networkManager.put(
            endpoint: "/employers/employees/\(id)",
            body: updateRequest,
            responseType: APIResponse<AdminEmployeeResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.employee
    }
    
    func getTimeOffRequests(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil,
        employeeId: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil
    ) async throws -> [TimeOffRequest] {
        var endpoint = "/time_off_requests?page=\(page)&per_page=\(perPage)"
        
        if let status = status {
            endpoint += "&status=\(status)"
        }
        
        if let employeeId = employeeId {
            endpoint += "&employee_id=\(employeeId)"
        }
        
        if let startDate = startDate {
            endpoint += "&start_date=\(startDate)"
        }
        
        if let endDate = endDate {
            endpoint += "&end_date=\(endDate)"
        }
        
        let response: APIResponse<TimeOffRequestListData> = try await networkManager.get(
            endpoint: "/employers" + endpoint,
            responseType: APIResponse<TimeOffRequestListData>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.timeOffRequests
    }
    
    func getTimeOffRequest(id: Int) async throws -> TimeOffRequest {
        let response: APIResponse<TimeOffRequest> = try await networkManager.get(
            endpoint: "/employers/time_off_requests/\(id)",
            responseType: APIResponse<TimeOffRequest>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func approveTimeOffRequest(id: Int) async throws -> TimeOffRequest {
        let emptyBody: [String: String] = [:]
        let response: APIResponse<TimeOffRequestResponse> = try await networkManager.put(
            endpoint: "/employers/time_off_requests/\(id)/approve",
            body: emptyBody,
            responseType: APIResponse<TimeOffRequestResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.timeOffRequest
    }
    
    func denyTimeOffRequest(id: Int) async throws -> TimeOffRequest {
        let emptyBody: [String: String] = [:]
        let response: APIResponse<TimeOffRequestResponse> = try await networkManager.put(
            endpoint: "/employers/time_off_requests/\(id)/deny",
            body: emptyBody,
            responseType: APIResponse<TimeOffRequestResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.timeOffRequest
    }
    
    func getTimeOffStats() async throws -> TimeOffStats {
        let response: APIResponse<TimeOffStats> = try await networkManager.get(
            endpoint: "/employers/time_off_requests/stats",
            responseType: APIResponse<TimeOffStats>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getAnalyticsOverview(
        startDate: String? = nil,
        endDate: String? = nil
    ) async throws -> AnalyticsOverview {
        var endpoint = "/analytics/overview"
        
        var params: [String] = []
        if let startDate = startDate {
            params.append("start_date=\(startDate)")
        }
        if let endDate = endDate {
            params.append("end_date=\(endDate)")
        }
        
        if !params.isEmpty {
            endpoint += "?" + params.joined(separator: "&")
        }
        
        let response: APIResponse<AnalyticsOverview> = try await networkManager.get(
            endpoint: "/employers" + endpoint,
            responseType: APIResponse<AnalyticsOverview>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getEmployeeAnalytics() async throws -> AnalyticsOverview {
        let response: APIResponse<AnalyticsOverview> = try await networkManager.get(
            endpoint: "/employers/analytics/employees",
            responseType: APIResponse<AnalyticsOverview>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getDetailedEmployer(id: Int) async throws -> DetailedEmployerResponse {
        let response: APIResponse<DetailedEmployerResponse> = try await networkManager.get(
            endpoint: "/admin/employers/\(id)",
            responseType: APIResponse<DetailedEmployerResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    // MARK: - Invoice methods
    func getInvoices(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil
    ) async throws -> [Invoice] {
        // Check if current user is an admin and use appropriate endpoint
        let isAdmin = await isCurrentUserAdmin()
        let baseEndpoint = isAdmin ? "/admin/invoices" : "/employers/invoices"
        var endpoint = "\(baseEndpoint)?page=\(page)&per_page=\(perPage)"
        
        if let status = status {
            endpoint += "&status=\(status)"
        }
        
        let response: APIResponse<InvoiceListResponse> = try await networkManager.get(
            endpoint: endpoint,
            responseType: APIResponse<InvoiceListResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.invoices
    }
    
    private func isCurrentUserAdmin() async -> Bool {
        // Return cached value if available
        if let cached = cachedIsAdmin {
            return cached
        }
        
        // If there's already a request in progress, wait for it
        if let existingTask = adminCheckTask {
            do {
                return try await existingTask.value
            } catch {
                // If the existing task failed, try again
            }
        }
        
        // Create new task to check admin status
        let task = Task<Bool, Error> {
            guard UserDefaults.standard.string(forKey: "jwt_token") != nil else {
                return false
            }
            
            do {
                let response: APIResponse<UserProfileWrapperForAPI> = try await networkManager.get(
                    endpoint: "/auth/profile",
                    responseType: APIResponse<UserProfileWrapperForAPI>.self
                )
                
                // Check if user type indicates admin or if they have super admin status
                let userType = response.data.user.user_type.lowercased()
                let isSuperAdmin = response.data.user.super_admin ?? false
                let hasAdminRole = response.data.user.roles?.contains { $0.lowercased().contains("admin") } ?? false
                
                let isAdmin = userType == "admin" || 
                             isSuperAdmin || 
                             hasAdminRole
                
                print("Admin status check: userType=\(userType), isSuperAdmin=\(isSuperAdmin), hasAdminRole=\(hasAdminRole), isAdmin=\(isAdmin)")
                
                // Cache the result
                self.cachedIsAdmin = isAdmin
                return isAdmin
            } catch {
                // If we can't determine user type, default to non-admin endpoint
                print("Failed to determine user admin status: \(error)")
                self.cachedIsAdmin = false
                return false
            }
        }
        
        adminCheckTask = task
        
        do {
            let result = try await task.value
            adminCheckTask = nil
            return result
        } catch {
            adminCheckTask = nil
            return false
        }
    }
    
    // Add a method to clear the cache when needed (e.g., on logout)
    func clearAdminCache() {
        cachedIsAdmin = nil
        adminCheckTask?.cancel()
        adminCheckTask = nil
    }
    
    func getInvoiceDetails(id: Int) async throws -> DetailedInvoice {
        // Check if current user is an admin and use appropriate endpoint
        let isAdmin = await isCurrentUserAdmin()
        let endpoint = isAdmin ? "/admin/invoices/\(id)" : "/employers/invoices/\(id)"
        
        let response: APIResponse<InvoiceDetailResponse> = try await networkManager.get(
            endpoint: endpoint,
            responseType: APIResponse<InvoiceDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.invoice
    }
    
    func downloadInvoicePDF(id: Int) async throws -> Data {
        // Check if current user is an admin and use appropriate endpoint
        let isAdmin = await isCurrentUserAdmin()
        let endpoint = isAdmin ? "/admin/invoices/\(id)/download_pdf" : "/employers/invoices/\(id)/download_pdf"
        
        guard let url = URL(string: "\(NetworkManager.shared.baseURL)\(endpoint)") else {
            throw NetworkManager.NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/pdf", forHTTPHeaderField: "Accept")
        
        // Add authorization token
        if let token = UserDefaults.standard.string(forKey: "jwt_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkManager.NetworkError.networkError(URLError(.badServerResponse))
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkManager.NetworkError.authenticationError
        }
        
        if httpResponse.statusCode >= 400 {
            throw NetworkManager.NetworkError.serverError("HTTP \(httpResponse.statusCode)")
        }
        
        // Validate that we received PDF data
        // PDF files start with "%PDF" magic bytes
        if data.count < 5 {
            print("ERROR: Received data is too small (\(data.count) bytes)")
            throw NetworkManager.NetworkError.serverError("Invalid PDF data - too small")
        }
        
        let pdfHeader = String(data: data.prefix(5), encoding: .ascii)
        if pdfHeader != "%PDF-" {
            print("ERROR: Data doesn't appear to be PDF. First bytes: \(data.prefix(100).map { String(format: "%02x", $0) }.joined())")
            // Try to see if it's JSON error response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON instead of PDF: \(jsonString)")
            }
            throw NetworkManager.NetworkError.serverError("Invalid PDF data - not a PDF file")
        }
        
        print("Successfully received PDF data: \(data.count) bytes")
        return data
    }
    
    // MARK: - Holiday Methods
    func getHolidays() async throws -> HolidaysResponse {
        let response: APIResponse<HolidaysResponse> = try await networkManager.get(
            endpoint: "/employers/holidays",
            responseType: APIResponse<HolidaysResponse>.self
        )
        
        if response.success {
            return response.data
        } else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
    }
    
    // MARK: - Callback-based methods for compatibility
    func fetchEmployerProfile(completion: @escaping (Result<EmployerProfileData, Error>) -> Void) {
        Task {
            do {
                let response: APIResponse<EmployerProfileData> = try await networkManager.get(
                    endpoint: "/employers/profile",
                    responseType: APIResponse<EmployerProfileData>.self
                )
                
                if response.success {
                    completion(.success(response.data))
                } else {
                    completion(.failure(NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Job Postings Methods
    func getJobPostings(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil,
        location: String? = nil,
        employmentType: String? = nil,
        experienceLevel: String? = nil,
        department: String? = nil
    ) async throws -> JobPostingsResponse {
        var endpoint = "/admin/job_postings?page=\(page)&per_page=\(perPage)"
        
        if let search = search, !search.isEmpty {
            endpoint += "&search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        if let location = location, !location.isEmpty {
            endpoint += "&location=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        if let employmentType = employmentType, !employmentType.isEmpty {
            endpoint += "&employment_type=\(employmentType)"
        }
        
        if let experienceLevel = experienceLevel, !experienceLevel.isEmpty {
            endpoint += "&experience_level=\(experienceLevel)"
        }
        
        if let department = department, !department.isEmpty {
            endpoint += "&department=\(department.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        let response: APIResponse<JobPostingsResponse> = try await networkManager.get(
            endpoint: endpoint,
            responseType: APIResponse<JobPostingsResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getJobPosting(id: Int) async throws -> JobPosting {
        let response: APIResponse<JobPostingDetailResponse> = try await networkManager.get(
            endpoint: "/admin/job_postings/\(id)",
            responseType: APIResponse<JobPostingDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.jobPosting
    }
    
    // MARK: - Admin User Management Methods
    
    func getAdminUsers(
        page: Int = 1,
        perPage: Int = 50,
        search: String? = nil,
        userType: String? = nil,
        role: String? = nil,
        status: String? = nil
    ) async throws -> AdminUsersResponse {
        var endpoint = "/admin/users?page=\(page)&per_page=\(perPage)"
        
        if let search = search, !search.isEmpty {
            endpoint += "&search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        if let userType = userType, !userType.isEmpty {
            endpoint += "&user_type=\(userType)"
        }
        
        if let role = role, !role.isEmpty {
            endpoint += "&role=\(role)"
        }
        
        if let status = status, !status.isEmpty {
            endpoint += "&status=\(status)"
        }
        
        let response: APIResponse<AdminUsersResponse> = try await networkManager.get(
            endpoint: endpoint,
            responseType: APIResponse<AdminUsersResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getAdminUser(id: Int) async throws -> AdminUserDetail {
        let response: APIResponse<AdminUserDetailResponse> = try await networkManager.get(
            endpoint: "/admin/users/\(id)",
            responseType: APIResponse<AdminUserDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.user
    }
    
    func createAdminUser(request: CreateUserRequest) async throws -> AdminUserDetail {
        let response: APIResponse<AdminUserDetailResponse> = try await networkManager.post(
            endpoint: "/admin/users",
            body: request,
            responseType: APIResponse<AdminUserDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.user
    }
    
    func updateAdminUser(id: Int, request: UpdateUserRequest) async throws -> AdminUserDetail {
        let response: APIResponse<AdminUserDetailResponse> = try await networkManager.put(
            endpoint: "/admin/users/\(id)",
            body: request,
            responseType: APIResponse<AdminUserDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.user
    }
    
    func deleteAdminUser(id: Int) async throws {
        let response: APIResponse<EmptyResponse> = try await networkManager.delete(
            endpoint: "/admin/users/\(id)",
            responseType: APIResponse<EmptyResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
    }
    
    func suspendAdminUser(id: Int) async throws -> AdminUserDetail {
        let emptyBody: [String: String] = [:]
        let response: APIResponse<AdminUserDetailResponse> = try await networkManager.post(
            endpoint: "/admin/users/\(id)/suspend",
            body: emptyBody,
            responseType: APIResponse<AdminUserDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.user
    }
    
    func activateAdminUser(id: Int) async throws -> AdminUserDetail {
        let emptyBody: [String: String] = [:]
        let response: APIResponse<AdminUserDetailResponse> = try await networkManager.post(
            endpoint: "/admin/users/\(id)/activate",
            body: emptyBody,
            responseType: APIResponse<AdminUserDetailResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.user
    }
    
    func resetAdminUserPassword(id: Int) async throws {
        let emptyBody: [String: String] = [:]
        let response: APIResponse<PasswordResetResponse> = try await networkManager.post(
            endpoint: "/admin/users/\(id)/reset_password",
            body: emptyBody,
            responseType: APIResponse<PasswordResetResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
    }
    
    // MARK: - Admin API Methods
    
    func getAdminDashboard() async throws -> AdminDashboardData {
        let response: APIResponse<AdminDashboardResponse> = try await networkManager.get(
            endpoint: "/admin/dashboard",
            responseType: APIResponse<AdminDashboardResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return AdminDashboardData(
            stats: response.data.stats,
            recentEmployers: response.data.recentEmployers ?? [],
            systemAlerts: response.data.systemAlerts ?? []
        )
    }

    func getAdminStats() async throws -> AdminStats {
        let dashboardData = try await getAdminDashboard()
        return dashboardData.stats
    }
    
    func getAllEmployers(page: Int = 1, perPage: Int = 20, search: String? = nil) async throws -> AdminEmployersResponse {
        var endpoint = "/admin/employers?page=\(page)&per_page=\(perPage)"
        
        if let search = search, !search.isEmpty {
            endpoint += "&search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        let response: APIResponse<AdminEmployersResponse> = try await networkManager.get(
            endpoint: endpoint,
            responseType: APIResponse<AdminEmployersResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func updateAdminEmployee(id: Int, employee: AdminEmployeeUpdateRequest) async throws -> Employee {
        // Create employee parameters without salary_detail
        let employeeData = AdminEmployeeUpdateRequestForAPI(
            firstName: employee.firstName,
            lastName: employee.lastName,
            email: employee.email,
            phoneNumber: employee.phoneNumber,
            personalEmail: employee.personalEmail,
            department: employee.department,
            status: employee.status,
            employeeType: employee.employeeType,
            title: employee.title,
            location: employee.location,
            address: employee.address,
            city: employee.city,
            country: employee.country,
            postcode: employee.postcode,
            personalIdNumber: employee.personalIdNumber,
            fullNameCyr: employee.fullNameCyr,
            cityCyr: employee.cityCyr,
            addressCyr: employee.addressCyr,
            countryCyr: employee.countryCyr
        )
        
        // Create the body with both employee and salary_detail
        let requestBody = AdminEmployeeUpdateBody(
            employee: employeeData,
            salaryDetail: employee.salaryDetail
        )
        
        let response: APIResponse<AdminEmployeeResponse> = try await networkManager.put(
            endpoint: "/admin/employees/\(id)",
            body: requestBody,
            responseType: APIResponse<AdminEmployeeResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.employee
    }
    
    func createAdminEmployee(employee: AdminEmployeeCreateRequest) async throws -> Employee {
        let response: APIResponse<AdminEmployeeResponse> = try await networkManager.post(
            endpoint: "/admin/employees",
            body: ["employee": employee],
            responseType: APIResponse<AdminEmployeeResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.employee
    }
    
    func lookupBankName(accountNumber: String, country: String) async throws -> BankNameLookupResponse {
        let request = BankNameLookupRequest(accountNumber: accountNumber, country: country)
        
        let response: APIResponse<BankNameLookupResponse> = try await networkManager.post(
            endpoint: "/admin/bank_name_lookup",
            body: request,
            responseType: APIResponse<BankNameLookupResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
    func getAdminEmployee(id: Int) async throws -> Employee {
        let response: APIResponse<AdminEmployeeResponse> = try await networkManager.get(
            endpoint: "/admin/employees/\(id)",
            responseType: APIResponse<AdminEmployeeResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data.employee
    }
    
    func getAllEmployees(page: Int = 1, perPage: Int = 20, search: String? = nil, status: String? = nil) async throws -> AdminEmployeesResponse {
        var endpoint = "/admin/employees?page=\(page)&per_page=\(perPage)"
        
        if let search = search, !search.isEmpty {
            endpoint += "&search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        if let status = status, !status.isEmpty {
            endpoint += "&status=\(status)"
        }
        
        let response: APIResponse<AdminEmployeesResponse> = try await networkManager.get(
            endpoint: endpoint,
            responseType: APIResponse<AdminEmployeesResponse>.self
        )
        
        guard response.success else {
            throw NetworkManager.NetworkError.serverError(response.message ?? "Unknown error")
        }
        
        return response.data
    }
    
}

// MARK: - Response Types
struct InvoiceDetailResponse: Codable {
    let invoice: DetailedInvoice
}

struct JobPostingDetailResponse: Codable {
    let jobPosting: JobPosting
    
    enum CodingKeys: String, CodingKey {
        case jobPosting = "job_posting"
    }
}

struct AdminDashboardResponse: Codable {
    let stats: AdminStats
    let recentEmployers: [RecentEmployer]?
    let systemAlerts: [SystemAlert]?
    
    enum CodingKeys: String, CodingKey {
        case stats
        case recentEmployers = "recent_employers"
        case systemAlerts = "system_alerts"
    }
}



struct AdminEmployersResponse: Codable {
    let employers: [Employer]
    let pagination: PaginationInfo
}

struct AdminEmployeesResponse: Codable {
    let employees: [Employee]
    let pagination: PaginationInfo
}

struct AdminEmployeeResponse: Codable {
    let employee: Employee
}

struct AdminEmployeeUpdateRequest: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNumber: String?
    let personalEmail: String?
    let department: String?
    let status: String?
    let employeeType: String?
    let title: String?
    let location: String?
    let address: String?
    let city: String?
    let country: String?
    let postcode: String?
    let personalIdNumber: String?
    let fullNameCyr: String?
    let cityCyr: String?
    let addressCyr: String?
    let countryCyr: String?
    let salaryDetail: AdminSalaryDetailUpdateRequest?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case personalEmail = "personal_email"
        case department
        case status
        case employeeType = "employee_type"
        case title
        case location
        case address
        case city
        case country
        case postcode
        case personalIdNumber = "personal_id_number"
        case fullNameCyr = "full_name_cyr"
        case cityCyr = "city_cyr"
        case addressCyr = "address_cyr"
        case countryCyr = "country_cyr"
        case salaryDetail = "salary_detail"
    }
}

struct AdminSalaryDetailUpdateRequest: Codable {
    let baseSalary: Double?
    let hourlySalary: Double?
    let variableSalary: Double?
    let deductions: Double?
    let netSalary: Double?
    let grossSalary: Double?
    let seniority: Double?
    let bankName: String?
    let bankAccountNumber: String?
    let onMaternity: Bool?
    let merotFee: Double?
    
    enum CodingKeys: String, CodingKey {
        case baseSalary = "base_salary"
        case hourlySalary = "hourly_salary"
        case variableSalary = "variable_salary"
        case deductions = "deductions"
        case netSalary = "net_salary"
        case grossSalary = "gross_salary"
        case seniority = "seniority"
        case bankName = "bank_name"
        case bankAccountNumber = "bank_account_number"
        case onMaternity = "on_maternity"
        case merotFee = "merot_fee"
    }
}

struct AdminEmployeeUpdateRequestForAPI: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNumber: String?
    let personalEmail: String?
    let department: String?
    let status: String?
    let employeeType: String?
    let title: String?
    let location: String?
    let address: String?
    let city: String?
    let country: String?
    let postcode: String?
    let personalIdNumber: String?
    let fullNameCyr: String?
    let cityCyr: String?
    let addressCyr: String?
    let countryCyr: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case personalEmail = "personal_email"
        case department
        case status
        case employeeType = "employee_type"
        case title
        case location
        case address
        case city
        case country
        case postcode
        case personalIdNumber = "personal_id_number"
        case fullNameCyr = "full_name_cyr"
        case cityCyr = "city_cyr"
        case addressCyr = "address_cyr"
        case countryCyr = "country_cyr"
    }
}

struct AdminEmployeeUpdateBody: Codable {
    let employee: AdminEmployeeUpdateRequestForAPI
    let salaryDetail: AdminSalaryDetailUpdateRequest?
    
    enum CodingKeys: String, CodingKey {
        case employee
        case salaryDetail = "salary_detail"
    }
}

struct BankNameLookupRequest: Codable {
    let accountNumber: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case accountNumber = "account_number"
        case country
    }
}

struct BankNameLookupResponse: Codable {
    let bankName: String
    let accountNumber: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case bankName = "bank_name"
        case accountNumber = "account_number"
        case country
    }
}

struct AdminEmployeeCreateRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String?
    let phoneNumber: String?
    let personalEmail: String?
    let department: String?
    let status: String?
    let employeeType: String?
    let title: String?
    let location: String?
    let address: String?
    let city: String?
    let country: String?
    let postcode: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case password
        case phoneNumber = "phone_number"
        case personalEmail = "personal_email"
        case department
        case status
        case employeeType = "employee_type"
        case title
        case location
        case address
        case city
        case country
        case postcode
    }
}

// MARK: - Admin User Management Response Types
struct AdminUsersResponse: Codable {
    let users: [AdminUserDetail]
    let pagination: PaginationInfo
}

struct AdminUserDetailResponse: Codable {
    let user: AdminUserDetail
}

struct AdminUserDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let userType: String
    let status: String
    let role: String?
    let isSuperAdmin: Bool?
    let employer: EmployerInfo?
    let department: String?
    let employeeId: String?
    let lastLogin: String?
    let createdAt: String
    let updatedAt: String
    let phoneNumber: String?
    let address: String?
    let city: String?
    let country: String?
    let signInCount: Int?
    let currentSignInAt: String?
    let suspendedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case userType = "user_type"
        case status
        case role
        case isSuperAdmin = "is_super_admin"
        case employer
        case department
        case employeeId = "employee_id"
        case lastLogin = "last_login"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case phoneNumber = "phone_number"
        case address
        case city
        case country
        case signInCount = "sign_in_count"
        case currentSignInAt = "current_sign_in_at"
        case suspendedAt = "suspended_at"
    }
    
    struct EmployerInfo: Codable {
        let id: Int
        let name: String
    }
}

struct CreateUserRequest: Codable {
    let userType: String
    let email: String
    let firstName: String
    let lastName: String
    let password: String?
    let sendWelcomeEmail: Bool
    let employerId: Int?
    let department: String?
    let role: String?
    
    enum CodingKeys: String, CodingKey {
        case userType = "user_type"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case password
        case sendWelcomeEmail = "send_welcome_email"
        case employerId = "employer_id"
        case department
        case role
    }
}

struct UpdateUserRequest: Codable {
    let email: String?
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let department: String?
    let status: String?
    let role: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case department
        case status
        case role
    }
}

struct PasswordResetResponse: Codable {
    let message: String
    let emailSent: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case emailSent = "email_sent"
    }
}


