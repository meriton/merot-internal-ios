import XCTest

final class LoginE2ETests: UITestBase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
        app = launchApp()
        // Ensure on login screen
        if !app.buttons["Sign In"].waitForExistence(timeout: 5) {
            UITestHelpers.logout(app: app)
            sleep(2)
        }
    }

    // MARK: - Login Screen

    @MainActor func testLoginScreenShowsAllUserTypeButtons() throws {
        XCTAssertTrue(app.buttons["Admin"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Employer"].exists)
        XCTAssertTrue(app.buttons["Employee"].exists)
    }

    @MainActor func testLoginScreenShowsBranding() throws {
        XCTAssertTrue(app.staticTexts["api.outsourcing.merot.com"].waitForExistence(timeout: 8))
    }

    @MainActor func testSignInButtonExists() throws {
        XCTAssertTrue(app.buttons["Sign In"].waitForExistence(timeout: 8))
    }

    @MainActor func testSuccessfulAdminLogin() throws {
        UITestHelpers.login(app: app, email: Self.adminEmail, password: Self.adminPassword, userType: "Admin")
        XCTAssertTrue(app.tabBars.buttons["Hiring"].waitForExistence(timeout: 10), "Admin should have Hiring tab")
    }

    @MainActor func testSuccessfulEmployeeLogin() throws {
        if !app.buttons["Sign In"].waitForExistence(timeout: 3) {
            UITestHelpers.logout(app: app)
            sleep(2)
        }
        UITestHelpers.login(app: app, email: Self.employeeEmail, password: Self.employeePassword, userType: "Employee")
        XCTAssertTrue(app.tabBars.buttons["Clock"].waitForExistence(timeout: 10), "Employee should have Clock tab")
    }

    @MainActor func testSuccessfulEmployerLogin() throws {
        if !app.buttons["Sign In"].waitForExistence(timeout: 3) {
            UITestHelpers.logout(app: app)
            sleep(2)
        }
        UITestHelpers.login(app: app, email: Self.employerEmail, password: Self.employerPassword, userType: "Employer")
        let timeOff = app.tabBars.buttons["Time Off"]
        let hiring = app.tabBars.buttons["Hiring"]
        XCTAssertTrue(timeOff.waitForExistence(timeout: 10), "Employer should have Time Off tab")
        XCTAssertFalse(hiring.exists, "Employer should NOT have Hiring tab")
    }
}
