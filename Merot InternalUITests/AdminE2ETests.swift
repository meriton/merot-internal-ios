import XCTest

final class AdminE2ETests: XCTestCase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        // "Hiring" tab only exists on admin portal
        UITestHelpers.ensureLoggedIn(app: app, email: "meriton@merot.com", password: "password123", userType: "Admin", portalIdentifier: "Hiring")
    }

    override func setUpWithError() throws { continueAfterFailure = true }

    private var app: XCUIApplication { AdminE2ETests.app }

    // MARK: - Dashboard

    @MainActor func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome"), "Should show Welcome")
    }

    @MainActor func testDashboardShowsActiveEmployees() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Active Employees"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsClockedIn() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Clocked In"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsOnLeave() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["On Leave"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsOutstanding() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Outstanding"].waitForExistence(timeout: 10))
    }

    @MainActor func testDashboardShowsNextPayroll() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Next Payroll"].waitForExistence(timeout: 10))
    }

    // MARK: - Employees

    @MainActor func testEmployeesTabLoads() throws {
        app.tabBars.buttons["Employees"].tap()
        XCTAssertTrue(app.textFields["Search employees..."].waitForExistence(timeout: 10))
    }

    @MainActor func testEmployeesFilterChips() throws {
        app.tabBars.buttons["Employees"].tap()
        XCTAssertTrue(app.buttons["Active"].waitForExistence(timeout: 10))
    }

    @MainActor func testEmployeeDetail() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        guard UITestHelpers.tapFirstListRow(app: app) else { return }
        XCTAssertTrue(app.staticTexts["Personal Information"].waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Invoices

    @MainActor func testInvoicesTabLoads() throws {
        app.tabBars.buttons["Invoices"].tap()
        let search = app.textFields["Search invoices..."]
        let empty = app.staticTexts["No invoices found"]
        XCTAssertTrue(search.waitForExistence(timeout: 10) || empty.waitForExistence(timeout: 10))
    }

    @MainActor func testInvoiceDetail() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if app.staticTexts["No invoices found"].waitForExistence(timeout: 3) { return }
        guard UITestHelpers.tapFirstListRow(app: app, containingText: "INV") else { return }
        XCTAssertTrue(app.staticTexts["Details"].waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Hiring

    @MainActor func testHiringSegments() throws {
        app.tabBars.buttons["Hiring"].tap()
        XCTAssertTrue(app.buttons["Postings"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Applications"].exists)
    }

    @MainActor func testHiringSwitchToApplications() throws {
        app.tabBars.buttons["Hiring"].tap()
        app.buttons["Applications"].tap()
        XCTAssertTrue(app.textFields["Search applications..."].waitForExistence(timeout: 10))
    }

    // MARK: - More Tab

    @MainActor func testMoreTabLinks() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Employers"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Payroll"].exists)
        XCTAssertTrue(app.staticTexts["Time Off Requests"].exists)
        XCTAssertTrue(app.staticTexts["Settings"].exists)
    }

    @MainActor func testMoreEmployersLoads() throws {
        app.tabBars.buttons["More"].tap()
        app.staticTexts["Employers"].tap()
        let search = app.textFields["Search employers..."]
        let empty = app.staticTexts["No employers found"]
        XCTAssertTrue(search.waitForExistence(timeout: 10) || empty.waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreSettingsShowsProfile() throws {
        app.tabBars.buttons["More"].tap()
        app.staticTexts["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Profile Details"].waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreTabLogoutExists() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.buttons["Logout"].waitForExistence(timeout: 10))
    }
}
