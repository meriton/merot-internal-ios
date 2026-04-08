import XCTest

final class EmployerE2ETests: UITestBase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        let base = UITestBase()
        try? base.setUpWithError()
        app = base.launchApp()
        // Employer has Time Off but not Hiring
        let hiringTab = app.tabBars.buttons["Hiring"]
        let timeOffTab = app.tabBars.buttons["Time Off"]
        if timeOffTab.waitForExistence(timeout: 5) && !hiringTab.exists {
            app.tabBars.buttons["Dashboard"].tap()
        } else {
            if !app.buttons["Sign In"].waitForExistence(timeout: 3) {
                UITestHelpers.logout(app: app)
                sleep(2)
            }
            UITestHelpers.login(app: app, email: employerEmail, password: employerPassword, userType: "Employer")
        }
    }

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
        XCTAssertTrue(hasStats)
    }

    // MARK: - Employees

    @MainActor func testEmployeesTabLoads() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        let hasContent = UITestHelpers.waitForText(app: app, text: "Ana Testova") ||
                         UITestHelpers.waitForText(app: app, text: "No employees") ||
                         UITestHelpers.waitForText(app: app, text: "Search")
        XCTAssertTrue(hasContent)
    }

    // MARK: - Invoices

    @MainActor func testInvoicesTabLoads() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let hasContent = UITestHelpers.waitForText(app: app, text: "INV-TEST-001") ||
                         UITestHelpers.waitForText(app: app, text: "No invoices")
        XCTAssertTrue(hasContent)
    }

    @MainActor func testInvoiceDetail() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if UITestHelpers.waitForText(app: app, text: "No invoices") { return }
        guard UITestHelpers.tapFirstListRow(app: app, containingText: "INV") else { return }
        let hasDetail = UITestHelpers.waitForText(app: app, text: "Summary") ||
                        UITestHelpers.waitForText(app: app, text: "Total") ||
                        UITestHelpers.waitForText(app: app, text: "Download PDF")
        XCTAssertTrue(hasDetail)
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
        XCTAssertTrue(hasContent)
    }

    // MARK: - More

    @MainActor func testMoreTabShowsLinks() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Holidays"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Profile"].exists)
    }

    @MainActor func testMoreProfileLoads() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        app.staticTexts["Profile"].tap()
        let hasProfile = UITestHelpers.waitForText(app: app, text: "employer@test.merot.com") ||
                         UITestHelpers.waitForText(app: app, text: "TestCorp") ||
                         UITestHelpers.waitForText(app: app, text: "Change Password")
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
