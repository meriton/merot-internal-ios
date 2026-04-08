import XCTest

final class EmployeeE2ETests: UITestBase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        let base = UITestBase()
        try? base.setUpWithError()
        app = base.launchApp()
        UITestHelpers.ensureLoggedIn(app: app, email: employeeEmail, password: employeePassword, userType: "Employee", portalIdentifier: "Clock")
    }

    override func tearDownWithError() throws {
        let app = EmployeeE2ETests.app!
        if app.tabBars.buttons["Dashboard"].exists { app.tabBars.buttons["Dashboard"].tap() }
    }

    private var app: XCUIApplication { EmployeeE2ETests.app }

    // MARK: - Dashboard

    @MainActor func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome"))
    }

    @MainActor func testDashboardShowsEmployeeName() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Ana Testova"),
                      "Should show seeded employee name")
    }

    @MainActor func testDashboardShowsHoursWeek() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Hours/Week"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsDaysOff() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Days Off"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsClockStatus() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let clockedIn = app.staticTexts["Currently Clocked In"]
        let notClocked = app.staticTexts["Not Clocked In"]
        XCTAssertTrue(clockedIn.waitForExistence(timeout: 10) || notClocked.waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsLeaveBalances() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Leave Balances"].waitForExistence(timeout: 10))
    }

    // MARK: - Payroll

    @MainActor func testPayrollTabLoads() throws {
        app.tabBars.buttons["Payroll"].tap()
        let hasRecords = UITestHelpers.waitForText(app: app, text: "Net")
        let empty = UITestHelpers.waitForText(app: app, text: "No payroll")
        XCTAssertTrue(hasRecords || empty)
    }

    // MARK: - Clock

    @MainActor func testClockTabShowsButton() throws {
        app.tabBars.buttons["Clock"].tap()
        sleep(3)
        let clockedIn = app.staticTexts["Clocked In"]
        let clockedOut = app.staticTexts["Clocked Out"]
        XCTAssertTrue(clockedIn.waitForExistence(timeout: 10) || clockedOut.waitForExistence(timeout: 10))
    }

    @MainActor func testClockTabShowsRecentActivity() throws {
        app.tabBars.buttons["Clock"].tap()
        sleep(3)
        XCTAssertTrue(app.staticTexts["Recent Activity"].waitForExistence(timeout: 10))
    }

    // MARK: - Time Off

    @MainActor func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        let hasContent = UITestHelpers.waitForText(app: app, text: "pending") ||
                         UITestHelpers.waitForText(app: app, text: "approved") ||
                         UITestHelpers.waitForText(app: app, text: "No time off")
        XCTAssertTrue(hasContent)
    }

    @MainActor func testTimeOffShowsPendingRequest() throws {
        app.tabBars.buttons["Time Off"].tap()
        // Seeded data has a pending request
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "pending"),
                      "Should show seeded pending time off request")
    }

    // MARK: - More

    @MainActor func testMoreTabShowsLinks() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Verification Letters"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Profile"].exists)
    }

    @MainActor func testMoreProfileShowsEmail() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        app.staticTexts["Profile"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "employee@test.merot.com") ||
                      UITestHelpers.waitForText(app: app, text: "Ana Testova"),
                      "Profile should show seeded employee data")
        UITestHelpers.tapBack(app: app)
    }
}
