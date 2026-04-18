import XCTest
@testable import Merot_Outsourcing

final class MerotOutsourcingTests: XCTestCase {

    // MARK: - Model Decoding Tests

    func testAdminUserDecoding() throws {
        let json = """
        {
            "id": 1,
            "email": "admin@merot.com",
            "user_type": "admin",
            "first_name": "John",
            "last_name": "Doe",
            "full_name": "John Doe",
            "roles": ["admin", "engineer"],
            "super_admin": true
        }
        """.data(using: .utf8)!

        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.email, "admin@merot.com")
        XCTAssertEqual(user.first_name, "John")
        XCTAssertEqual(user.last_name, "Doe")
        XCTAssertEqual(user.displayName, "John Doe")
        XCTAssertEqual(user.initials, "JD")
        XCTAssertEqual(user.roles?.count, 2)
        XCTAssertEqual(user.super_admin, true)
    }

    func testEmployeeDecoding() throws {
        let json = """
        {
            "id": 42,
            "employee_id": "EMP-001",
            "first_name": "Jane",
            "last_name": "Smith",
            "full_name": "Jane Smith",
            "email": "jane@example.com",
            "status": "active",
            "employee_type": "salaried",
            "department": "engineering",
            "department_name": "Engineering",
            "title": "Software Engineer",
            "employer": {"id": 1, "name": "Acme Corp"},
            "salary_detail": {"net_salary": 1500.0, "gross_salary": 2000.0, "currency": "EUR"},
            "created_at": "2024-01-15T10:00:00Z"
        }
        """.data(using: .utf8)!

        let employee = try JSONDecoder().decode(Employee.self, from: json)
        XCTAssertEqual(employee.id, 42)
        XCTAssertEqual(employee.employee_id, "EMP-001")
        XCTAssertEqual(employee.displayName, "Jane Smith")
        XCTAssertEqual(employee.initials, "JS")
        XCTAssertEqual(employee.employer?.name, "Acme Corp")
        XCTAssertEqual(employee.salary_detail?.currency, "EUR")
    }

    func testInvoiceDecoding() throws {
        let json = """
        {
            "id": 100,
            "employer_id": 5,
            "employer_name": "Test Corp",
            "invoice_number": "INV-2024-001",
            "issue_date": "2024-03-01",
            "due_date": "2024-03-31",
            "status": "sent",
            "currency": "USD",
            "total_amount": 5000.50,
            "overdue": false,
            "formatted_total": "$5,000.50"
        }
        """.data(using: .utf8)!

        let invoice = try JSONDecoder().decode(Invoice.self, from: json)
        XCTAssertEqual(invoice.id, 100)
        XCTAssertEqual(invoice.invoice_number, "INV-2024-001")
        XCTAssertEqual(invoice.status, "sent")
        XCTAssertEqual(invoice.total_amount?.value, 5000.50)
        XCTAssertEqual(invoice.overdue, false)
    }

    func testPayrollBatchDecoding() throws {
        let json = """
        {
            "id": 10,
            "month": "3",
            "year": 2024,
            "approved": true,
            "records_count": 15,
            "total_mkd_gross": 750000.0,
            "total_eur_gross": 12500.0
        }
        """.data(using: .utf8)!

        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.id, 10)
        XCTAssertEqual(batch.periodLabel, "March 2024")
        XCTAssertEqual(batch.approved, true)
        XCTAssertEqual(batch.records_count, 15)
    }

    func testJobPostingDecoding() throws {
        let json = """
        {
            "id": 5,
            "title": "Senior Developer",
            "status": "published",
            "department": "Engineering",
            "location": "Remote",
            "employment_type": "full_time",
            "applications_count": 8,
            "positions_available": 2,
            "positions_filled": 0,
            "created_at": "2024-02-01T10:00:00Z"
        }
        """.data(using: .utf8)!

        let posting = try JSONDecoder().decode(JobPosting.self, from: json)
        XCTAssertEqual(posting.id, 5)
        XCTAssertEqual(posting.title, "Senior Developer")
        XCTAssertEqual(posting.status, "published")
        XCTAssertEqual(posting.applications_count, 8)
    }

    func testDashboardStatsDecoding() throws {
        let json = """
        {
            "active_employees": 25,
            "clocked_in": 12,
            "on_leave": 3,
            "expiring_agreements": 2,
            "outstanding_invoices": 5,
            "employers_count": 8,
            "pending_time_off": 4
        }
        """.data(using: .utf8)!

        let stats = try JSONDecoder().decode(DashboardStats.self, from: json)
        XCTAssertEqual(stats.active_employees, 25)
        XCTAssertEqual(stats.clocked_in, 12)
        XCTAssertEqual(stats.on_leave, 3)
        XCTAssertEqual(stats.pending_time_off, 4)
    }

    func testTimeOffRequestDecoding() throws {
        let json = """
        {
            "id": 15,
            "employee": {"id": 1, "full_name": "Test User", "employee_id": "EMP-001"},
            "start_date": "2024-04-01",
            "end_date": "2024-04-05",
            "days": 5,
            "approval_status": "pending",
            "time_off_record": {"id": 1, "name": "Annual Leave", "leave_type": "annual"},
            "created_at": "2024-03-20T10:00:00Z"
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(TimeOffRequest.self, from: json)
        XCTAssertEqual(request.id, 15)
        XCTAssertEqual(request.days, 5)
        XCTAssertEqual(request.approval_status, "pending")
        XCTAssertEqual(request.employee?.full_name, "Test User")
    }

    func testHolidayDecoding() throws {
        let json = """
        {
            "id": 1,
            "name": "New Year",
            "date": "2024-01-01",
            "holiday_type": "national",
            "applicable_country": "MK",
            "is_weekend": false,
            "day_of_week": "Monday"
        }
        """.data(using: .utf8)!

        let holiday = try JSONDecoder().decode(Holiday.self, from: json)
        XCTAssertEqual(holiday.id, 1)
        XCTAssertEqual(holiday.name, "New Year")
        XCTAssertEqual(holiday.applicable_country, "MK")
        XCTAssertNotNil(holiday.dateValue)
    }

    func testEmployeeAgreementDecoding() throws {
        let json = """
        {
            "id": 20,
            "employee_user_id": 5,
            "employee_name": "Test Employee",
            "status": "active",
            "signature_status": "completed",
            "contract_type": "indefinite",
            "country": "north_macedonia",
            "term_months": 12,
            "net_compensation": 1500.0,
            "currency": "EUR"
        }
        """.data(using: .utf8)!

        let agreement = try JSONDecoder().decode(EmployeeAgreement.self, from: json)
        XCTAssertEqual(agreement.id, 20)
        XCTAssertEqual(agreement.status, "active")
        XCTAssertEqual(agreement.signature_status, "completed")
        XCTAssertEqual(agreement.net_compensation?.value, 1500.0)
    }

    func testContactRequestDecoding() throws {
        let json = """
        {
            "id": 3,
            "name": "John Client",
            "email": "john@client.com",
            "company_name": "Client LLC",
            "message": "I need HR services",
            "status": "pending",
            "created_at": "2024-03-15T10:00:00Z"
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(ContactRequest.self, from: json)
        XCTAssertEqual(request.id, 3)
        XCTAssertEqual(request.name, "John Client")
        XCTAssertEqual(request.status, "pending")
    }

    func testPersonalInfoRequestDecoding() throws {
        let json = """
        {
            "id": 7,
            "status": "submitted",
            "employee": {"id": 10, "full_name": "Test Employee", "email": "test@emp.com"},
            "submitted_data": {"first_name": "Updated", "phone_number": "555-0123"},
            "current_data": {"first_name": "Original", "phone_number": "555-0000"},
            "changed_fields": ["first_name", "phone_number"],
            "created_at": "2024-03-20T10:00:00Z"
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(PersonalInfoRequest.self, from: json)
        XCTAssertEqual(request.id, 7)
        XCTAssertEqual(request.status, "submitted")
        XCTAssertEqual(request.changed_fields?.count, 2)
        XCTAssertEqual(request.submitted_data?["first_name"], "Updated")
    }

    // MARK: - Utility Tests

    func testFormatMoney() {
        let val1: Double? = 1234.56
        let val2: Double? = 0.0
        let val3: Double? = nil
        XCTAssertEqual(formatMoney(val1), "1,234.56")
        XCTAssertEqual(formatMoney(val2), "0.00")
        XCTAssertEqual(formatMoney(val3), "-")
        XCTAssertEqual(formatMoney(val1, currency: "EUR"), "1,234.56 EUR")
    }

    func testFormatDate() {
        XCTAssertEqual(formatDate("2024-03-15"), "15.03.2024")
        XCTAssertEqual(formatDate("2024-03-15T10:00:00Z"), "15.03.2024")
        XCTAssertEqual(formatDate(nil), "-")
        XCTAssertEqual(formatDate(""), "-")
    }

    func testFormatDateShort() {
        XCTAssertEqual(formatDateShort("2024-03-15"), "15.03")
        XCTAssertEqual(formatDateShort(nil), "-")
    }

    // MARK: - FlexDouble Tests

    func testFlexDoubleFromDouble() throws {
        let json = "42.5".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 42.5)
    }

    func testFlexDoubleFromString() throws {
        let json = "\"42.5\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 42.5)
    }

    func testFlexDoubleFromInt() throws {
        let json = "42".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 42.0)
    }

    // MARK: - Keychain Tests

    func testKeychainSaveAndRead() {
        let key = "test_key_\(UUID().uuidString)"
        KeychainHelper.save(key: key, value: "test_value")
        XCTAssertEqual(KeychainHelper.read(key: key), "test_value")
        KeychainHelper.delete(key: key)
        XCTAssertNil(KeychainHelper.read(key: key))
    }

    // MARK: - PayrollBatch Period Label

    func testPayrollBatchPeriodLabel() throws {
        let json = """
        {"id": 1, "month": "6", "year": 2024}
        """.data(using: .utf8)!

        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.periodLabel, "June 2024")
    }

    func testPayrollBatchPeriodLabelInvalid() throws {
        let json = """
        {"id": 1, "month": "13", "year": 2024}
        """.data(using: .utf8)!

        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.periodLabel, "13 2024")
    }
}
