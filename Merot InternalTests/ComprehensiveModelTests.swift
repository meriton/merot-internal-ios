import XCTest
@testable import Merot_Internal

final class ComprehensiveModelTests: XCTestCase {

    // MARK: - FlexDouble Tests

    func testFlexDoubleFromDouble() throws {
        let json = "42.5".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 42.5)
    }

    func testFlexDoubleFromInt() throws {
        let json = "42".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 42.0)
    }

    func testFlexDoubleFromString() throws {
        let json = "\"123.45\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 123.45)
    }

    func testFlexDoubleFromStringZero() throws {
        let json = "\"0\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 0.0)
    }

    func testFlexDoubleFromEmptyString() throws {
        let json = "\"\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 0.0)
    }

    func testFlexDoubleFromNegativeString() throws {
        let json = "\"-99.5\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, -99.5)
    }

    func testFlexDoubleFromNegativeDouble() throws {
        let json = "-15.75".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, -15.75)
    }

    func testFlexDoubleFromZeroDouble() throws {
        let json = "0.0".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 0.0)
    }

    func testFlexDoubleFromLargeNumber() throws {
        let json = "999999.99".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 999999.99)
    }

    func testFlexDoubleFromNull() throws {
        // When FlexDouble is optional and JSON has null
        let json = "{\"amount\": null}".data(using: .utf8)!
        struct Wrapper: Codable { let amount: FlexDouble? }
        let decoded = try JSONDecoder().decode(Wrapper.self, from: json)
        XCTAssertNil(decoded.amount)
    }

    func testFlexDoubleComparableLessThan() {
        let a = FlexDouble(10.0)
        let b = FlexDouble(20.0)
        XCTAssertTrue(a < b)
        XCTAssertFalse(b < a)
    }

    func testFlexDoubleComparableEqual() {
        let a = FlexDouble(10.0)
        let b = FlexDouble(10.0)
        XCTAssertEqual(a, b)
    }

    func testFlexDoubleGreaterThanInt() {
        let flex = FlexDouble(5.0)
        XCTAssertTrue(flex > 3)
        XCTAssertFalse(flex > 10)
    }

    func testFlexDoubleGreaterThanDouble() {
        let flex = FlexDouble(5.5)
        XCTAssertTrue(flex > 3.0)
        XCTAssertFalse(flex > 10.0)
    }

    func testFlexDoubleInitDirect() {
        let flex = FlexDouble(42.0)
        XCTAssertEqual(flex.value, 42.0)
    }

    func testFlexDoubleEncoding() throws {
        let flex = FlexDouble(99.5)
        let data = try JSONEncoder().encode(flex)
        let decoded = try JSONDecoder().decode(FlexDouble.self, from: data)
        XCTAssertEqual(decoded.value, 99.5)
    }

    func testFlexDoubleFromStringInteger() throws {
        let json = "\"42\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 42.0)
    }

    func testFlexDoubleFromNonNumericString() throws {
        let json = "\"abc\"".data(using: .utf8)!
        let flex = try JSONDecoder().decode(FlexDouble.self, from: json)
        XCTAssertEqual(flex.value, 0.0, "Non-numeric strings should decode to 0")
    }

    // MARK: - AdminUser / Login Tests

    func testAdminUserDecodingMinimal() throws {
        let json = """
        {"id": 1, "email": "admin@merot.com"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.email, "admin@merot.com")
        XCTAssertNil(user.first_name)
        XCTAssertNil(user.last_name)
        XCTAssertNil(user.roles)
        XCTAssertNil(user.super_admin)
    }

    func testAdminUserDisplayNameFromFullName() throws {
        let json = """
        {"id": 1, "email": "a@b.com", "full_name": "John Doe", "first_name": "John", "last_name": "Doe"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.displayName, "John Doe")
    }

    func testAdminUserDisplayNameFallback() throws {
        let json = """
        {"id": 1, "email": "a@b.com", "first_name": "Jane", "last_name": "Smith"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.displayName, "Jane Smith")
    }

    func testAdminUserDisplayNameOnlyFirst() throws {
        let json = """
        {"id": 1, "email": "a@b.com", "first_name": "Jane"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.displayName, "Jane")
    }

    func testAdminUserDisplayNameEmpty() throws {
        let json = """
        {"id": 1, "email": "a@b.com"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.displayName, "")
    }

    func testAdminUserInitials() throws {
        let json = """
        {"id": 1, "email": "a@b.com", "first_name": "jane", "last_name": "smith"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.initials, "JS")
    }

    func testAdminUserInitialsNoName() throws {
        let json = """
        {"id": 1, "email": "a@b.com"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(AdminUser.self, from: json)
        XCTAssertEqual(user.initials, "")
    }

    func testLoginResponseDecoding() throws {
        let json = """
        {
            "data": {
                "access_token": "abc123",
                "refresh_token": "ref456",
                "user": {"id": 1, "email": "admin@merot.com", "first_name": "Admin", "last_name": "User"},
                "expires_at": "2024-12-31T23:59:59Z"
            },
            "success": true,
            "message": "Login successful"
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(LoginResponse.self, from: json)
        XCTAssertEqual(resp.success, true)
        XCTAssertEqual(resp.data?.access_token, "abc123")
        XCTAssertEqual(resp.data?.refresh_token, "ref456")
        XCTAssertEqual(resp.data?.user.id, 1)
        XCTAssertEqual(resp.data?.user.email, "admin@merot.com")
        XCTAssertEqual(resp.data?.expires_at, "2024-12-31T23:59:59Z")
    }

    func testProfileResponseDecoding() throws {
        let json = """
        {
            "data": {"user": {"id": 5, "email": "user@merot.com", "roles": ["manager"], "super_admin": false}},
            "success": true
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(ProfileResponse.self, from: json)
        XCTAssertEqual(resp.data?.user.id, 5)
        XCTAssertEqual(resp.data?.user.roles, ["manager"])
        XCTAssertEqual(resp.data?.user.super_admin, false)
    }

    // MARK: - Employee Tests

    func testEmployeeDecodingFull() throws {
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
            "salary_detail": {"net_salary": "1500.0", "gross_salary": 2000, "currency": "EUR"},
            "created_at": "2024-01-15T10:00:00Z"
        }
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(Employee.self, from: json)
        XCTAssertEqual(emp.id, 42)
        XCTAssertEqual(emp.employee_id, "EMP-001")
        XCTAssertEqual(emp.displayName, "Jane Smith")
        XCTAssertEqual(emp.initials, "JS")
        XCTAssertEqual(emp.employer?.name, "Acme Corp")
        XCTAssertEqual(emp.salary_detail?.net_salary?.value, 1500.0)
        XCTAssertEqual(emp.salary_detail?.gross_salary?.value, 2000.0)
        XCTAssertEqual(emp.salary_detail?.currency, "EUR")
    }

    func testEmployeeDecodingMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(Employee.self, from: json)
        XCTAssertEqual(emp.id, 1)
        XCTAssertNil(emp.employee_id)
        XCTAssertNil(emp.email)
        XCTAssertNil(emp.status)
        XCTAssertNil(emp.employer)
        XCTAssertNil(emp.salary_detail)
    }

    func testEmployeeDisplayNameFallback() throws {
        let json = """
        {"id": 1, "first_name": "John", "last_name": "Doe"}
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(Employee.self, from: json)
        XCTAssertEqual(emp.displayName, "John Doe")
    }

    func testEmployeeSalaryWithFlexDoubleString() throws {
        let json = """
        {
            "id": 1,
            "salary_detail": {"net_salary": "1200.50", "gross_salary": "1800.75", "currency": "MKD"}
        }
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(Employee.self, from: json)
        XCTAssertEqual(emp.salary_detail?.net_salary?.value, 1200.50)
        XCTAssertEqual(emp.salary_detail?.gross_salary?.value, 1800.75)
    }

    func testEmployeesListResponseDecoding() throws {
        let json = """
        {
            "data": {
                "employees": [
                    {"id": 1, "full_name": "Alice"},
                    {"id": 2, "full_name": "Bob"}
                ],
                "meta": {"page": 1, "per_page": 25, "total_count": 2, "total_pages": 1}
            },
            "success": true
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(EmployeesListResponse.self, from: json)
        XCTAssertEqual(resp.data?.employees.count, 2)
        XCTAssertEqual(resp.data?.meta?.total_count, 2)
    }

    func testEmployeeFullJSONDecoding() throws {
        let json = """
        {
            "id": 10,
            "employee_id": "EMP-010",
            "first_name": "Test",
            "last_name": "User",
            "full_name": "Test User",
            "email": "test@corp.com",
            "personal_email": "test@personal.com",
            "phone_number": "+1234567890",
            "status": "active",
            "country": "north_macedonia",
            "country_name": "North Macedonia",
            "city": "Skopje"
        }
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(EmployeeFullJSON.self, from: json)
        XCTAssertEqual(emp.id, 10)
        XCTAssertEqual(emp.displayName, "Test User")
        XCTAssertEqual(emp.initials, "TU")
        XCTAssertEqual(emp.country_name, "North Macedonia")
    }

    func testSalaryDetailDecoding() throws {
        let json = """
        {
            "id": 1,
            "base_salary": 1200,
            "net_salary": "1100.50",
            "gross_salary": 1500.75,
            "currency": "EUR",
            "bank_name": "NLB",
            "seniority": "5",
            "merot_fee": 200
        }
        """.data(using: .utf8)!
        let detail = try JSONDecoder().decode(SalaryDetail.self, from: json)
        XCTAssertEqual(detail.base_salary?.value, 1200.0)
        XCTAssertEqual(detail.net_salary?.value, 1100.50)
        XCTAssertEqual(detail.gross_salary?.value, 1500.75)
        XCTAssertEqual(detail.seniority?.value, 5.0)
        XCTAssertEqual(detail.merot_fee?.value, 200.0)
    }

    func testEmploymentRecordDecoding() throws {
        let json = """
        {"id": 1, "employer_id": 5, "employer_name": "Corp", "start_date": "2024-01-01", "employment_status": "active"}
        """.data(using: .utf8)!
        let record = try JSONDecoder().decode(EmploymentRecord.self, from: json)
        XCTAssertEqual(record.id, 1)
        XCTAssertEqual(record.employer_name, "Corp")
        XCTAssertNil(record.end_date)
    }

    // MARK: - Invoice Tests

    func testInvoiceDecodingFull() throws {
        let json = """
        {
            "id": 100,
            "employer_id": 5,
            "employer_name": "Test Corp",
            "employer_emails": ["billing@test.com", "admin@test.com"],
            "invoice_number": "INV-2024-001",
            "issue_date": "2024-03-01",
            "due_date": "2024-03-31",
            "billing_period_start": "2024-02-01",
            "billing_period_end": "2024-02-29",
            "status": "sent",
            "currency": "EUR",
            "subtotal": "4500.00",
            "tax_amount": 500.50,
            "late_fee": 0,
            "discount_amount": "0",
            "total_amount": 5000.50,
            "total_employees": 10,
            "overdue": false,
            "days_overdue": 0,
            "formatted_total": "5,000.50 EUR"
        }
        """.data(using: .utf8)!
        let inv = try JSONDecoder().decode(Invoice.self, from: json)
        XCTAssertEqual(inv.id, 100)
        XCTAssertEqual(inv.invoice_number, "INV-2024-001")
        XCTAssertEqual(inv.subtotal?.value, 4500.0)
        XCTAssertEqual(inv.tax_amount?.value, 500.50)
        XCTAssertEqual(inv.total_amount?.value, 5000.50)
        XCTAssertEqual(inv.late_fee?.value, 0.0)
        XCTAssertEqual(inv.discount_amount?.value, 0.0)
        XCTAssertEqual(inv.total_employees, 10)
        XCTAssertEqual(inv.overdue, false)
        XCTAssertEqual(inv.employer_emails?.count, 2)
    }

    func testInvoiceDecodingMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let inv = try JSONDecoder().decode(Invoice.self, from: json)
        XCTAssertEqual(inv.id, 1)
        XCTAssertNil(inv.invoice_number)
        XCTAssertNil(inv.total_amount)
        XCTAssertNil(inv.overdue)
    }

    func testInvoiceLineItemDecoding() throws {
        let json = """
        {
            "id": 50,
            "description": "Monthly service fee",
            "line_item_type": "service",
            "service_category": "hr_management",
            "quantity": "1",
            "unit_price": 500.00,
            "total_price": "500.00",
            "employee_name": "John Doe",
            "employee_id": "EMP-001",
            "hours_worked": 160,
            "hourly_rate": "3.125"
        }
        """.data(using: .utf8)!
        let item = try JSONDecoder().decode(InvoiceLineItem.self, from: json)
        XCTAssertEqual(item.id, 50)
        XCTAssertEqual(item.description, "Monthly service fee")
        XCTAssertEqual(item.quantity?.value, 1.0)
        XCTAssertEqual(item.unit_price?.value, 500.0)
        XCTAssertEqual(item.total_price?.value, 500.0)
        XCTAssertEqual(item.hours_worked?.value, 160.0)
        XCTAssertEqual(item.hourly_rate?.value, 3.125)
    }

    func testInvoiceTransactionDecoding() throws {
        let json = """
        {
            "id": 10,
            "amount": 5000.50,
            "payment_method": "bank_transfer",
            "status": "completed",
            "transaction_type": "payment",
            "currency": "EUR",
            "reference_number": "REF-001",
            "processed_at": "2024-03-15T14:00:00Z"
        }
        """.data(using: .utf8)!
        let tx = try JSONDecoder().decode(InvoiceTransaction.self, from: json)
        XCTAssertEqual(tx.id, 10)
        XCTAssertEqual(tx.amount?.value, 5000.50)
        XCTAssertEqual(tx.payment_method, "bank_transfer")
        XCTAssertEqual(tx.status, "completed")
    }

    func testInvoiceStatsDecoding() throws {
        let json = """
        {
            "period_label": "March 2024",
            "total_draft": 1000,
            "total_approved": "2500.50",
            "total_outstanding": 3000,
            "overdue_count": 2,
            "total_paid": "15000",
            "total_fees": 500.25
        }
        """.data(using: .utf8)!
        let stats = try JSONDecoder().decode(InvoiceStats.self, from: json)
        XCTAssertEqual(stats.period_label, "March 2024")
        XCTAssertEqual(stats.total_draft?.value, 1000.0)
        XCTAssertEqual(stats.total_approved?.value, 2500.50)
        XCTAssertEqual(stats.total_paid?.value, 15000.0)
        XCTAssertEqual(stats.total_fees?.value, 500.25)
        XCTAssertEqual(stats.overdue_count, 2)
    }

    func testInvoiceDetailDecoding() throws {
        let json = """
        {
            "invoice": {"id": 1, "invoice_number": "INV-001", "status": "draft"},
            "line_items": [{"id": 1, "description": "Item 1", "total_price": 100}],
            "transactions": []
        }
        """.data(using: .utf8)!
        let detail = try JSONDecoder().decode(InvoiceDetail.self, from: json)
        XCTAssertEqual(detail.invoice.id, 1)
        XCTAssertEqual(detail.line_items?.count, 1)
        XCTAssertEqual(detail.transactions?.count, 0)
    }

    // MARK: - Employer Tests

    func testEmployerDecodingFull() throws {
        let json = """
        {
            "id": 1,
            "name": "Acme Corp",
            "legal_name": "Acme Corporation LLC",
            "primary_email": "info@acme.com",
            "status": "active",
            "address_city": "New York",
            "employee_count": 25
        }
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(Employer.self, from: json)
        XCTAssertEqual(emp.id, 1)
        XCTAssertEqual(emp.name, "Acme Corp")
        XCTAssertEqual(emp.legal_name, "Acme Corporation LLC")
        XCTAssertEqual(emp.employee_count, 25)
    }

    func testEmployerMinimal() throws {
        let json = """
        {"id": 99}
        """.data(using: .utf8)!
        let emp = try JSONDecoder().decode(Employer.self, from: json)
        XCTAssertEqual(emp.id, 99)
        XCTAssertNil(emp.name)
        XCTAssertNil(emp.employee_count)
    }

    func testEmployersListResponseDecoding() throws {
        let json = """
        {
            "data": {
                "employers": [
                    {"id": 1, "name": "Corp A"},
                    {"id": 2, "name": "Corp B"},
                    {"id": 3, "name": "Corp C"}
                ],
                "meta": {"page": 1, "per_page": 25, "total_count": 3, "total_pages": 1}
            },
            "success": true
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(EmployersListResponse.self, from: json)
        XCTAssertEqual(resp.data?.employers.count, 3)
        XCTAssertEqual(resp.data?.meta?.total_count, 3)
    }

    func testEmployerDetailDecoding() throws {
        let json = """
        {
            "employer": {
                "id": 1,
                "name": "Test Corp",
                "legal_name": "Test Corporation",
                "primary_email": "info@test.com",
                "billing_email": "billing@test.com",
                "phone": "+1234567890",
                "status": "active",
                "industry": "technology",
                "company_size": "50-100",
                "address_city": "Skopje",
                "address_country": "MK",
                "tax_number": "MK123456",
                "website": "https://test.com"
            },
            "employee_count": 15,
            "total_invoiced": "45000.50",
            "active_employments": [
                {"id": 1, "employee_id": 10, "employee_name": "John", "start_date": "2024-01-01", "employment_status": "active"}
            ]
        }
        """.data(using: .utf8)!
        let detail = try JSONDecoder().decode(EmployerDetail.self, from: json)
        XCTAssertEqual(detail.employer.id, 1)
        XCTAssertEqual(detail.employer.name, "Test Corp")
        XCTAssertEqual(detail.employer.industry, "technology")
        XCTAssertEqual(detail.employee_count, 15)
        XCTAssertEqual(detail.total_invoiced?.value, 45000.50)
        XCTAssertEqual(detail.active_employments?.count, 1)
    }

    // MARK: - PayrollBatch Tests

    func testPayrollBatchFullDecoding() throws {
        let json = """
        {
            "id": 10,
            "month": "3",
            "year": 2024,
            "conversion_rate": "61.5",
            "working_hours": 176,
            "approved": true,
            "approved_at": "2024-04-01T10:00:00Z",
            "records_count": 15,
            "total_mkd_gross": "750000.0",
            "total_eur_gross": 12500.0
        }
        """.data(using: .utf8)!
        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.id, 10)
        XCTAssertEqual(batch.periodLabel, "March 2024")
        XCTAssertEqual(batch.approved, true)
        XCTAssertEqual(batch.records_count, 15)
        XCTAssertEqual(batch.conversion_rate?.value, 61.5)
        XCTAssertEqual(batch.working_hours?.value, 176.0)
        XCTAssertEqual(batch.total_mkd_gross?.value, 750000.0)
        XCTAssertEqual(batch.total_eur_gross?.value, 12500.0)
    }

    func testPayrollBatchPeriodLabelAllMonths() throws {
        let months = ["January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        for (i, name) in months.enumerated() {
            let json = """
            {"id": 1, "month": "\(i + 1)", "year": 2024}
            """.data(using: .utf8)!
            let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
            XCTAssertEqual(batch.periodLabel, "\(name) 2024", "Month \(i + 1) should be \(name)")
        }
    }

    func testPayrollBatchPeriodLabelInvalidMonth() throws {
        let json = """
        {"id": 1, "month": "13", "year": 2024}
        """.data(using: .utf8)!
        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.periodLabel, "13 2024")
    }

    func testPayrollBatchPeriodLabelMissingMonth() throws {
        let json = """
        {"id": 1, "year": 2024}
        """.data(using: .utf8)!
        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.periodLabel, " 2024")
    }

    func testPayrollBatchPeriodLabelMissingYear() throws {
        let json = """
        {"id": 1, "month": "6"}
        """.data(using: .utf8)!
        let batch = try JSONDecoder().decode(PayrollBatch.self, from: json)
        XCTAssertEqual(batch.periodLabel, "6 0")
    }

    func testPayrollRecordDecoding() throws {
        let json = """
        {
            "id": 1,
            "employee_user_id": 10,
            "employee_name": "Test Employee",
            "employee_id": "EMP-010",
            "country": "MK",
            "employment_type": "full_time",
            "base_salary": "30000",
            "net_salary": "25000.50",
            "gross_salary": 35000,
            "personal_tax": "3000",
            "overtime_hours": 0,
            "overtime_pay": "0",
            "bonus_payment": 5000
        }
        """.data(using: .utf8)!
        let record = try JSONDecoder().decode(PayrollRecord.self, from: json)
        XCTAssertEqual(record.id, 1)
        XCTAssertEqual(record.employee_name, "Test Employee")
        XCTAssertEqual(record.base_salary?.value, 30000.0)
        XCTAssertEqual(record.net_salary?.value, 25000.50)
        XCTAssertEqual(record.gross_salary?.value, 35000.0)
        XCTAssertEqual(record.personal_tax?.value, 3000.0)
        XCTAssertEqual(record.bonus_payment?.value, 5000.0)
    }

    // MARK: - JobPosting Tests

    func testJobPostingDecodingFull() throws {
        let json = """
        {
            "id": 5,
            "title": "Senior Developer",
            "status": "published",
            "employer_id": 1,
            "employer": {"id": 1, "name": "Tech Corp"},
            "department": "Engineering",
            "location": "Remote",
            "employment_type": "full_time",
            "experience_level": "senior",
            "salary_min": "50000",
            "salary_max": 80000,
            "salary_currency": "EUR",
            "positions_available": 2,
            "positions_filled": 0,
            "applications_count": 8,
            "published_at": "2024-02-01T10:00:00Z",
            "description": "Job description here",
            "requirements": "5+ years experience"
        }
        """.data(using: .utf8)!
        let posting = try JSONDecoder().decode(JobPosting.self, from: json)
        XCTAssertEqual(posting.id, 5)
        XCTAssertEqual(posting.title, "Senior Developer")
        XCTAssertEqual(posting.salary_min?.value, 50000.0)
        XCTAssertEqual(posting.salary_max?.value, 80000.0)
        XCTAssertEqual(posting.employer?.name, "Tech Corp")
        XCTAssertEqual(posting.applications_count, 8)
        XCTAssertEqual(posting.positions_available, 2)
    }

    func testJobPostingMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let posting = try JSONDecoder().decode(JobPosting.self, from: json)
        XCTAssertEqual(posting.id, 1)
        XCTAssertNil(posting.title)
        XCTAssertNil(posting.salary_min)
        XCTAssertNil(posting.salary_max)
    }

    func testJobPostingWithCreatedBy() throws {
        let json = """
        {"id": 1, "created_by": {"id": 5, "full_name": "Admin User"}}
        """.data(using: .utf8)!
        let posting = try JSONDecoder().decode(JobPosting.self, from: json)
        XCTAssertEqual(posting.created_by?.id, 5)
        XCTAssertEqual(posting.created_by?.full_name, "Admin User")
    }

    // MARK: - JobApplication Tests

    func testJobApplicationDecodingFull() throws {
        let json = """
        {
            "id": 20,
            "full_name": "John Applicant",
            "first_name": "John",
            "last_name": "Applicant",
            "email": "john@example.com",
            "phone": "+1234567890",
            "status": "screening",
            "job_posting": {"id": 5, "title": "Senior Developer", "employer_name": "Tech Corp"},
            "events_count": 3,
            "can_be_converted": false,
            "cover_letter": "I am interested...",
            "linkedin_url": "https://linkedin.com/in/john",
            "has_resume": true,
            "created_at": "2024-03-01T10:00:00Z"
        }
        """.data(using: .utf8)!
        let app = try JSONDecoder().decode(JobApplication.self, from: json)
        XCTAssertEqual(app.id, 20)
        XCTAssertEqual(app.full_name, "John Applicant")
        XCTAssertEqual(app.status, "screening")
        XCTAssertEqual(app.job_posting?.title, "Senior Developer")
        XCTAssertEqual(app.events_count, 3)
        XCTAssertEqual(app.can_be_converted, false)
        XCTAssertEqual(app.has_resume, true)
    }

    func testJobApplicationBriefDecoding() throws {
        let json = """
        {"id": 1, "full_name": "Test User", "email": "test@test.com", "status": "new", "events_count": 0}
        """.data(using: .utf8)!
        let brief = try JSONDecoder().decode(JobApplicationBrief.self, from: json)
        XCTAssertEqual(brief.id, 1)
        XCTAssertEqual(brief.status, "new")
    }

    func testJobApplicationEventDecoding() throws {
        let json = """
        {
            "id": 1,
            "event_type": "interview_scheduled",
            "notes": "Technical interview",
            "scheduled_date": "2024-04-01",
            "interview_type": "technical",
            "location": "Online",
            "is_private": false,
            "previous_status": "screening",
            "new_status": "interviewing",
            "created_by": {"id": 1, "full_name": "HR Manager"},
            "created_at": "2024-03-20T10:00:00Z"
        }
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(JobApplicationEvent.self, from: json)
        XCTAssertEqual(event.id, 1)
        XCTAssertEqual(event.event_type, "interview_scheduled")
        XCTAssertEqual(event.interview_type, "technical")
        XCTAssertEqual(event.is_private, false)
        XCTAssertEqual(event.created_by?.full_name, "HR Manager")
    }

    // MARK: - Agreement Tests

    func testEmployeeAgreementDecodingFull() throws {
        let json = """
        {
            "id": 20,
            "employee_user_id": 5,
            "employee_name": "Test Employee",
            "status": "active",
            "signature_status": "completed",
            "contract_type": "indefinite",
            "contract_type_display": "Indefinite",
            "employment_type": "full_time",
            "employment_type_display": "Full Time",
            "country": "north_macedonia",
            "country_display": "North Macedonia",
            "legal_entity": "merot_mk",
            "legal_entity_display": "Merot MK",
            "effective_date": "2024-01-01",
            "start_date": "2024-01-01",
            "end_date": null,
            "term_months": 12,
            "auto_renewal": true,
            "net_compensation": "1500.0",
            "currency": "EUR",
            "job_position": "Software Engineer",
            "is_trial": false,
            "has_signed_document": true,
            "addendums_count": 2
        }
        """.data(using: .utf8)!
        let agr = try JSONDecoder().decode(EmployeeAgreement.self, from: json)
        XCTAssertEqual(agr.id, 20)
        XCTAssertEqual(agr.status, "active")
        XCTAssertEqual(agr.signature_status, "completed")
        XCTAssertEqual(agr.contract_type, "indefinite")
        XCTAssertEqual(agr.net_compensation?.value, 1500.0)
        XCTAssertEqual(agr.auto_renewal, true)
        XCTAssertEqual(agr.is_trial, false)
        XCTAssertEqual(agr.has_signed_document, true)
        XCTAssertEqual(agr.addendums_count, 2)
        XCTAssertNil(agr.end_date)
    }

    func testEmployeeAgreementMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let agr = try JSONDecoder().decode(EmployeeAgreement.self, from: json)
        XCTAssertEqual(agr.id, 1)
        XCTAssertNil(agr.status)
        XCTAssertNil(agr.net_compensation)
    }

    func testServiceAgreementDecodingFull() throws {
        let json = """
        {
            "id": 30,
            "employer_id": 5,
            "employer_name": "Client Corp",
            "status": "active",
            "signature_status": "completed",
            "effective_date": "2024-01-01",
            "term_months": 24,
            "auto_renewal": true,
            "base_fee_per_employee": "200.00",
            "payment_terms_days": 30,
            "has_signed_document": true,
            "addendums_count": 1
        }
        """.data(using: .utf8)!
        let agr = try JSONDecoder().decode(ServiceAgreement.self, from: json)
        XCTAssertEqual(agr.id, 30)
        XCTAssertEqual(agr.employer_name, "Client Corp")
        XCTAssertEqual(agr.base_fee_per_employee?.value, 200.0)
        XCTAssertEqual(agr.payment_terms_days, 30)
        XCTAssertEqual(agr.auto_renewal, true)
    }

    func testServiceAgreementMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let agr = try JSONDecoder().decode(ServiceAgreement.self, from: json)
        XCTAssertEqual(agr.id, 1)
        XCTAssertNil(agr.employer_name)
        XCTAssertNil(agr.base_fee_per_employee)
    }

    // MARK: - TimeOffRequest Tests

    func testTimeOffRequestDecodingFull() throws {
        let json = """
        {
            "id": 15,
            "employee": {"id": 1, "full_name": "Test User", "employee_id": "EMP-001", "department": "Engineering"},
            "start_date": "2024-04-01",
            "end_date": "2024-04-05",
            "days": 5,
            "approval_status": "pending",
            "time_off_record": {"id": 1, "name": "Annual Leave", "leave_type": "annual", "balance": 15, "total_days": "20"},
            "created_at": "2024-03-20T10:00:00Z"
        }
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(TimeOffRequest.self, from: json)
        XCTAssertEqual(req.id, 15)
        XCTAssertEqual(req.days, 5)
        XCTAssertEqual(req.approval_status, "pending")
        XCTAssertEqual(req.employee?.full_name, "Test User")
        XCTAssertEqual(req.employee?.department, "Engineering")
        XCTAssertEqual(req.time_off_record?.name, "Annual Leave")
        XCTAssertEqual(req.time_off_record?.balance?.value, 15.0)
        XCTAssertEqual(req.time_off_record?.total_days?.value, 20.0)
    }

    func testTimeOffRequestMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(TimeOffRequest.self, from: json)
        XCTAssertEqual(req.id, 1)
        XCTAssertNil(req.employee)
        XCTAssertNil(req.days)
        XCTAssertNil(req.time_off_record)
    }

    func testTimeOffListResponseDecoding() throws {
        let json = """
        {
            "data": {
                "time_off_requests": [
                    {"id": 1, "days": 3, "approval_status": "approved"},
                    {"id": 2, "days": 1, "approval_status": "pending"}
                ],
                "meta": {"page": 1, "per_page": 25, "total_count": 2, "total_pages": 1}
            },
            "success": true
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(TimeOffListResponse.self, from: json)
        XCTAssertEqual(resp.data?.time_off_requests.count, 2)
    }

    // MARK: - PersonalInfoRequest Tests

    func testPersonalInfoRequestDecodingFull() throws {
        let json = """
        {
            "id": 7,
            "status": "submitted",
            "token": "abc123",
            "employee": {"id": 10, "full_name": "Test Employee", "email": "test@emp.com", "employee_id": "EMP-010"},
            "reviewer": {"id": 1, "full_name": "Admin"},
            "rejection_comment": null,
            "submitted_data": {"first_name": "Updated", "phone_number": "555-0123"},
            "current_data": {"first_name": "Original", "phone_number": "555-0000"},
            "changed_fields": ["first_name", "phone_number"],
            "has_photo_changes": false,
            "created_at": "2024-03-20T10:00:00Z"
        }
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(PersonalInfoRequest.self, from: json)
        XCTAssertEqual(req.id, 7)
        XCTAssertEqual(req.status, "submitted")
        XCTAssertEqual(req.token, "abc123")
        XCTAssertEqual(req.employee?.full_name, "Test Employee")
        XCTAssertEqual(req.employee?.employee_id, "EMP-010")
        XCTAssertEqual(req.reviewer?.full_name, "Admin")
        XCTAssertNil(req.rejection_comment)
        XCTAssertEqual(req.changed_fields?.count, 2)
        XCTAssertEqual(req.submitted_data?["first_name"], "Updated")
        XCTAssertEqual(req.current_data?["phone_number"], "555-0000")
        XCTAssertEqual(req.has_photo_changes, false)
    }

    func testPersonalInfoRequestMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(PersonalInfoRequest.self, from: json)
        XCTAssertEqual(req.id, 1)
        XCTAssertNil(req.status)
        XCTAssertNil(req.submitted_data)
        XCTAssertNil(req.changed_fields)
    }

    // MARK: - ContactRequest Tests

    func testContactRequestDecodingFull() throws {
        let json = """
        {
            "id": 3,
            "name": "John Client",
            "email": "john@client.com",
            "company_name": "Client LLC",
            "message": "I need HR services",
            "status": "pending",
            "ip_address": "192.168.1.1",
            "created_at": "2024-03-15T10:00:00Z",
            "updated_at": "2024-03-15T10:00:00Z"
        }
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(ContactRequest.self, from: json)
        XCTAssertEqual(req.id, 3)
        XCTAssertEqual(req.name, "John Client")
        XCTAssertEqual(req.email, "john@client.com")
        XCTAssertEqual(req.company_name, "Client LLC")
        XCTAssertEqual(req.status, "pending")
        XCTAssertEqual(req.ip_address, "192.168.1.1")
    }

    func testContactRequestMinimal() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(ContactRequest.self, from: json)
        XCTAssertEqual(req.id, 1)
        XCTAssertNil(req.name)
        XCTAssertNil(req.email)
        XCTAssertNil(req.status)
    }

    func testContactRequestStatsDecoding() throws {
        let json = """
        {"pending": 5, "replied": 10, "completed": 20, "total": 35}
        """.data(using: .utf8)!
        let stats = try JSONDecoder().decode(ContactRequestStats.self, from: json)
        XCTAssertEqual(stats.pending, 5)
        XCTAssertEqual(stats.replied, 10)
        XCTAssertEqual(stats.completed, 20)
        XCTAssertEqual(stats.total, 35)
    }

    // MARK: - Holiday Tests

    func testHolidayDecodingFull() throws {
        let json = """
        {
            "id": 1,
            "name": "New Year",
            "date": "2024-01-01",
            "holiday_type": "national",
            "applicable_group": "all",
            "applicable_country": "MK",
            "is_weekend": false,
            "day_of_week": "Monday"
        }
        """.data(using: .utf8)!
        let holiday = try JSONDecoder().decode(Holiday.self, from: json)
        XCTAssertEqual(holiday.id, 1)
        XCTAssertEqual(holiday.name, "New Year")
        XCTAssertEqual(holiday.applicable_country, "MK")
        XCTAssertEqual(holiday.is_weekend, false)
        XCTAssertNotNil(holiday.dateValue)
    }

    func testHolidayDateValue() throws {
        let json = """
        {"id": 1, "date": "2024-12-25"}
        """.data(using: .utf8)!
        let holiday = try JSONDecoder().decode(Holiday.self, from: json)
        XCTAssertNotNil(holiday.dateValue)
        let cal = Calendar.current
        XCTAssertEqual(cal.component(.month, from: holiday.dateValue!), 12)
        XCTAssertEqual(cal.component(.day, from: holiday.dateValue!), 25)
    }

    func testHolidayDateValueNilWhenMissing() throws {
        let json = """
        {"id": 1}
        """.data(using: .utf8)!
        let holiday = try JSONDecoder().decode(Holiday.self, from: json)
        XCTAssertNil(holiday.dateValue)
    }

    func testHolidayDateValueFromISO() throws {
        let json = """
        {"id": 1, "date": "2024-07-04T00:00:00Z"}
        """.data(using: .utf8)!
        let holiday = try JSONDecoder().decode(Holiday.self, from: json)
        XCTAssertNotNil(holiday.dateValue)
    }

    func testHolidayDateValueShortString() throws {
        let json = """
        {"id": 1, "date": "abc"}
        """.data(using: .utf8)!
        let holiday = try JSONDecoder().decode(Holiday.self, from: json)
        XCTAssertNil(holiday.dateValue, "Short date string should return nil")
    }

    // MARK: - Dashboard Tests

    func testDashboardStatsDecodingFull() throws {
        let json = """
        {
            "active_employees": 25,
            "clocked_in": 12,
            "on_leave": 3,
            "expiring_agreements": 2,
            "outstanding_invoices": 5,
            "pending_service_agreements": 1,
            "pending_employee_agreements": 3,
            "employers_count": 8,
            "pending_time_off": 4
        }
        """.data(using: .utf8)!
        let stats = try JSONDecoder().decode(DashboardStats.self, from: json)
        XCTAssertEqual(stats.active_employees, 25)
        XCTAssertEqual(stats.clocked_in, 12)
        XCTAssertEqual(stats.on_leave, 3)
        XCTAssertEqual(stats.expiring_agreements, 2)
        XCTAssertEqual(stats.outstanding_invoices, 5)
        XCTAssertEqual(stats.pending_service_agreements, 1)
        XCTAssertEqual(stats.pending_employee_agreements, 3)
        XCTAssertEqual(stats.employers_count, 8)
        XCTAssertEqual(stats.pending_time_off, 4)
    }

    func testDashboardStatsAllNil() throws {
        let json = "{}".data(using: .utf8)!
        let stats = try JSONDecoder().decode(DashboardStats.self, from: json)
        XCTAssertNil(stats.active_employees)
        XCTAssertNil(stats.clocked_in)
        XCTAssertNil(stats.pending_time_off)
    }

    func testPendingItemDecoding() throws {
        let json = """
        {"key": "time_off", "label": "Pending Time Off", "count": 4, "path": "/time-off", "icon": "calendar"}
        """.data(using: .utf8)!
        let item = try JSONDecoder().decode(PendingItem.self, from: json)
        XCTAssertEqual(item.key, "time_off")
        XCTAssertEqual(item.label, "Pending Time Off")
        XCTAssertEqual(item.count, 4)
        XCTAssertEqual(item.path, "/time-off")
        XCTAssertEqual(item.id, "time_off")
    }

    func testPendingItemMinimal() throws {
        let json = """
        {"key": "test", "label": "Test", "count": 0}
        """.data(using: .utf8)!
        let item = try JSONDecoder().decode(PendingItem.self, from: json)
        XCTAssertNil(item.path)
        XCTAssertNil(item.icon)
    }

    func testUpcomingPayrollDecoding() throws {
        let json = """
        {"days_until": 15, "next_date": "2024-04-25"}
        """.data(using: .utf8)!
        let payroll = try JSONDecoder().decode(UpcomingPayroll.self, from: json)
        XCTAssertEqual(payroll.days_until, 15)
        XCTAssertEqual(payroll.next_date, "2024-04-25")
    }

    func testUpcomingHolidayDecoding() throws {
        let json = """
        {"name": "Easter", "date": "2024-05-05", "holiday_type": "religious", "applicable_country": "MK"}
        """.data(using: .utf8)!
        let holiday = try JSONDecoder().decode(UpcomingHoliday.self, from: json)
        XCTAssertEqual(holiday.name, "Easter")
        XCTAssertEqual(holiday.applicable_country, "MK")
    }

    func testLegalEntityDecoding() throws {
        let json = """
        {"name": "Merot MK", "detail": "DOOEL Skopje", "country": "MK"}
        """.data(using: .utf8)!
        let entity = try JSONDecoder().decode(LegalEntity.self, from: json)
        XCTAssertEqual(entity.name, "Merot MK")
        XCTAssertEqual(entity.id, "Merot MK")
    }

    func testRecentActivityDecoding() throws {
        let json = """
        {"type": "employee_created", "message": "New employee added", "created_at": "2024-03-20T10:00:00Z"}
        """.data(using: .utf8)!
        let activity = try JSONDecoder().decode(RecentActivity.self, from: json)
        XCTAssertEqual(activity.type, "employee_created")
        XCTAssertEqual(activity.message, "New employee added")
    }

    func testDashboardResponseDecoding() throws {
        let json = """
        {
            "data": {
                "stats": {"active_employees": 10, "clocked_in": 5},
                "pending_items": [{"key": "k", "label": "l", "count": 1}],
                "upcoming_payroll": {"days_until": 5},
                "upcoming_holiday": {"name": "Holiday"},
                "entities": [{"name": "Entity1"}],
                "recent_activity": [{"type": "test", "message": "msg"}]
            },
            "success": true
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(DashboardResponse.self, from: json)
        XCTAssertEqual(resp.success, true)
        XCTAssertEqual(resp.data?.stats?.active_employees, 10)
        XCTAssertEqual(resp.data?.pending_items?.count, 1)
        XCTAssertNotNil(resp.data?.upcoming_payroll)
        XCTAssertNotNil(resp.data?.upcoming_holiday)
        XCTAssertEqual(resp.data?.entities?.count, 1)
        XCTAssertEqual(resp.data?.recent_activity?.count, 1)
    }

    // MARK: - PaginationMeta Tests

    func testPaginationMetaFull() throws {
        let json = """
        {"page": 2, "per_page": 25, "total_count": 100, "total_pages": 4}
        """.data(using: .utf8)!
        let meta = try JSONDecoder().decode(PaginationMeta.self, from: json)
        XCTAssertEqual(meta.page, 2)
        XCTAssertEqual(meta.per_page, 25)
        XCTAssertEqual(meta.total_count, 100)
        XCTAssertEqual(meta.total_pages, 4)
    }

    func testPaginationMetaEmpty() throws {
        let json = "{}".data(using: .utf8)!
        let meta = try JSONDecoder().decode(PaginationMeta.self, from: json)
        XCTAssertNil(meta.page)
        XCTAssertNil(meta.per_page)
        XCTAssertNil(meta.total_count)
        XCTAssertNil(meta.total_pages)
    }

    // MARK: - APIResponse / PaginatedResponse Tests

    func testAPIResponseDecoding() throws {
        let json = """
        {"data": {"id": 1, "name": "test"}, "success": true, "message": "OK"}
        """.data(using: .utf8)!
        struct Simple: Codable { let id: Int; let name: String }
        let resp = try JSONDecoder().decode(APIResponse<Simple>.self, from: json)
        XCTAssertEqual(resp.success, true)
        XCTAssertEqual(resp.data?.id, 1)
        XCTAssertEqual(resp.message, "OK")
    }

    func testPaginatedResponseDecoding() throws {
        let json = """
        {
            "data": [1, 2, 3],
            "success": true,
            "meta": {"page": 1, "per_page": 10, "total_count": 3, "total_pages": 1}
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(PaginatedResponse<[Int]>.self, from: json)
        XCTAssertEqual(resp.data?.count, 3)
        XCTAssertEqual(resp.meta?.page, 1)
    }

    // MARK: - EmployeeDashData Tests

    func testEmployeeDashDataDecoding() throws {
        let json = """
        {
            "employee": {"id": 1, "full_name": "Test User", "employee_id": "EMP-001", "department": "Engineering"},
            "employment": {"id": 1, "position": "Developer", "employer": {"name": "Corp", "id": 1}},
            "time_tracking": {"currently_clocked_in": true, "total_hours_this_week": 32.5, "total_hours_this_month": 120.0},
            "time_off": {
                "available_days": 15.0,
                "pending_requests_count": 1,
                "pending_requests": [{"id": 1, "start_date": "2024-04-01", "end_date": "2024-04-03", "days": 3, "approval_status": "pending"}],
                "balances": [{"id": 1, "name": "Annual", "leave_type": "annual", "days": 20, "balance": 15}]
            },
            "next_holiday": {"id": 1, "name": "Easter", "date": "2024-05-05", "day_of_week": "Sunday", "days_until": 30},
            "last_paystub": {"id": 1, "period": "March 2024", "net_salary": 1500.0, "gross_salary": 2000.0, "currency": "EUR"}
        }
        """.data(using: .utf8)!
        let data = try JSONDecoder().decode(EmployeeDashData.self, from: json)
        XCTAssertEqual(data.employee?.full_name, "Test User")
        XCTAssertEqual(data.employee?.employee_id, "EMP-001")
        XCTAssertEqual(data.employment?.position, "Developer")
        XCTAssertEqual(data.time_tracking?.currently_clocked_in, true)
        XCTAssertEqual(data.time_tracking?.total_hours_this_week, 32.5)
        XCTAssertEqual(data.time_off?.available_days, 15.0)
        XCTAssertEqual(data.time_off?.pending_requests_count, 1)
        XCTAssertEqual(data.time_off?.pending_requests?.count, 1)
        XCTAssertEqual(data.time_off?.balances?.count, 1)
        XCTAssertEqual(data.next_holiday?.name, "Easter")
        XCTAssertEqual(data.next_holiday?.days_until, 30)
        XCTAssertEqual(data.last_paystub?.net_salary, 1500.0)
        XCTAssertEqual(data.last_paystub?.currency, "EUR")
    }

    func testEmployeeDashDataAllNil() throws {
        let json = "{}".data(using: .utf8)!
        let data = try JSONDecoder().decode(EmployeeDashData.self, from: json)
        XCTAssertNil(data.employee)
        XCTAssertNil(data.employment)
        XCTAssertNil(data.time_tracking)
        XCTAssertNil(data.time_off)
        XCTAssertNil(data.next_holiday)
        XCTAssertNil(data.last_paystub)
    }

    func testEmployeeDashPendingReqDecoding() throws {
        let json = """
        {"id": 5, "start_date": "2024-06-01", "end_date": "2024-06-05", "days": 5, "approval_status": "approved"}
        """.data(using: .utf8)!
        let req = try JSONDecoder().decode(EmployeeDashPendingReq.self, from: json)
        XCTAssertEqual(req.id, 5)
        XCTAssertEqual(req.days, 5)
        XCTAssertEqual(req.approval_status, "approved")
    }

    func testEmployeeDashBalanceDecoding() throws {
        let json = """
        {"id": 1, "name": "Sick Leave", "leave_type": "sick", "days": 10.0, "balance": 8.5}
        """.data(using: .utf8)!
        let bal = try JSONDecoder().decode(EmployeeDashBalance.self, from: json)
        XCTAssertEqual(bal.name, "Sick Leave")
        XCTAssertEqual(bal.leave_type, "sick")
        XCTAssertEqual(bal.balance, 8.5)
    }

    func testEmployeeDashPaystubDecoding() throws {
        let json = """
        {"id": 1, "period": "Feb 2024", "net_salary": 1400.0, "gross_salary": 1900.0, "currency": "MKD"}
        """.data(using: .utf8)!
        let stub = try JSONDecoder().decode(EmployeeDashPaystub.self, from: json)
        XCTAssertEqual(stub.period, "Feb 2024")
        XCTAssertEqual(stub.net_salary, 1400.0)
        XCTAssertEqual(stub.currency, "MKD")
    }

    // MARK: - Keychain Tests

    func testKeychainSaveAndRead() {
        let key = "test_comprehensive_\(UUID().uuidString)"
        KeychainHelper.save(key: key, value: "hello_world")
        XCTAssertEqual(KeychainHelper.read(key: key), "hello_world")
        KeychainHelper.delete(key: key)
    }

    func testKeychainDeleteRemovesValue() {
        let key = "test_delete_\(UUID().uuidString)"
        KeychainHelper.save(key: key, value: "to_delete")
        KeychainHelper.delete(key: key)
        XCTAssertNil(KeychainHelper.read(key: key))
    }

    func testKeychainReadNonExistent() {
        XCTAssertNil(KeychainHelper.read(key: "non_existent_key_\(UUID().uuidString)"))
    }

    func testKeychainOverwrite() {
        let key = "test_overwrite_\(UUID().uuidString)"
        KeychainHelper.save(key: key, value: "first")
        KeychainHelper.save(key: key, value: "second")
        XCTAssertEqual(KeychainHelper.read(key: key), "second")
        KeychainHelper.delete(key: key)
    }

    func testKeychainEmptyStringValue() {
        let key = "test_empty_\(UUID().uuidString)"
        KeychainHelper.save(key: key, value: "")
        XCTAssertEqual(KeychainHelper.read(key: key), "")
        KeychainHelper.delete(key: key)
    }

    func testKeychainSpecialCharacters() {
        let key = "test_special_\(UUID().uuidString)"
        let value = "p@$$w0rd!#%^&*()"
        KeychainHelper.save(key: key, value: value)
        XCTAssertEqual(KeychainHelper.read(key: key), value)
        KeychainHelper.delete(key: key)
    }

    // MARK: - formatMoney Tests

    func testFormatMoneyBasic() {
        XCTAssertEqual(formatMoney(1234.56), "1,234.56")
    }

    func testFormatMoneyZero() {
        XCTAssertEqual(formatMoney(0.0), "0.00")
    }

    func testFormatMoneyNil() {
        let val: Double? = nil
        XCTAssertEqual(formatMoney(val), "-")
    }

    func testFormatMoneyWithCurrency() {
        XCTAssertEqual(formatMoney(1234.56, currency: "EUR"), "1,234.56 EUR")
    }

    func testFormatMoneyWithMKD() {
        XCTAssertEqual(formatMoney(75000.0, currency: "MKD"), "75,000.00 MKD")
    }

    func testFormatMoneyLargeNumber() {
        XCTAssertEqual(formatMoney(1000000.0), "1,000,000.00")
    }

    func testFormatMoneySmallNumber() {
        XCTAssertEqual(formatMoney(0.50), "0.50")
    }

    func testFormatMoneyFlexDouble() {
        let flex = FlexDouble(2500.75)
        XCTAssertEqual(formatMoney(flex), "2,500.75")
    }

    func testFormatMoneyFlexDoubleNil() {
        let flex: FlexDouble? = nil
        XCTAssertEqual(formatMoney(flex), "-")
    }

    func testFormatMoneyFlexDoubleWithCurrency() {
        let flex = FlexDouble(1500.0)
        XCTAssertEqual(formatMoney(flex, currency: "EUR"), "1,500.00 EUR")
    }

    func testFormatMoneyNilCurrency() {
        XCTAssertEqual(formatMoney(100.0, currency: nil), "100.00")
    }

    // MARK: - formatDate Tests

    func testFormatDateBasic() {
        XCTAssertEqual(formatDate("2024-03-15"), "15.03.2024")
    }

    func testFormatDateISO() {
        XCTAssertEqual(formatDate("2024-03-15T10:00:00Z"), "15.03.2024")
    }

    func testFormatDateNil() {
        XCTAssertEqual(formatDate(nil), "-")
    }

    func testFormatDateEmptyString() {
        XCTAssertEqual(formatDate(""), "-")
    }

    func testFormatDateShortString() {
        XCTAssertEqual(formatDate("2024"), "-")
    }

    func testFormatDateJanuary() {
        XCTAssertEqual(formatDate("2024-01-01"), "01.01.2024")
    }

    func testFormatDateDecember() {
        XCTAssertEqual(formatDate("2024-12-31"), "31.12.2024")
    }

    // MARK: - formatDateShort Tests

    func testFormatDateShortBasic() {
        XCTAssertEqual(formatDateShort("2024-03-15"), "15.03")
    }

    func testFormatDateShortNil() {
        XCTAssertEqual(formatDateShort(nil), "-")
    }

    func testFormatDateShortEmptyString() {
        XCTAssertEqual(formatDateShort(""), "-")
    }

    func testFormatDateShortISO() {
        XCTAssertEqual(formatDateShort("2024-12-25T00:00:00Z"), "25.12")
    }
}
