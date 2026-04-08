import XCTest

final class EmployeeE2ETests: XCTestCase {

    private static var app: XCUIApplication!

    override class func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        // Employee portal has "Clock" tab (unique to employee)
        UITestHelpers.ensureLoggedIn(app: app, email: "employee@merot.com", password: "password123", userType: "Employee", portalIdentifier: "Clock")
    }

    override func setUpWithError() throws { continueAfterFailure = true }

    private var app: XCUIApplication { EmployeeE2ETests.app }

    // MARK: - Dashboard

    @MainActor func testDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome"), "Should show Welcome")
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
        let empty = app.staticTexts["No payroll records"]
        let hasRecords = UITestHelpers.waitForText(app: app, text: "Net")
        XCTAssertTrue(hasRecords || empty.waitForExistence(timeout: 10), "Payroll should load")
    }

    @MainActor func testPayrollDetailShowsBreakdown() throws {
        app.tabBars.buttons["Payroll"].tap()
        sleep(3)
        guard UITestHelpers.tapFirstListRow(app: app) else { return }
        let earnings = app.staticTexts["Earnings"]
        let deductions = app.staticTexts["Deductions"]
        XCTAssertTrue(earnings.waitForExistence(timeout: 10) || deductions.waitForExistence(timeout: 10),
                      "Payroll detail should show Earnings or Deductions")
        UITestHelpers.tapBack(app: app)
    }

    // MARK: - Clock

    @MainActor func testClockTabShowsButton() throws {
        app.tabBars.buttons["Clock"].tap()
        let clockIn = UITestHelpers.waitForText(app: app, text: "Clock In")
        let clockOut = UITestHelpers.waitForText(app: app, text: "Clock Out")
        XCTAssertTrue(clockIn || clockOut, "Clock tab should show Clock In or Clock Out")
    }

    // MARK: - Time Off

    @MainActor func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        let empty = app.staticTexts["No time off requests"]
        let hasRequests = UITestHelpers.waitForText(app: app, text: "pending")
        let approved = UITestHelpers.waitForText(app: app, text: "approved")
        XCTAssertTrue(hasRequests || approved || empty.waitForExistence(timeout: 10), "Time Off should load")
    }

    @MainActor func testTimeOffPlusOpensCreateForm() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let plusButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add")).firstMatch
        let toolbarPlus = app.navigationBars.buttons.element(boundBy: 1)
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
        } else if toolbarPlus.waitForExistence(timeout: 3) {
            toolbarPlus.tap()
        }
        let createTitle = UITestHelpers.waitForText(app: app, text: "Request Time Off")
        let dateExists = UITestHelpers.waitForText(app: app, text: "Start Date")
        XCTAssertTrue(createTitle || dateExists, "Create form should open")
    }

    // MARK: - More

    @MainActor func testMoreTabShowsVerificationAndProfile() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Verification Letters"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Profile"].exists)
    }

    @MainActor func testMoreProfileShowsDetails() throws {
        app.tabBars.buttons["More"].tap()
        app.staticTexts["Profile"].tap()
        let email = UITestHelpers.waitForText(app: app, text: "employee@merot.com")
        let editProfile = UITestHelpers.waitForText(app: app, text: "Edit Profile")
        XCTAssertTrue(email || editProfile, "Profile should show email or Edit Profile")
        UITestHelpers.tapBack(app: app)
    }
}
