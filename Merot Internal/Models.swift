import Foundation

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let userType: String
    let employer: Employer?
    let fullName: String?
    let roles: [String]?
    let superAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, email, employer, roles
        case userType = "user_type"
        case fullName = "full_name"
        case superAdmin = "super_admin"
    }
}

struct UserProfileWrapper: Codable {
    let user: User
}

struct UserProfileWrapperForAPI: Codable {
    let user: UserProfileForAPI
}

struct UserProfileForAPI: Codable {
    let id: Int
    let email: String
    let user_type: String
    let full_name: String?
    let roles: [String]?
    let super_admin: Bool?
    let employer: Employer?
}

struct Employer: Codable, Identifiable {
    let id: Int?
    let name: String?
    let legalName: String?
    let primaryEmail: String?
    let billingEmail: String?
    let contactEmail: String?
    let addressLine1: String?
    let addressLine2: String?
    let addressCity: String?
    let addressState: String?
    let addressZip: String?
    let addressCountry: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case legalName = "legal_name"
        case primaryEmail = "primary_email"
        case billingEmail = "billing_email"
        case contactEmail = "contact_email"
        case addressLine1 = "address_line1"
        case addressLine2 = "address_line2"
        case addressCity = "address_city"
        case addressState = "address_state"
        case addressZip = "address_zip"
        case addressCountry = "address_country"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Detailed Employer Models for Admin

struct DetailedEmployerResponse: Codable {
    let employer: Employer
    let statistics: EmployerStatistics
    let representatives: [EmployerRepresentative]
    let recentEmployees: [EmployerRecentEmployee]
    let recentInvoices: [EmployerRecentInvoice]
    
    enum CodingKeys: String, CodingKey {
        case employer, statistics, representatives
        case recentEmployees = "recent_employees"
        case recentInvoices = "recent_invoices"
    }
}

struct EmployerStatistics: Codable {
    let totalEmployees: Int
    let activeEmployees: Int
    let inactiveEmployees: Int
    let unpaidInvoicesCount: Int
    let unpaidInvoicesTotal: Double
    let overdueInvoicesCount: Int
    let overdueInvoicesTotal: Double
    
    enum CodingKeys: String, CodingKey {
        case totalEmployees = "total_employees"
        case activeEmployees = "active_employees"
        case inactiveEmployees = "inactive_employees"
        case unpaidInvoicesCount = "unpaid_invoices_count"
        case unpaidInvoicesTotal = "unpaid_invoices_total"
        case overdueInvoicesCount = "overdue_invoices_count"
        case overdueInvoicesTotal = "overdue_invoices_total"
    }
    
}

struct EmployerRepresentative: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, name
        case createdAt = "created_at"
    }
}

struct EmployerRecentEmployee: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let department: String?
    let position: String?
    let startDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, department, position
        case startDate = "start_date"
    }
}

struct EmployerRecentInvoice: Codable, Identifiable {
    let id: Int
    let invoiceNumber: String
    let status: String
    let totalAmount: Double
    let dueDate: String?
    let overdue: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, status, overdue
        case invoiceNumber = "invoice_number"
        case totalAmount = "total_amount"
        case dueDate = "due_date"
    }
    
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T
}

struct APIErrorResponse: Codable {
    let success: Bool
    let message: String
    let errors: [String]?
}

// MARK: - Basic Models (restored for compatibility)

struct Employee: Codable, Identifiable {
    let id: Int
    let employeeId: String?
    let firstName: String?
    let lastName: String?
    let email: String
    let phoneNumber: String?
    let personalEmail: String?
    let department: String?
    let status: String
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
    let onLeave: String?
    let employment: Employment?
    let salaryDetail: SalaryDetail?
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, department, status, title, location, address, city, country, postcode
        case employeeId = "employee_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case personalEmail = "personal_email"
        case employeeType = "employee_type"
        case personalIdNumber = "personal_id_number"
        case fullNameCyr = "full_name_cyr"
        case cityCyr = "city_cyr"
        case addressCyr = "address_cyr"
        case countryCyr = "country_cyr"
        case onLeave = "on_leave"
        case employment
        case salaryDetail = "salary_detail"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Employment: Codable {
    let id: Int
    let employmentPosition: String?
    let startDate: Date?
    let endDate: Date?
    let grossSalary: Double?
    let employmentStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case employmentPosition = "employment_position"
        case startDate = "start_date"
        case endDate = "end_date"
        case grossSalary = "gross_salary"
        case employmentStatus = "employment_status"
    }
}

