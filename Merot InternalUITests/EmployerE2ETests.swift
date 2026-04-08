import XCTest

final class EmployerE2ETests: XCTestCase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        // Employer has Time Off tab but NOT Hiring tab
        let hiringTab = app.tabBars.buttons["Hiring"]
        let timeOffTab = app.tabBars.buttons["Time Off"]
        if timeOffTab.waitForExistence(timeout: 5) && !hiringTab.exists {
            app.tabBars.buttons["Dashboard"].tap()
        } else {
            if !app.buttons["Sign In"].waitForExistence(timeout: 3) {
                UITestHelpers.logout(app: app)
                sleep(2)
            }
            UITestHelpers.login(app: app, email: "employer1@test.chutra.org", password: "password123", userType: "Employer")
        }
    }

    override func setUpWithError() throws { continueAfterFailure = true }

    override func tearDownWithError() throws {
        let app = EmployerE2ETests.app!
        if app.tabBars.buttons["Dashboard"].exists { app.tabBars.buttons["Dashboard"].tap() }
    }

    private var app: XCUIApplication { EmployerE2ETests.app }

    // MARK: - Dashboard

    @MainActor func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome"))
    }

    @MainActor func testDashboardShowsStats() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let hasStats = UITestHelpers.waitForText(app: app, text: "Employees") ||
                       UITestHelpers.waitForText(app: app, text: "Active") ||
                       UITestHelpers.waitForText(app: app, text: "Team")
        XCTAssertTrue(hasStats, "Dashboard should show stats")
    }

    // MARK: - Employees

    @MainActor func testEmployeesTabLoads() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        // Employer employees view uses .searchable with prompt "Search employees"
        let hasContent = UITestHelpers.waitForText(app: app, text: "Search") ||
                         UITestHelpers.waitForText(app: app, text: "No employees") ||
                         UITestHelpers.waitForText(app: app, text: "active")
        XCTAssertTrue(hasContent, "Employees tab should load")
    }

    @MainActor func testEmployeeDetail() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        guard UITestHelpers.tapFirstListRow(app: app) else { return }
        let hasDetail = UITestHelpers.waitForText(app: app, text: "Contact") ||
                        UITestHelpers.waitForText(app: app, text: "Email") ||
                        UITestHelpers.waitForText(app: app, text: "Work Info")
        XCTAssertTrue(hasDetail)
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Invoices

    @MainActor func testInvoicesTabLoads() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let hasInvoices = UITestHelpers.waitForText(app: app, text: "INV")
        let empty = UITestHelpers.waitForText(app: app, text: "No invoices")
        XCTAssertTrue(hasInvoices || empty, "Invoices should load")
    }

    @MainActor func testInvoiceDetail() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if UITestHelpers.waitForText(app: app, text: "No invoices") { return }
        guard UITestHelpers.tapFirstListRow(app: app, containingText: "INV") else { return }
        let hasDetail = UITestHelpers.waitForText(app: app, text: "Summary") ||
                        UITestHelpers.waitForText(app: app, text: "Total") ||
                        UITestHelpers.waitForText(app: app, text: "Details") ||
                        UITestHelpers.waitForText(app: app, text: "Download PDF")
        XCTAssertTrue(hasDetail, "Invoice detail should load")
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testInvoiceDetailShowsDownloadPDF() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if UITestHelpers.waitForText(app: app, text: "No invoices") { return }
        guard UITestHelpers.tapFirstListRow(app: app, containingText: "INV") else { return }
        sleep(2)
        // May need to scroll to find Download PDF button
        if !UITestHelpers.waitForText(app: app, text: "Download PDF") {
            app.swipeUp()
        }
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Download PDF"), "Should show Download PDF")
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Time Off

    @MainActor func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(3)
        let hasContent = UITestHelpers.waitForText(app: app, text: "pending") ||
                         UITestHelpers.waitForText(app: app, text: "approved") ||
                         UITestHelpers.waitForText(app: app, text: "No time off") ||
                         UITestHelpers.waitForText(app: app, text: "All")
        XCTAssertTrue(hasContent, "Time Off should load")
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
        sleep(1)
        app.staticTexts["Holidays"].tap()
        let hasContent = UITestHelpers.waitForText(app: app, text: "2026") ||
                         UITestHelpers.waitForText(app: app, text: "Holiday") ||
                         UITestHelpers.waitForText(app: app, text: "No holidays")
        XCTAssertTrue(hasContent)
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreProfileLoads() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        app.staticTexts["Profile"].tap()
        let hasProfile = UITestHelpers.waitForText(app: app, text: "employer1@test.chutra.org") ||
                         UITestHelpers.waitForText(app: app, text: "Change Password") ||
                         UITestHelpers.waitForText(app: app, text: "Company")
        XCTAssertTrue(hasProfile)
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreLogoutExists() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        if !app.buttons["Logout"].waitForExistence(timeout: 3) { app.swipeUp() }
        XCTAssertTrue(app.buttons["Logout"].waitForExistence(timeout: 10))
    }
}
