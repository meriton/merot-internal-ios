import XCTest

final class EmployeeE2ETests: XCTestCase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        UITestHelpers.ensureLoggedIn(app: app, email: "employee@merot.com", password: "password123", userType: "Employee", portalIdentifier: "Clock")
    }

    override func setUpWithError() throws { continueAfterFailure = true }

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

    @MainActor func testDashboardShowsHoursWeek() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Hours/Week"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsHoursMonth() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Hours/Month"].waitForExistence(timeout: 10))
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

    @MainActor func testDashboardShowsLastPaystub() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Last Paystub"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(hasRecords || empty, "Payroll should load")
    }

    @MainActor func testPayrollDetailShowsBreakdown() throws {
        app.tabBars.buttons["Payroll"].tap()
        sleep(3)
        guard UITestHelpers.tapFirstListRow(app: app) else { return }
        let earnings = app.staticTexts["Earnings"]
        let deductions = app.staticTexts["Deductions"]
        XCTAssertTrue(earnings.waitForExistence(timeout: 10) || deductions.waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Clock

    @MainActor func testClockTabShowsButton() throws {
        app.tabBars.buttons["Clock"].tap()
        sleep(3)
        // The button label is "Clock In" or "Clock Out", and there's also static text "Clocked In"/"Clocked Out"
        let clockedInText = app.staticTexts["Clocked In"]
        let clockedOutText = app.staticTexts["Clocked Out"]
        let clockInButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock In")).firstMatch
        let clockOutButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock Out")).firstMatch
        XCTAssertTrue(
            clockedInText.waitForExistence(timeout: 10) ||
            clockedOutText.waitForExistence(timeout: 10) ||
            clockInButton.waitForExistence(timeout: 10) ||
            clockOutButton.waitForExistence(timeout: 10),
            "Clock tab should show clock status or button"
        )
    }

    @MainActor func testClockTabShowsRecentActivity() throws {
        app.tabBars.buttons["Clock"].tap()
        sleep(3)
        XCTAssertTrue(app.staticTexts["Recent Activity"].waitForExistence(timeout: 10))
    }

    // MARK: - Time Off

    @MainActor func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        let hasRequests = UITestHelpers.waitForText(app: app, text: "pending") ||
                          UITestHelpers.waitForText(app: app, text: "approved") ||
                          UITestHelpers.waitForText(app: app, text: "No time off")
        XCTAssertTrue(hasRequests, "Time Off should load")
    }

    @MainActor func testTimeOffPlusOpensCreateForm() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        // Find the + button in toolbar
        let navButtons = app.navigationBars.buttons
        let plusButton = navButtons.element(boundBy: navButtons.count - 1)
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
            let hasForm = UITestHelpers.waitForText(app: app, text: "Request Time Off") ||
                          UITestHelpers.waitForText(app: app, text: "Start Date") ||
                          UITestHelpers.waitForText(app: app, text: "Leave Type")
            XCTAssertTrue(hasForm, "Create form should open")
            // Dismiss
            let cancel = app.buttons["Cancel"]
            if cancel.waitForExistence(timeout: 3) { cancel.tap() }
        }
    }

    // MARK: - More

    @MainActor func testMoreTabShowsLinks() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Verification Letters"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Profile"].exists)
    }

    @MainActor func testMoreProfileShowsDetails() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        app.staticTexts["Profile"].tap()
        let hasProfile = UITestHelpers.waitForText(app: app, text: "employee@merot.com") ||
                         UITestHelpers.waitForText(app: app, text: "Edit Profile") ||
                         UITestHelpers.waitForText(app: app, text: "Tatjana")
        XCTAssertTrue(hasProfile, "Profile should show details")
        UITestHelpers.tapBack(app: app)
    }
}