struct SalaryDetail: Codable {
    let id: Int
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
        case id
        case baseSalary = "base_salary"
        case hourlySalary = "hourly_salary"
        case variableSalary = "variable_salary"
        case deductions
        case netSalary = "net_salary"
        case grossSalary = "gross_salary"
        case seniority
        case bankName = "bank_name"
        case bankAccountNumber = "bank_account_number"
        case onMaternity = "on_maternity"
        case merotFee = "merot_fee"
    }
}

struct JobPosting: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let department: String?
    let status: String
    let location: String?
    let employmentType: String?
    let experienceLevel: String?
    let salaryMin: Double?
    let salaryMax: Double?
    let salaryCurrency: String?
    let salaryPeriod: String?
    let positionsAvailable: Int
    let positionsFilled: Int
    let applicationsCount: Int?
    let viewsCount: Int?
    let requirements: String?
    let benefits: String?
    let publishedAt: String
    let expiresAt: String?
    let employer: JobPostingEmployer
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, department, status, location, requirements, benefits, employer
        case employmentType = "employment_type"
        case experienceLevel = "experience_level"
        case salaryMin = "salary_min"
        case salaryMax = "salary_max"
        case salaryCurrency = "salary_currency"
        case salaryPeriod = "salary_period"
        case positionsAvailable = "positions_available"
        case positionsFilled = "positions_filled"
        case applicationsCount = "applications_count"
        case viewsCount = "views_count"
        case publishedAt = "published_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Memberwise initializer for manual creation (like in previews)
    init(id: Int, title: String, description: String?, department: String?, status: String, location: String?, employmentType: String?, experienceLevel: String?, salaryMin: Double?, salaryMax: Double?, salaryCurrency: String?, salaryPeriod: String?, positionsAvailable: Int, positionsFilled: Int, applicationsCount: Int?, viewsCount: Int?, requirements: String?, benefits: String?, publishedAt: String, expiresAt: String?, employer: JobPostingEmployer, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.department = department
        self.status = status
        self.location = location
        self.employmentType = employmentType
        self.experienceLevel = experienceLevel
        self.salaryMin = salaryMin
        self.salaryMax = salaryMax
        self.salaryCurrency = salaryCurrency
        self.salaryPeriod = salaryPeriod
        self.positionsAvailable = positionsAvailable
        self.positionsFilled = positionsFilled
        self.applicationsCount = applicationsCount
        self.viewsCount = viewsCount
        self.requirements = requirements
        self.benefits = benefits
        self.publishedAt = publishedAt
        self.expiresAt = expiresAt
        self.employer = employer
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom decoder for handling salary fields that might come as strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        department = try container.decodeIfPresent(String.self, forKey: .department)
        status = try container.decode(String.self, forKey: .status)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        employmentType = try container.decodeIfPresent(String.self, forKey: .employmentType)
        experienceLevel = try container.decodeIfPresent(String.self, forKey: .experienceLevel)
        
        // Handle salary fields that might come as strings or numbers
        if let salaryMinString = try? container.decodeIfPresent(String.self, forKey: .salaryMin) {
            salaryMin = Double(salaryMinString)
        } else {
            salaryMin = try container.decodeIfPresent(Double.self, forKey: .salaryMin)
        }
        
        if let salaryMaxString = try? container.decodeIfPresent(String.self, forKey: .salaryMax) {
            salaryMax = Double(salaryMaxString)
        } else {
            salaryMax = try container.decodeIfPresent(Double.self, forKey: .salaryMax)
        }
        
        salaryCurrency = try container.decodeIfPresent(String.self, forKey: .salaryCurrency)
        salaryPeriod = try container.decodeIfPresent(String.self, forKey: .salaryPeriod)
        positionsAvailable = try container.decode(Int.self, forKey: .positionsAvailable)
        positionsFilled = try container.decode(Int.self, forKey: .positionsFilled)
        applicationsCount = try container.decodeIfPresent(Int.self, forKey: .applicationsCount)
        viewsCount = try container.decodeIfPresent(Int.self, forKey: .viewsCount)
        requirements = try container.decodeIfPresent(String.self, forKey: .requirements)
        benefits = try container.decodeIfPresent(String.self, forKey: .benefits)
        publishedAt = try container.decode(String.self, forKey: .publishedAt)
        expiresAt = try container.decodeIfPresent(String.self, forKey: .expiresAt)
        employer = try container.decode(JobPostingEmployer.self, forKey: .employer)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

struct JobPostingEmployer: Codable {
    let id: Int
    let name: String?
}

struct JobApplication: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let status: String
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, status
        case firstName = "first_name"
        case lastName = "last_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AdminDashboardData: Codable {
    let stats: AdminStats
    let recentEmployers: [RecentEmployer]
    let systemAlerts: [SystemAlert]
    
    enum CodingKeys: String, CodingKey {
        case stats
        case recentEmployers = "recent_employers"
        case systemAlerts = "system_alerts"
    }
}

