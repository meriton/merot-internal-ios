import XCTest

final class LoginE2ETests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        // Make sure we start on the login screen
        logoutIfNeeded()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func logoutIfNeeded() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 3) {
            UITestHelpers.logout(app: app)
        }
    }

    // MARK: - Login Screen Element Tests

    @MainActor
    func testLoginScreenShowsAllUserTypeButtons() throws {
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 8), "Login screen should show Admin button")
        XCTAssertTrue(app.buttons["Employer"].exists, "Login screen should show Employer button")
        XCTAssertTrue(app.buttons["Employee"].exists, "Login screen should show Employee button")
    }

    @MainActor
    func testLoginScreenShowsBranding() throws {
        let branding = app.staticTexts["internal.merot.com"]
        XCTAssertTrue(branding.waitForExistence(timeout: 8),
                      "Login screen should show 'internal.merot.com' branding")
    }

    @MainActor
    func testSignInDisabledWhenEmpty() throws {
        let signIn = app.buttons["Sign In"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 8))
        XCTAssertFalse(signIn.isEnabled,
                       "Sign In should be disabled when fields are empty")
    }

    @MainActor
    func testSignInEnabledAfterEnteringCredentials() throws {
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 8))
        adminButton.tap()
        let emailField = app.textFields.firstMatch
        emailField.tap()
        emailField.typeText("meriton@merot.com")
        let passwordField = app.secureTextFields.firstMatch
        passwordField.tap()
        passwordField.typeText("password123")
        let signIn = app.buttons["Sign In"]
        XCTAssertTrue(signIn.isEnabled,
                      "Sign In should be enabled after entering credentials")
    }

    @MainActor
    func testInvalidCredentialsShowError() throws {
        // Ensure we're on login screen
        let adminButton = app.buttons["Admin"]
        guard adminButton.waitForExistence(timeout: 10) else {
            // Might be logged in, try logout
            UITestHelpers.logout(app: app)
            sleep(2)
            XCTAssertTrue(adminButton.waitForExistence(timeout: 10), "Should be on login screen")
            return
        }
        adminButton.tap()
        let emailField = app.textFields.firstMatch
        emailField.tap()
        emailField.typeText("wrong@merot.com")
        let passwordField = app.secureTextFields.firstMatch
        passwordField.tap()
        passwordField.typeText("wrongpass")
        app.buttons["Sign In"].tap()
        // Wait for error — the API returns "Invalid credentials" which the app shows
        sleep(3)
        let errorExists = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Invalid")).firstMatch.waitForExistence(timeout: 10)
        let networkError = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "error")).firstMatch.exists
        let failed = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "failed")).firstMatch.exists
        // Still on login screen (no Dashboard tab appeared)
        let stillOnLogin = app.buttons["Sign In"].exists
        XCTAssertTrue(errorExists || networkError || failed || stillOnLogin,
                      "Invalid credentials should show an error or stay on login screen")
    }

    @MainActor
    func testSuccessfulAdminLoginShowsDashboard() throws {
        UITestHelpers.login(app: app, email: "meriton@merot.com", password: "password123", userType: "Admin")
        // Verify we see admin tabs
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Admin should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Hiring"].exists, "Admin should have Hiring tab")
        XCTAssertTrue(app.tabBars.buttons["More"].exists, "Admin should have More tab")
        // Verify welcome text with real data
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome,"),
                      "Admin dashboard should show Welcome text after login")
    }

    @MainActor
    func testSuccessfulEmployeeLoginShowsDashboard() throws {
        UITestHelpers.login(app: app, email: "employee@merot.com", password: "password123", userType: "Employee")
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Employee should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Payroll"].exists, "Employee should have Payroll tab")
        XCTAssertTrue(app.tabBars.buttons["Clock"].exists, "Employee should have Clock tab")
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome,"),
                      "Employee dashboard should show Welcome text after login")
    }

    @MainActor
    func testSuccessfulEmployerLoginShowsDashboard() throws {
        UITestHelpers.login(app: app, email: "employer1@test.chutra.org", password: "password123", userType: "Employer")
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Employer should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Employees"].exists, "Employer should have Employees tab")
        XCTAssertTrue(app.tabBars.buttons["Time Off"].exists, "Employer should have Time Off tab")
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome,"),
                      "Employer dashboard should show Welcome text after login")
    }

    @MainActor
    func testAdminLoginShowsCorrectFiveTabs() throws {
        UITestHelpers.login(app: app, email: "meriton@merot.com", password: "password123", userType: "Admin")
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Admin should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Employees"].exists, "Admin should have Employees tab")
        XCTAssertTrue(app.tabBars.buttons["Invoices"].exists, "Admin should have Invoices tab")
        XCTAssertTrue(app.tabBars.buttons["Hiring"].exists, "Admin should have Hiring tab")
        XCTAssertTrue(app.tabBars.buttons["More"].exists, "Admin should have More tab")
    }

    @MainActor
    func testEmployeeLoginShowsCorrectFiveTabs() throws {
        UITestHelpers.login(app: app, email: "employee@merot.com", password: "password123", userType: "Employee")
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Employee should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Payroll"].exists, "Employee should have Payroll tab")
        XCTAssertTrue(app.tabBars.buttons["Clock"].exists, "Employee should have Clock tab")
        XCTAssertTrue(app.tabBars.buttons["Time Off"].exists, "Employee should have Time Off tab")
        XCTAssertTrue(app.tabBars.buttons["More"].exists, "Employee should have More tab")
    }
}
