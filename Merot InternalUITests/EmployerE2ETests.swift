import XCTest

final class EmployerE2ETests: XCTestCase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        // Employer has "Time Off" tab but no "Hiring" tab (admin has Hiring)
        // Use "Time Off" as identifier — if Hiring also exists, we're on admin, need to switch
        let hiringTab = app.tabBars.buttons["Hiring"]
        let timeOffTab = app.tabBars.buttons["Time Off"]
        if timeOffTab.waitForExistence(timeout: 5) && !hiringTab.exists {
            // Already on employer portal
            app.tabBars.buttons["Dashboard"].tap()
        } else {
            // Login as employer
            if !app.buttons["Sign In"].waitForExistence(timeout: 3) {
                UITestHelpers.logout(app: app)
                sleep(2)
            }
            UITestHelpers.login(app: app, email: "employer1@test.chutra.org", password: "password123", userType: "Employer")
        }
    }

    override func setUpWithError() throws { continueAfterFailure = true }

    private var app: XCUIApplication { EmployerE2ETests.app }

    // MARK: - Dashboard

    @MainActor func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome"), "Should show Welcome")
    }

    @MainActor func testDashboardShowsStats() throws {
        app.tabBars.buttons["Dashboard"].tap()
        // Employer dashboard should show employee-related stats
        let hasStats = UITestHelpers.waitForText(app: app, text: "Employees") ||
                       UITestHelpers.waitForText(app: app, text: "Active") ||
                       UITestHelpers.waitForText(app: app, text: "Team")
        XCTAssertTrue(hasStats, "Dashboard should show stats")
    }

    // MARK: - Employees

    @MainActor func testEmployeesTabLoads() throws {
        app.tabBars.buttons["Employees"].tap()
        let search = app.textFields["Search employees..."]
        let empty = app.staticTexts["No employees"]
        XCTAssertTrue(search.waitForExistence(timeout: 10) || empty.waitForExistence(timeout: 10),
                      "Employees tab should load")
    }

    @MainActor func testEmployeeDetail() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        guard UITestHelpers.tapFirstListRow(app: app) else { return }
        let hasDetail = UITestHelpers.waitForText(app: app, text: "Contact") ||
                        UITestHelpers.waitForText(app: app, text: "Email") ||
                        UITestHelpers.waitForText(app: app, text: "Work Info")
        XCTAssertTrue(hasDetail, "Employee detail should show info")
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Invoices

    @MainActor func testInvoicesTabLoads() throws {
        app.tabBars.buttons["Invoices"].tap()
        let hasInvoices = UITestHelpers.waitForText(app: app, text: "INV")
        let empty = app.staticTexts["No invoices"]
        XCTAssertTrue(hasInvoices || empty.waitForExistence(timeout: 10), "Invoices should load")
    }

    @MainActor func testInvoiceDetail() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if app.staticTexts["No invoices"].waitForExistence(timeout: 3) { return }
        guard UITestHelpers.tapFirstListRow(app: app, containingText: "INV") else { return }
        let hasDetail = UITestHelpers.waitForText(app: app, text: "Summary") ||
                        UITestHelpers.waitForText(app: app, text: "Total") ||
                        UITestHelpers.waitForText(app: app, text: "Details")
        XCTAssertTrue(hasDetail, "Invoice detail should load")
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testInvoiceDetailShowsDownloadPDF() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if app.staticTexts["No invoices"].waitForExistence(timeout: 3) { return }
        guard UITestHelpers.tapFirstListRow(app: app, containingText: "INV") else { return }
        let downloadPDF = UITestHelpers.waitForText(app: app, text: "Download PDF")
        XCTAssertTrue(downloadPDF, "Invoice detail should show Download PDF")
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Time Off

    @MainActor func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        let hasRequests = UITestHelpers.waitForText(app: app, text: "pending") ||
                          UITestHelpers.waitForText(app: app, text: "approved") ||
                          UITestHelpers.waitForText(app: app, text: "No time off")
        XCTAssertTrue(hasRequests, "Time Off should load")
    }

    // MARK: - More

    @MainActor func testMoreTabShowsLinks() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Holidays"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Service Agreements"].exists)
        XCTAssertTrue(app.staticTexts["Profile"].exists)
    }

    @MainActor func testMoreHolidaysLoads() throws {
        app.tabBars.buttons["More"].tap()
        app.staticTexts["Holidays"].tap()
        let hasHolidays = UITestHelpers.waitForText(app: app, text: "2026") ||
                          UITestHelpers.waitForText(app: app, text: "Holiday")
        XCTAssertTrue(hasHolidays, "Holidays should load")
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreProfileLoads() throws {
        app.tabBars.buttons["More"].tap()
        app.staticTexts["Profile"].tap()
        let hasProfile = UITestHelpers.waitForText(app: app, text: "employer1@test.chutra.org") ||
                         UITestHelpers.waitForText(app: app, text: "Change Password") ||
                         UITestHelpers.waitForText(app: app, text: "Profile")
        XCTAssertTrue(hasProfile, "Profile should load")
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreLogoutExists() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.buttons["Logout"].waitForExistence(timeout: 10))
    }
}