struct AdminStats: Codable {
    let totalEmployers: Int
    let activeEmployees: Int
    let activeInvoices: Int?
    let monthlyRevenue: Double?
    let recentEmployers: [RecentEmployer]?
    
    enum CodingKeys: String, CodingKey {
        case totalEmployers = "total_employers"
        case activeEmployees = "active_employees"
        case activeInvoices = "active_invoices"
        case monthlyRevenue = "monthly_revenue"
        case recentEmployers = "recent_employers"
    }
}

struct RecentEmployer: Codable, Identifiable {
    let id: Int
    let name: String
    let employeeCount: Int
    let createdAt: Date
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, status
        case employeeCount = "employee_count"
        case createdAt = "created_at"
    }
}

struct DashboardData: Codable {
    let stats: DashboardStats
    let recentActivities: [DashboardActivity]?
    
    enum CodingKeys: String, CodingKey {
        case stats
        case recentActivities = "recent_activities"
    }
}

struct DashboardStats: Codable {
    let totalEmployees: Int
    let activeEmployees: Int?
    let pendingTimeOffRequests: Int?
    let employeesOnLeaveToday: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalEmployees = "total_employees"
        case activeEmployees = "active_employees"
        case pendingTimeOffRequests = "pending_time_off_requests"
        case employeesOnLeaveToday = "employees_on_leave_today"
    }
}

struct DashboardActivity: Codable, Identifiable {
    let id: Int
    let type: String
    let employeeName: String?
    let startDate: Date?
    let endDate: Date?
    let status: String?
    let days: Int?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, type, status, days
        case employeeName = "employee_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        employeeName = try container.decodeIfPresent(String.self, forKey: .employeeName)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        days = try container.decodeIfPresent(Int.self, forKey: .days)
        
        // Helper function to parse dates with multiple formatters
        func parseDate(_ dateString: String) -> Date? {
            // Try ISO8601DateFormatter first
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            // Try without fractional seconds
            iso8601Formatter.formatOptions = [.withInternetDateTime]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            // Try with regular DateFormatter as fallback
            let dateFormatters = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",  // With fractional seconds and timezone
                "yyyy-MM-dd'T'HH:mm:ssXXXXX",      // Without fractional seconds and timezone
                "yyyy-MM-dd'T'HH:mm:ss.SSS'+02:00'", // Specific timezone format
                "yyyy-MM-dd'T'HH:mm:ss'+02:00'",     // Without fractional seconds, specific timezone
                "yyyy-MM-dd'T'HH:mm:ssZ",          // UTC format
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",      // UTC with fractional seconds
                "yyyy-MM-dd'T'HH:mm:ss"            // Without timezone
            ]
            
            for formatString in dateFormatters {
                let formatter = DateFormatter()
                formatter.dateFormat = formatString
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone.current
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            return nil
        }
        
