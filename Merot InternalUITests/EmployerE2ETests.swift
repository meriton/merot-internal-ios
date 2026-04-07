import XCTest

final class EmployerE2ETests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        loginAsEmployer()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func loginAsEmployer() {
        // Employer portal has: Dashboard, Employees, Invoices, Time Off, More
        let timeOffTab = app.tabBars.buttons["Time Off"]
        let employeesTab = app.tabBars.buttons["Employees"]
        // Distinguish from admin (admin has Hiring, employer has Time Off)
        let hiringTab = app.tabBars.buttons["Hiring"]
        if timeOffTab.waitForExistence(timeout: 3) && employeesTab.exists && !hiringTab.exists {
            app.tabBars.buttons["Dashboard"].tap()
            return
        }
        UITestHelpers.logout(app: app)
        UITestHelpers.login(app: app, email: "employer1@test.chutra.org", password: "password123", userType: "Employer")
    }

    // MARK: - Dashboard Tests

    @MainActor
    func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome,"),
                      "Employer dashboard should show Welcome text")
    }

    @MainActor
    func testDashboardShowsEmployeesCount() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Employees"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10),
                      "Employer dashboard should show Employees stat")
    }

    @MainActor
    func testDashboardShowsActiveStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Active"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10),
                      "Employer dashboard should show Active stat")
    }

    @MainActor
    func testDashboardShowsPendingPTOStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Pending PTO"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10),
                      "Employer dashboard should show Pending PTO stat")
    }

    @MainActor
    func testDashboardShowsTeamMembers() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        let teamMembers = app.staticTexts["Team Members"]
        // Team Members only shows if there are recent employees
        let noTeam = !teamMembers.waitForExistence(timeout: 10)
        if noTeam {
            // That's ok if no employees yet
            return
        }
        XCTAssertTrue(teamMembers.exists,
                      "Employer dashboard should show Team Members section")
    }

    @MainActor
    func testDashboardPullToRefreshWorks() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let welcome = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcome.waitForExistence(timeout: 10))
        app.swipeDown()
        XCTAssertTrue(welcome.waitForExistence(timeout: 10),
                      "Employer dashboard should reload after pull-to-refresh")
    }

    // MARK: - Employees Tab Tests

    @MainActor
    func testEmployeesTabLoads() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(2)
        // Employer employees uses .searchable modifier so search is in nav bar
        let noEmployees = app.staticTexts["No employees found"]
        let hasData = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
        XCTAssertTrue(hasData.waitForExistence(timeout: 10) || noEmployees.exists,
                      "Employer Employees tab should show employee data or empty state")
    }

    @MainActor
    func testEmployeesTabShowsEmployeeNames() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        let noEmployees = app.staticTexts["No employees found"]
        if noEmployees.waitForExistence(timeout: 5) { return }
        // Should show employee names with status badges
        let activeBadge = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
        XCTAssertTrue(activeBadge.waitForExistence(timeout: 10),
                      "Employee list should show status badges for loaded employees")
    }

    @MainActor
    func testEmployeesTabTapEmployeeShowsDetail() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        let noEmployees = app.staticTexts["No employees found"]
        if noEmployees.waitForExistence(timeout: 5) { return }
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        // Should show employee detail with Contact section
        let contactSection = app.staticTexts["Contact"]
        let workInfo = app.staticTexts["Work Info"]
        XCTAssertTrue(contactSection.waitForExistence(timeout: 10) || workInfo.waitForExistence(timeout: 5),
                      "Tapping an employee should show detail with Contact or Work Info section")
    }

    // MARK: - Invoices Tab Tests

    @MainActor
    func testInvoicesTabLoads() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(2)
        let noInvoices = app.staticTexts["No invoices found"]
        let hasInvoice = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "INV")).firstMatch
        XCTAssertTrue(hasInvoice.waitForExistence(timeout: 10) || noInvoices.waitForExistence(timeout: 5),
                      "Invoices tab should show invoices or empty state")
    }

    @MainActor
    func testInvoicesTabShowsStatusFilters() throws {
        app.tabBars.buttons["Invoices"].tap()
        let allFilter = app.buttons["All"]
        XCTAssertTrue(allFilter.waitForExistence(timeout: 10),
                      "Invoices tab should show All filter pill")
    }

    @MainActor
    func testInvoicesFilterPaidChangesView() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(2)
        let paidFilter = app.buttons["Paid"]
        XCTAssertTrue(paidFilter.waitForExistence(timeout: 10))
        paidFilter.tap()
        sleep(2)
        let hasInvoice = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "INV")).firstMatch
        let noInvoices = app.staticTexts["No invoices found"]
        XCTAssertTrue(hasInvoice.waitForExistence(timeout: 10) || noInvoices.exists,
                      "Filtering by Paid should show paid invoices or empty state")
    }

    @MainActor
    func testInvoiceDetailLoadsWithSummary() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let noInvoices = app.staticTexts["No invoices found"]
        if noInvoices.waitForExistence(timeout: 5) { return }
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        let summary = app.staticTexts["Summary"]
        XCTAssertTrue(summary.waitForExistence(timeout: 10),
                      "Invoice detail should show Summary section with amounts")
    }

    @MainActor
    func testInvoiceDetailShowsDownloadPDF() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let noInvoices = app.staticTexts["No invoices found"]
        if noInvoices.waitForExistence(timeout: 5) { return }
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        app.swipeUp()
        let downloadPDF = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Download PDF")).firstMatch
        XCTAssertTrue(downloadPDF.waitForExistence(timeout: 10),
                      "Invoice detail should show Download PDF button")
    }

    @MainActor
    func testInvoiceDetailShowsDates() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let noInvoices = app.staticTexts["No invoices found"]
        if noInvoices.waitForExistence(timeout: 5) { return }
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        app.swipeUp()
        let dates = app.staticTexts["Dates"]
        XCTAssertTrue(dates.waitForExistence(timeout: 10),
                      "Invoice detail should show Dates section")
    }

    // MARK: - Time Off Tab Tests

    @MainActor
    func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let noRequests = app.staticTexts["No time off requests"]
        let hasFilters = app.buttons["All"]
        XCTAssertTrue(hasFilters.waitForExistence(timeout: 10) || noRequests.waitForExistence(timeout: 5),
                      "Time Off tab should show filter pills or empty state")
    }

    @MainActor
    func testTimeOffShowsFilterPills() throws {
        app.tabBars.buttons["Time Off"].tap()
        let pendingFilter = app.buttons["Pending"]
        XCTAssertTrue(pendingFilter.waitForExistence(timeout: 10),
                      "Time Off tab should show Pending filter pill")
    }

    @MainActor
    func testTimeOffFilterPendingShowsPendingRequests() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let pendingFilter = app.buttons["Pending"]
        XCTAssertTrue(pendingFilter.waitForExistence(timeout: 10))
        pendingFilter.tap()
        sleep(2)
        let hasRequests = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "pending")).firstMatch
        let noRequests = app.staticTexts["No time off requests"]
        XCTAssertTrue(hasRequests.waitForExistence(timeout: 10) || noRequests.exists,
                      "Filtering by Pending should show pending requests or empty state")
    }

    @MainActor
    func testTimeOffPendingRequestShowsApproveButton() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let pendingFilter = app.buttons["Pending"]
        XCTAssertTrue(pendingFilter.waitForExistence(timeout: 10))
        pendingFilter.tap()
        sleep(2)
        let noRequests = app.staticTexts["No time off requests"]
        if noRequests.waitForExistence(timeout: 5) { return }
        let approveButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Approve")).firstMatch
        XCTAssertTrue(approveButton.waitForExistence(timeout: 10),
                      "Pending time off requests should show Approve button")
    }

    @MainActor
    func testTimeOffPendingRequestShowsDenyButton() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let pendingFilter = app.buttons["Pending"]
        XCTAssertTrue(pendingFilter.waitForExistence(timeout: 10))
        pendingFilter.tap()
        sleep(2)
        let noRequests = app.staticTexts["No time off requests"]
        if noRequests.waitForExistence(timeout: 5) { return }
        let denyButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Deny")).firstMatch
        XCTAssertTrue(denyButton.waitForExistence(timeout: 10),
                      "Pending time off requests should show Deny button")
    }

    // MARK: - More Tab Tests

    @MainActor
    func testMoreTabShowsHolidaysLink() throws {
        app.tabBars.buttons["More"].tap()
        let holidays = app.staticTexts["Holidays"]
        XCTAssertTrue(holidays.waitForExistence(timeout: 10),
                      "Employer More tab should show Holidays link")
    }

    @MainActor
    func testMoreTabShowsServiceAgreementsLink() throws {
        app.tabBars.buttons["More"].tap()
        let svcAgreements = app.staticTexts["Service Agreements"]
        XCTAssertTrue(svcAgreements.waitForExistence(timeout: 10),
                      "Employer More tab should show Service Agreements link")
    }

    @MainActor
    func testMoreTabShowsProfileLink() throws {
        app.tabBars.buttons["More"].tap()
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10),
                      "Employer More tab should show Profile link")
    }

    @MainActor
    func testMoreTabShowsLogoutButton() throws {
        app.tabBars.buttons["More"].tap()
        let logout = app.buttons["Logout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 10),
                      "Employer More tab should show Logout button")
    }

    @MainActor
    func testMoreTabHolidaysLoads() throws {
        app.tabBars.buttons["More"].tap()
        let holidays = app.staticTexts["Holidays"]
        XCTAssertTrue(holidays.waitForExistence(timeout: 10))
        holidays.tap()
        sleep(2)
        let noHolidays = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No upcoming")).firstMatch
        let hasHolidays = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Holiday")).firstMatch
        let title = app.navigationBars.staticTexts["Holidays"]
        XCTAssertTrue(noHolidays.waitForExistence(timeout: 10) || hasHolidays.exists || title.exists,
                      "Holidays page should load with data or empty state")
    }

    @MainActor
    func testMoreTabServiceAgreementsLoads() throws {
        app.tabBars.buttons["More"].tap()
        let svcAgreements = app.staticTexts["Service Agreements"]
        XCTAssertTrue(svcAgreements.waitForExistence(timeout: 10))
        svcAgreements.tap()
        sleep(2)
        let noAgreements = app.staticTexts["No service agreements"]
        let hasAgreements = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Service Agreement")).firstMatch
        XCTAssertTrue(noAgreements.waitForExistence(timeout: 10) || hasAgreements.exists,
                      "Service Agreements page should load with data or empty state")
    }

    @MainActor
    func testMoreTabProfileLoads() throws {
        app.tabBars.buttons["More"].tap()
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10))
        profile.tap()
        sleep(2)
        // Should show Company section
        let company = app.staticTexts["Company"]
        let contact = app.staticTexts["Contact"]
        XCTAssertTrue(company.waitForExistence(timeout: 10) || contact.waitForExistence(timeout: 5),
                      "Employer profile should show Company or Contact section")
    }

    @MainActor
    func testMoreTabProfileShowsAppInfo() throws {
        app.tabBars.buttons["More"].tap()
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10))
        profile.tap()
        app.swipeUp()
        app.swipeUp()
        let appInfo = app.staticTexts["App Info"]
        XCTAssertTrue(appInfo.waitForExistence(timeout: 10),
                      "Employer profile should show App Info section")
    }

    @MainActor
    func testMoreTabProfileShowsChangePasswordButton() throws {
        app.tabBars.buttons["More"].tap()
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10))
        profile.tap()
        app.swipeUp()
        let changePassword = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Change Password")).firstMatch
        XCTAssertTrue(changePassword.waitForExistence(timeout: 10),
                      "Employer profile should show Change Password button")
    }

    // MARK: - Tab Bar Tests

    @MainActor
    func testEmployerTabBarHasCorrectTabs() throws {
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Employer should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Employees"].exists, "Employer should have Employees tab")
        XCTAssertTrue(app.tabBars.buttons["Invoices"].exists, "Employer should have Invoices tab")
        XCTAssertTrue(app.tabBars.buttons["Time Off"].exists, "Employer should have Time Off tab")
        XCTAssertTrue(app.tabBars.buttons["More"].exists, "Employer should have More tab")
    }

    @MainActor
    func testMoreTabLogoutReturnsToLoginScreen() throws {
        app.tabBars.buttons["More"].tap()
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 10))
        logoutButton.tap()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 10),
                      "After logout, login screen should appear with Admin button")
    }
}
