import Foundation

struct DataResult<T> {
    let data: T
    let isFromCache: Bool
}

class CachedAPIService: ObservableObject {
    private let apiService: APIService
    private let cacheManager = CacheManager.shared
    private let requestManager = RequestManager()
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Admin Dashboard Methods
    
    func getAdminDashboard(forceRefresh: Bool = false) async throws -> AdminDashboardData {
        let cacheKey = CacheManager.CacheKeys.adminDashboard()
        let requestKey = "admin_dashboard"
        
        return try await requestManager.executeRequest(key: requestKey) {
            // Return cached data if available and not forcing refresh
            if !forceRefresh, let cachedData = self.cacheManager.retrieve(AdminDashboardData.self, forKey: cacheKey) {
                print("CachedAPIService: Returning cached admin dashboard data")
                return cachedData
            }
            
            // Fetch fresh data
            print("CachedAPIService: Fetching fresh admin dashboard data (forceRefresh: \(forceRefresh))")
            do {
                let freshData = try await self.apiService.getAdminDashboard()
                print("CachedAPIService: Successfully fetched fresh admin dashboard data")
                
                // Cache the fresh data
                self.cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.short)
                print("CachedAPIService: Cached fresh admin dashboard data")
                
                return freshData
            } catch {
                print("CachedAPIService: Error fetching admin dashboard data: \(error)")
                throw error
            }
        }
    }
    
    func getAdminDashboardWithSource(forceRefresh: Bool = false) async throws -> DataResult<AdminDashboardData> {
        let cacheKey = CacheManager.CacheKeys.adminDashboard()
        let requestKey = "admin_dashboard_with_source"
        
        return try await requestManager.executeRequest(key: requestKey) {
            // Return cached data if available and not forcing refresh
            if !forceRefresh, let cachedData = self.cacheManager.retrieve(AdminDashboardData.self, forKey: cacheKey) {
                return DataResult(data: cachedData, isFromCache: true)
            }
            
            // Fetch fresh data
            let freshData = try await self.apiService.getAdminDashboard()
            
            // Cache the fresh data
            self.cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.short)
            
            return DataResult(data: freshData, isFromCache: false)
        }
    }
    
    func getAdminStats(forceRefresh: Bool = false) async throws -> AdminStats {
        let cacheKey = CacheManager.CacheKeys.adminStats()
        
        if !forceRefresh, let cachedData = cacheManager.retrieve(AdminStats.self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getAdminStats()
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.short)
        
        return freshData
    }
    
    func getAllEmployers(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil,
        forceRefresh: Bool = false
    ) async throws -> AdminEmployersResponse {
        let cacheKey = CacheManager.CacheKeys.employers(page: page, search: search)
        let requestKey = "employers_page_\(page)_search_\(search ?? "none")"
        
        return try await requestManager.executeRequest(key: requestKey) {
            if !forceRefresh, let cachedData = self.cacheManager.retrieve(AdminEmployersResponse.self, forKey: cacheKey) {
                return cachedData
            }
            
            let freshData = try await self.apiService.getAllEmployers(page: page, perPage: perPage, search: search)
            self.cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.medium)
            
            return freshData
        }
    }
    
    func getAllEmployees(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil,
        status: String? = nil,
        forceRefresh: Bool = false
    ) async throws -> AdminEmployeesResponse {
        let cacheKey = CacheManager.CacheKeys.employees(page: page, search: search, status: status)
        let requestKey = "employees_page_\(page)_search_\(search ?? "none")_status_\(status ?? "all")"
        
        return try await requestManager.executeRequest(key: requestKey) {
            if !forceRefresh, let cachedData = self.cacheManager.retrieve(AdminEmployeesResponse.self, forKey: cacheKey) {
                return cachedData
            }
            
            let freshData = try await self.apiService.getAllEmployees(page: page, perPage: perPage, search: search, status: status)
            self.cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.medium)
            
            return freshData
        }
    }
    
    // MARK: - Regular Dashboard Methods
    
    func getDashboard(forceRefresh: Bool = false) async throws -> DashboardData {
        let cacheKey = CacheManager.CacheKeys.dashboard()
        
        if !forceRefresh, let cachedData = cacheManager.retrieve(DashboardData.self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getDashboard()
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.medium)
        
        return freshData
    }
    
    func getEmployerProfile(forceRefresh: Bool = false) async throws -> Employer {
        let cacheKey = CacheManager.CacheKeys.userProfile()
        
        if !forceRefresh, let cachedData = cacheManager.retrieve(Employer.self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getEmployerProfile()
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.long)
        
        return freshData
    }
    
    // MARK: - Employee Methods
    
    func getEmployees(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil,
        search: String? = nil,
        forceRefresh: Bool = false
    ) async throws -> EmployeeListResponse {
        let cacheKey = "employees_page_\(page)_status_\(status ?? "all")_search_\(search ?? "none")"
        
        if !forceRefresh, let cachedData = cacheManager.retrieve(EmployeeListResponse.self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getEmployees(page: page, perPage: perPage, status: status, search: search)
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.medium)
        
        return freshData
    }
    
    func getEmployee(id: Int, forceRefresh: Bool = false) async throws -> Employee {
        let cacheKey = CacheManager.CacheKeys.employee(id: id)
        
        if !forceRefresh, let cachedData = cacheManager.retrieve(Employee.self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getEmployee(id: id)
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.long)
        
        return freshData
    }
    
    // MARK: - Time Off Methods
    
    func getTimeOffRequests(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil,
        employeeId: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        forceRefresh: Bool = false
    ) async throws -> [TimeOffRequest] {
        let cacheKey = CacheManager.CacheKeys.timeOffRequests()
        
        if !forceRefresh, let cachedData = cacheManager.retrieve([TimeOffRequest].self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getTimeOffRequests(
            page: page,
            perPage: perPage,
            status: status,
            employeeId: employeeId,
            startDate: startDate,
            endDate: endDate
        )
        
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.short)
        
        return freshData
    }
    
    func getHolidays(forceRefresh: Bool = false) async throws -> HolidaysResponse {
        let cacheKey = CacheManager.CacheKeys.holidays()
        
        if !forceRefresh, let cachedData = cacheManager.retrieve(HolidaysResponse.self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getHolidays()
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.extended)
        
        return freshData
    }
    
    // MARK: - Invoice Methods
    
    func getInvoices(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil,
        forceRefresh: Bool = false
    ) async throws -> [Invoice] {
        let cacheKey = CacheManager.CacheKeys.invoices(page: page, status: status)
        
        if !forceRefresh, let cachedData = cacheManager.retrieve([Invoice].self, forKey: cacheKey) {
            return cachedData
        }
        
        let freshData = try await apiService.getInvoices(page: page, perPage: perPage, status: status)
        cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.medium)
        
        return freshData
    }
    
    // MARK: - Admin Employee Operations
    
    func updateAdminEmployee(id: Int, employee: AdminEmployeeUpdateRequest) async throws -> Employee {
        let requestKey = "admin_update_employee_\(id)"
        
        return try await requestManager.executeRequest(key: requestKey) {
            let updatedEmployee = try await self.apiService.updateAdminEmployee(id: id, employee: employee)
            
            // Invalidate related caches
            self.cacheManager.removeCache(forKey: CacheManager.CacheKeys.employee(id: id))
            // Also invalidate employee lists as they might contain this employee
            self.invalidateEmployeesListCache()
            
            // Cache the updated employee
            self.cacheManager.cache(updatedEmployee, forKey: CacheManager.CacheKeys.employee(id: id), expirationInterval: CacheManager.CacheExpiration.long)
            
            return updatedEmployee
        }
    }
    
    func createAdminEmployee(employee: AdminEmployeeCreateRequest) async throws -> Employee {
        let requestKey = "admin_create_employee"
        
        return try await requestManager.executeRequest(key: requestKey) {
            let newEmployee = try await self.apiService.createAdminEmployee(employee: employee)
            
            // Invalidate employee lists to include new employee
            self.invalidateEmployeesListCache()
            
            // Cache the new employee
            self.cacheManager.cache(newEmployee, forKey: CacheManager.CacheKeys.employee(id: newEmployee.id), expirationInterval: CacheManager.CacheExpiration.long)
            
            return newEmployee
        }
    }
    
    func lookupBankName(accountNumber: String, country: String) async throws -> BankNameLookupResponse {
        // Don't cache bank name lookups as they are simple and fast
        return try await apiService.lookupBankName(accountNumber: accountNumber, country: country)
    }
    
    func getAdminEmployee(id: Int, forceRefresh: Bool = false) async throws -> Employee {
        let cacheKey = CacheManager.CacheKeys.employee(id: id)
        let requestKey = "admin_employee_\(id)"
        
        return try await requestManager.executeRequest(key: requestKey) {
            if !forceRefresh, let cachedData = self.cacheManager.retrieve(Employee.self, forKey: cacheKey) {
                return cachedData
            }
            
            let freshData = try await self.apiService.getAdminEmployee(id: id)
            self.cacheManager.cache(freshData, forKey: cacheKey, expirationInterval: CacheManager.CacheExpiration.long)
            
            return freshData
        }
    }

    // MARK: - Write Operations (These invalidate cache)
    
    func updateEmployerProfile(_ employer: Employer) async throws -> Employer {
        let updatedEmployer = try await apiService.updateEmployerProfile(employer)
        
        // Invalidate related caches
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.userProfile())
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.dashboard())
        
        // Cache the updated employer
        cacheManager.cache(updatedEmployer, forKey: CacheManager.CacheKeys.userProfile(), expirationInterval: CacheManager.CacheExpiration.long)
        
        return updatedEmployer
    }
    
    func updateEmployee(id: Int, employee: Employee) async throws -> Employee {
        let updatedEmployee = try await apiService.updateEmployee(id: id, employee: employee)
        
        // Invalidate related caches
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.employee(id: id))
        // Also invalidate employee lists as they might contain this employee
        invalidateEmployeesListCache()
        
        // Cache the updated employee
        cacheManager.cache(updatedEmployee, forKey: CacheManager.CacheKeys.employee(id: id), expirationInterval: CacheManager.CacheExpiration.long)
        
        return updatedEmployee
    }
    
    func approveTimeOffRequest(id: Int) async throws -> TimeOffRequest {
        let approvedRequest = try await apiService.approveTimeOffRequest(id: id)
        
        // Invalidate time off cache since the status changed
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.timeOffRequests())
        
        return approvedRequest
    }
    
    func denyTimeOffRequest(id: Int) async throws -> TimeOffRequest {
        let deniedRequest = try await apiService.denyTimeOffRequest(id: id)
        
        // Invalidate time off cache since the status changed
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.timeOffRequests())
        
        return deniedRequest
    }
    
    // MARK: - Cache Management
    
    func invalidateAllCache() {
        cacheManager.clearAllCache()
    }
    
    func cancelAllRequests() async {
        await requestManager.cancelAllRequests()
    }
    
    func cancelAdminDashboardRequest() async {
        await requestManager.cancelRequest(key: "admin_dashboard")
    }
    
    func invalidateAdminCache() {
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.adminDashboard())
        cacheManager.removeCache(forKey: CacheManager.CacheKeys.adminStats())
    }
    
    func invalidateEmployeesListCache() {
        // This is a simplified approach - in production, you might want to track all employee list cache keys
        let statistics = cacheManager.getCacheStatistics()
        if statistics.diskCacheCount > 0 {
            // Clear employee-related caches
            cacheManager.clearAllCache()
        }
    }
    
    func getCacheStatistics() -> CacheStatistics {
        return cacheManager.getCacheStatistics()
    }
    
    // MARK: - Pass-through methods for operations that shouldn't be cached
    
    func downloadInvoicePDF(id: Int) async throws -> Data {
        return try await apiService.downloadInvoicePDF(id: id)
    }
    
    func getAnalyticsOverview(startDate: String? = nil, endDate: String? = nil) async throws -> AnalyticsOverview {
        // Analytics should be fresh, so don't cache
        return try await apiService.getAnalyticsOverview(startDate: startDate, endDate: endDate)
    }
    
    func getEmployeeAnalytics() async throws -> AnalyticsOverview {
        // Analytics should be fresh, so don't cache
        return try await apiService.getEmployeeAnalytics()
    }
}