        // Parse optional start and end dates
        if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
            startDate = parseDate(startDateString)
        } else {
            startDate = nil
        }
        
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = parseDate(endDateString)
        } else {
            endDate = nil
        }
        
        // Parse required created_at date
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        guard let parsedCreatedAt = parseDate(createdAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string '\(createdAtString)' could not be parsed with any supported format")
        }
        createdAt = parsedCreatedAt
    }
}

// MARK: - Invoice Models

struct Invoice: Codable, Identifiable {
    let id: Int
    let invoiceNumber: String
    let status: String
    let issueDate: String
    let dueDate: String
    let totalAmount: Double
    let subtotal: Double?
    let taxAmount: Double?
    let discountAmount: Double?
    let lateFee: Double?
    let currency: String?
    let billingPeriodStart: String?
    let billingPeriodEnd: String?
    let billingPeriodDisplay: String?
    let totalEmployees: Int?
    let payrollProcessingFee: Double?
    let hrServicesFee: Double?
    let benefitsAdministrationFee: Double?
    let overdue: Bool?
    let daysOverdue: Int?
    let employer: InvoiceEmployer?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, status, currency, overdue, subtotal, employer
        case invoiceNumber = "invoice_number"
        case issueDate = "issue_date"
        case dueDate = "due_date"
        case totalAmount = "total_amount"
        case taxAmount = "tax_amount"
        case discountAmount = "discount_amount"
        case lateFee = "late_fee"
        case billingPeriodStart = "billing_period_start"
        case billingPeriodEnd = "billing_period_end"
        case billingPeriodDisplay = "billing_period_display"
        case totalEmployees = "total_employees"
        case payrollProcessingFee = "payroll_processing_fee"
        case hrServicesFee = "hr_services_fee"
        case benefitsAdministrationFee = "benefits_administration_fee"
        case daysOverdue = "days_overdue"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Standard initializer for creating instances programmatically
    init(id: Int, invoiceNumber: String, status: String, issueDate: String, dueDate: String, totalAmount: Double, subtotal: Double? = nil, taxAmount: Double? = nil, discountAmount: Double? = nil, lateFee: Double? = nil, currency: String? = nil, billingPeriodStart: String? = nil, billingPeriodEnd: String? = nil, billingPeriodDisplay: String? = nil, totalEmployees: Int? = nil, payrollProcessingFee: Double? = nil, hrServicesFee: Double? = nil, benefitsAdministrationFee: Double? = nil, overdue: Bool? = nil, daysOverdue: Int? = nil, employer: InvoiceEmployer? = nil, createdAt: String, updatedAt: String) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.status = status
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.totalAmount = totalAmount
        self.subtotal = subtotal
        self.taxAmount = taxAmount
        self.discountAmount = discountAmount
        self.lateFee = lateFee
        self.currency = currency
        self.billingPeriodStart = billingPeriodStart
        self.billingPeriodEnd = billingPeriodEnd
        self.billingPeriodDisplay = billingPeriodDisplay
        self.totalEmployees = totalEmployees
        self.payrollProcessingFee = payrollProcessingFee
        self.hrServicesFee = hrServicesFee
        self.benefitsAdministrationFee = benefitsAdministrationFee
        self.overdue = overdue
        self.daysOverdue = daysOverdue
        self.employer = employer
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom decoder to handle string total_amount from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        invoiceNumber = try container.decode(String.self, forKey: .invoiceNumber)
        status = try container.decode(String.self, forKey: .status)
        issueDate = try container.decode(String.self, forKey: .issueDate)
        dueDate = try container.decode(String.self, forKey: .dueDate)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Handle totalAmount as string or double
        if let totalAmountString = try? container.decode(String.self, forKey: .totalAmount) {
            totalAmount = Double(totalAmountString) ?? 0.0
        } else {
            totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        }
        
