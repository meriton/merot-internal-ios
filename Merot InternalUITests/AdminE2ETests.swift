import XCTest

final class AdminE2ETests: UITestBase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        let base = UITestBase()
        try? base.setUpWithError() // triggers seed
        app = base.launchApp()
        UITestHelpers.ensureLoggedIn(app: app, email: adminEmail, password: adminPassword, userType: "Admin", portalIdentifier: "Hiring")
    }

    override func tearDownWithError() throws {
        let app = AdminE2ETests.app!
        // Double-tap Dashboard to pop any pushed views (SwiftUI resets nav on re-tap)
        if app.tabBars.buttons["Dashboard"].exists {
            app.tabBars.buttons["Dashboard"].tap()
            app.tabBars.buttons["Dashboard"].tap()
        }
    }

    private var app: XCUIApplication { AdminE2ETests.app }

    // MARK: - Dashboard

    @MainActor func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome"))
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

    @MainActor func testEmployeesShowsTestEmployee() throws {
        app.tabBars.buttons["Employees"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Ana Testova") ||
                      UITestHelpers.waitForText(app: app, text: "Marko Testovski"),
                      "Should show seeded employees")
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

    @MainActor func testInvoiceShowsTestInvoice() throws {
        app.tabBars.buttons["Invoices"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "INV-TEST-001"),
                      "Should show seeded invoice")
    }

    @MainActor func testInvoiceDetail() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        if app.staticTexts["No invoices found"].waitForExistence(timeout: 5) { return }
        if !UITestHelpers.tapFirstListRow(app: app, containingText: "INV", timeout: 5) { return }
        let hasContent = app.staticTexts["Details"].waitForExistence(timeout: 10) ||
                         UITestHelpers.waitForText(app: app, text: "Total") ||
                         UITestHelpers.waitForText(app: app, text: "Actions")
        XCTAssertTrue(hasContent)
        UITestHelpers.tapBack(app: app)
        // Ensure we're back on invoice list
        app.tabBars.buttons["Invoices"].tap()
    }

    // MARK: - Hiring

    @MainActor func testHiringSegments() throws {
        app.tabBars.buttons["Hiring"].tap()
        XCTAssertTrue(app.buttons["Postings"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Applications"].exists)
    }

    @MainActor func testHiringShowsTestJobPosting() throws {
        app.tabBars.buttons["Hiring"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Test Developer"),
                      "Should show seeded job posting")
    }

    // MARK: - More Tab

    @MainActor func testMoreTabLinks() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        XCTAssertTrue(app.staticTexts["Employers"].waitForExistence(timeout: 10))
    }

    @MainActor func testMoreTabShowsSettings() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        if !app.staticTexts["Settings"].waitForExistence(timeout: 3) { app.swipeUp() }
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 10))
    }

    @MainActor func testMoreSettingsShowsProfile() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        if !app.staticTexts["Settings"].waitForExistence(timeout: 3) { app.swipeUp() }
        app.staticTexts["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Profile Details"].waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
    }

    @MainActor func testMoreTabLogoutExists() throws {
        app.tabBars.buttons["More"].tap()
        sleep(1)
        if !app.buttons["Logout"].waitForExistence(timeout: 3) { app.swipeUp() }
        XCTAssertTrue(app.buttons["Logout"].waitForExistence(timeout: 10))
    }
}