        // Handle optional fields
        subtotal = try container.decodeIfPresent(Double.self, forKey: .subtotal)
        taxAmount = try container.decodeIfPresent(Double.self, forKey: .taxAmount)
        discountAmount = try container.decodeIfPresent(Double.self, forKey: .discountAmount)
        lateFee = try container.decodeIfPresent(Double.self, forKey: .lateFee)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        billingPeriodStart = try container.decodeIfPresent(String.self, forKey: .billingPeriodStart)
        billingPeriodEnd = try container.decodeIfPresent(String.self, forKey: .billingPeriodEnd)
        billingPeriodDisplay = try container.decodeIfPresent(String.self, forKey: .billingPeriodDisplay)
        totalEmployees = try container.decodeIfPresent(Int.self, forKey: .totalEmployees)
        payrollProcessingFee = try container.decodeIfPresent(Double.self, forKey: .payrollProcessingFee)
        hrServicesFee = try container.decodeIfPresent(Double.self, forKey: .hrServicesFee)
        benefitsAdministrationFee = try container.decodeIfPresent(Double.self, forKey: .benefitsAdministrationFee)
        overdue = try container.decodeIfPresent(Bool.self, forKey: .overdue)
        daysOverdue = try container.decodeIfPresent(Int.self, forKey: .daysOverdue)
        employer = try container.decodeIfPresent(InvoiceEmployer.self, forKey: .employer)
    }
}

struct DetailedInvoice: Codable, Identifiable {
    let id: Int
    let invoiceNumber: String
    let status: String
    let issueDate: String
    let dueDate: String
    let totalAmount: Double
    let subtotal: Double
    let taxAmount: Double
    let discountAmount: Double?
    let lateFee: Double?
    let currency: String
    let billingPeriodStart: String?
    let billingPeriodEnd: String?
    let billingPeriodDisplay: String?
    let totalEmployees: Int?
    let payrollProcessingFee: Double?
    let hrServicesFee: Double?
    let benefitsAdministrationFee: Double?
    let overdue: Bool?
    let daysOverdue: Int?
    let lineItems: [InvoiceLineItem]
    let employer: InvoiceEmployer?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, status, currency, overdue, subtotal, employer
        case invoiceNumber = "invoice_number"
        case issueDate = "issue_date"
        case dueDate = "due_date"
        case totalAmount = "total_amount"
        case taxAmount = "tax_amount"
        case discountAmount = "discount_amount"
        case lateFee = "late_fee"
        case billingPeriodStart = "billing_period_start"
        case billingPeriodEnd = "billing_period_end"
        case billingPeriodDisplay = "billing_period_display"
        case totalEmployees = "total_employees"
        case payrollProcessingFee = "payroll_processing_fee"
        case hrServicesFee = "hr_services_fee"
        case benefitsAdministrationFee = "benefits_administration_fee"
        case daysOverdue = "days_overdue"
        case lineItems = "invoice_line_items"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom decoder to handle string amounts from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        invoiceNumber = try container.decode(String.self, forKey: .invoiceNumber)
        status = try container.decode(String.self, forKey: .status)
        issueDate = try container.decode(String.self, forKey: .issueDate)
        dueDate = try container.decode(String.self, forKey: .dueDate)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Handle amounts that might be strings
        if let totalAmountString = try? container.decode(String.self, forKey: .totalAmount) {
            totalAmount = Double(totalAmountString) ?? 0.0
        } else {
            totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        }
        
        if let subtotalString = try? container.decode(String.self, forKey: .subtotal) {
            subtotal = Double(subtotalString) ?? 0.0
        } else {
            subtotal = try container.decode(Double.self, forKey: .subtotal)
        }
        
        if let taxAmountString = try? container.decode(String.self, forKey: .taxAmount) {
            taxAmount = Double(taxAmountString) ?? 0.0
        } else {
            taxAmount = try container.decode(Double.self, forKey: .taxAmount)
        }
        
        // Handle optional string amounts
        if let discountString = try? container.decode(String.self, forKey: .discountAmount) {
            discountAmount = Double(discountString)
        } else {
            discountAmount = try container.decodeIfPresent(Double.self, forKey: .discountAmount)
        }
        
        if let lateFeeString = try? container.decode(String.self, forKey: .lateFee) {
            lateFee = Double(lateFeeString)
        } else {
            lateFee = try container.decodeIfPresent(Double.self, forKey: .lateFee)
        }
        
        if let payrollFeeString = try? container.decode(String.self, forKey: .payrollProcessingFee) {
            payrollProcessingFee = Double(payrollFeeString)
        } else {
            payrollProcessingFee = try container.decodeIfPresent(Double.self, forKey: .payrollProcessingFee)
        }
        
        if let hrFeeString = try? container.decode(String.self, forKey: .hrServicesFee) {
            hrServicesFee = Double(hrFeeString)
        } else {
            hrServicesFee = try container.decodeIfPresent(Double.self, forKey: .hrServicesFee)
        }
        
        if let benefitsFeeString = try? container.decode(String.self, forKey: .benefitsAdministrationFee) {
            benefitsAdministrationFee = Double(benefitsFeeString)
        } else {
            benefitsAdministrationFee = try container.decodeIfPresent(Double.self, forKey: .benefitsAdministrationFee)
        }
        
        // Handle other fields
        currency = try container.decode(String.self, forKey: .currency)
        billingPeriodStart = try container.decodeIfPresent(String.self, forKey: .billingPeriodStart)
        billingPeriodEnd = try container.decodeIfPresent(String.self, forKey: .billingPeriodEnd)
        billingPeriodDisplay = try container.decodeIfPresent(String.self, forKey: .billingPeriodDisplay)
        totalEmployees = try container.decodeIfPresent(Int.self, forKey: .totalEmployees)
        overdue = try container.decodeIfPresent(Bool.self, forKey: .overdue)
        daysOverdue = try container.decodeIfPresent(Int.self, forKey: .daysOverdue)
        lineItems = try container.decodeIfPresent([InvoiceLineItem].self, forKey: .lineItems) ?? []
        employer = try container.decodeIfPresent(InvoiceEmployer.self, forKey: .employer)
    }
}

struct InvoiceEmployer: Codable {
    let id: Int
    let name: String
    let legalName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case legalName = "legal_name"
    }
}

struct InvoiceLineItem: Codable, Identifiable {
    let id: Int
    let description: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    let lineItemType: String?
    let serviceCategory: String?
    let employeeName: String?
    let employeeId: String?
    let serviceDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, quantity, serviceDate
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
        case lineItemType = "line_item_type"
        case serviceCategory = "service_category"
        case employeeName = "employee_name"
        case employeeId = "employee_id"
    }
    
    // Custom decoder to handle string prices from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        quantity = try container.decode(Int.self, forKey: .quantity)
        
        // Handle unit_price as string or double
        if let unitPriceString = try? container.decode(String.self, forKey: .unitPrice) {
            unitPrice = Double(unitPriceString) ?? 0.0
        } else {
            unitPrice = try container.decode(Double.self, forKey: .unitPrice)
        }
        
        // Handle total_price as string or double
        if let totalPriceString = try? container.decode(String.self, forKey: .totalPrice) {
            totalPrice = Double(totalPriceString) ?? 0.0
        } else {
            totalPrice = try container.decode(Double.self, forKey: .totalPrice)
        }
        
        // Handle optional fields
        lineItemType = try container.decodeIfPresent(String.self, forKey: .lineItemType)
        serviceCategory = try container.decodeIfPresent(String.self, forKey: .serviceCategory)
        employeeName = try container.decodeIfPresent(String.self, forKey: .employeeName)
        employeeId = try container.decodeIfPresent(String.self, forKey: .employeeId)
        serviceDate = try container.decodeIfPresent(String.self, forKey: .serviceDate)
    }
}

struct InvoiceListResponse: Codable {
    let invoices: [Invoice]
    let pagination: PaginationInfo
}

struct PaginationInfo: Codable {
    let currentPage: Int
    let perPage: Int
    let totalCount: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "page"
        case perPage = "per_page"
        case totalCount = "total_count"
        case totalPages = "total_pages"
    }
}

// MARK: - Additional Models

struct TimeOffRequest: Codable, Identifiable {
    let id: Int
    let employeeName: String?
    let employee: Employee?
    let startDate: Date
    let endDate: Date
    let leaveType: String
    let reason: String?
    let status: String
    let approvalStatus: String?
    let days: Int?
    let timeOffRecord: TimeOffRecord?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, reason, status, employee, days
        case employeeName = "employee_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case leaveType = "leave_type"
        case approvalStatus = "approval_status"
        case timeOffRecord = "time_off_record"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TimeOffRecord: Codable {
    let id: Int?
    let leaveType: String?
    let startDate: Date?
    let endDate: Date?
    let status: String?
    let balance: Int?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, status, balance
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Holiday: Codable, Identifiable {
    let id: Int
    let name: String
    let date: Date
    let country: String
    let holidayType: String?
    let applicableGroup: String?
    let isWeekend: Bool?
    let dayOfWeek: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, date, country
        case holidayType = "holiday_type"
        case applicableGroup = "applicable_group"
        case isWeekend = "is_weekend"
        case dayOfWeek = "day_of_week"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct HolidaysResponse: Codable {
    let holidays: [Holiday]
}

struct EmployeeListResponse: Codable {
    let employees: [Employee]
    let pagination: PaginationInfo
}

struct EmployeeListData: Codable {
    let employees: [Employee]
    let pagination: PaginationInfo
}

struct AnalyticsOverview: Codable {
    let totalRevenue: Double?
    let totalEmployees: Int
    let averageSalary: Double?
    let activeContracts: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalRevenue = "total_revenue"
        case totalEmployees = "total_employees"
        case averageSalary = "average_salary"
        case activeContracts = "active_contracts"
    }
}

struct TimeOffStats: Codable {
    let totalRequests: Int
    let pendingRequests: Int
    let approvedRequests: Int
    
    enum CodingKeys: String, CodingKey {
        case totalRequests = "total_requests"
        case pendingRequests = "pending_requests"
        case approvedRequests = "approved_requests"
    }
}

struct JobPostingsResponse: Codable {
    let jobPostings: [JobPosting]
    let pagination: PaginationInfo
    
    enum CodingKeys: String, CodingKey {
        case jobPostings = "job_postings"
        case pagination
    }
}

struct SystemAlert: Codable, Identifiable {
    let id: Int
    let type: String
    let message: String
    let timestamp: Date
}

// MARK: - Missing Response Types

struct EmployerProfileData: Codable {
    let employer: EmployerData
    let employer_user: EmployerUserData
    let profile_stats: ProfileStatsData
    
    enum CodingKeys: String, CodingKey {
        case employer
        case employer_user
        case profile_stats
    }
}

struct EmployerData: Codable {
    let id: Int
    let name: String?
    let legal_name: String?
    let address_line1: String?
    let address_city: String?
    let address_state: String?
    let address_zip: String?
    let full_address: String?
    let authorized_representative_name: String?
    let authorized_officer_name: String?
    let primary_email: String?
    let billing_email: String?
    let contact_email: String?
    let email: String?
    let stripe_customer_id: String?
    let total_employees: Int?
    let total_outstanding_amount: Double?
    let total_paid_amount: Double?
    let created_at: String
    let updated_at: String
}

struct EmployerUserData: Codable {
    let id: Int
    let email: String?
    let first_name: String?
    let last_name: String?
    let full_name: String?
    let employer_id: Int
    let created_at: String
    let updated_at: String
}

struct ProfileStatsData: Codable {
    let total_active_employees: Int
    let total_inactive_employees: Int
    let pending_time_off_requests: Int
    let approved_time_off_requests_this_month: Int
    let total_payroll_records: Int
    let recent_invoices_count: Int
    let outstanding_invoices_count: Int
}

struct TimeOffRequestListData: Codable {
    let timeOffRequests: [TimeOffRequest]
    let pagination: PaginationInfo
    
    enum CodingKeys: String, CodingKey {
        case timeOffRequests = "time_off_requests"
        case pagination
    }
}

struct TimeOffRequestResponse: Codable {
    let timeOffRequest: TimeOffRequest
    
    enum CodingKeys: String, CodingKey {
        case timeOffRequest = "time_off_request"
    }
}