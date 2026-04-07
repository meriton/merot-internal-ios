import XCTest

final class LoginTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private func logoutIfNeeded() {
        // If we see a tab bar, we're logged in — log out first
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 3) {
            // Try tapping More tab (admin) or Profile tab (employee/employer)
            let moreTab = app.tabBars.buttons["More"]
            let profileTab = app.tabBars.buttons["Profile"]
            if moreTab.exists {
                moreTab.tap()
                let logoutButton = app.buttons["Logout"]
                if logoutButton.waitForExistence(timeout: 3) {
                    logoutButton.tap()
                    return
                }
                // Scroll to find logout
                app.swipeUp()
                if logoutButton.waitForExistence(timeout: 2) {
                    logoutButton.tap()
                    return
                }
            } else if profileTab.exists {
                profileTab.tap()
                let logoutButton = app.buttons["Logout"]
                if logoutButton.waitForExistence(timeout: 5) {
                    logoutButton.tap()
                    return
                }
                app.swipeUp()
                if logoutButton.waitForExistence(timeout: 2) {
                    logoutButton.tap()
                }
            }
        }
    }

    private func selectUserType(_ type: String) {
        let typeButton = app.buttons[type]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5), "User type button '\(type)' should exist")
        typeButton.tap()
    }

    private func enterCredentials(email: String, password: String) {
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field should exist")
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        passwordField.tap()
        passwordField.typeText(password)
    }

    private func tapSignIn() {
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists, "Sign In button should exist")
        signInButton.tap()
    }

    // MARK: - Login Screen Element Tests

    @MainActor
    func testLoginScreenShowsAllUserTypeButtons() throws {
        logoutIfNeeded()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5), "Admin button should exist on login screen")

        let employerButton = app.buttons["Employer"]
        XCTAssertTrue(employerButton.exists, "Employer button should exist on login screen")

        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.exists, "Employee button should exist on login screen")
    }

    @MainActor
    func testLoginScreenShowsEmailField() throws {
        logoutIfNeeded()
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 5), "Email label should exist")

        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.exists, "Email text field should exist")
    }

    @MainActor
    func testLoginScreenShowsPasswordField() throws {
        logoutIfNeeded()
        let passwordLabel = app.staticTexts["Password"]
        XCTAssertTrue(passwordLabel.waitForExistence(timeout: 5), "Password label should exist")

        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.exists, "Password secure field should exist")
    }

    @MainActor
    func testSignInButtonDisabledWhenFieldsEmpty() throws {
        logoutIfNeeded()
        let signIn = app.buttons["Sign In"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 5), "Sign In button should exist")
        XCTAssertFalse(signIn.isEnabled, "Sign In should be disabled when fields are empty")
    }

    @MainActor
    func testSignInButtonEnabledAfterEnteringCredentials() throws {
        logoutIfNeeded()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
        selectUserType("Admin")
        enterCredentials(email: "meriton@merot.com", password: "password123")

        let signIn = app.buttons["Sign In"]
        XCTAssertTrue(signIn.isEnabled, "Sign In should be enabled after entering credentials")
    }

    @MainActor
    func testInvalidCredentialsShowError() throws {
        logoutIfNeeded()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))

        selectUserType("Admin")
        enterCredentials(email: "wrong@merot.com", password: "wrongpass")
        tapSignIn()

        // Wait for error message to appear (API call + error rendering)
        let errorExists = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Invalid")).firstMatch
            .waitForExistence(timeout: 10)
        let networkError = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "error")).firstMatch.exists
        let unauthorized = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "unauthorized")).firstMatch.exists
        let failed = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "failed")).firstMatch.exists

        XCTAssertTrue(errorExists || networkError || unauthorized || failed,
                       "An error message should appear for invalid credentials")
    }

    @MainActor
    func testSuccessfulAdminLoginShowsDashboard() throws {
        logoutIfNeeded()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))

        selectUserType("Admin")
        enterCredentials(email: "meriton@merot.com", password: "password123")
        tapSignIn()

        // After login, the Dashboard tab should appear
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 10), "Dashboard tab should appear after admin login")

        // Verify we see the welcome text with admin name
        let welcomeText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 10), "Welcome text should appear on admin dashboard")
    }

    @MainActor
    func testSuccessfulEmployeeLoginShowsEmployeeDashboard() throws {
        logoutIfNeeded()
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5))

        selectUserType("Employee")
        enterCredentials(email: "employee@merot.com", password: "password123")
        tapSignIn()

        // After login, the Dashboard tab should appear with employee layout
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 10), "Dashboard tab should appear after employee login")

        // Employee dashboard shows "Welcome, <name>" text
        let welcomeText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 10), "Welcome text should appear on employee dashboard")
    }

    @MainActor
    func testLoginScreenShowsBranding() throws {
        logoutIfNeeded()
        let branding = app.staticTexts["internal.merot.com"]
        XCTAssertTrue(branding.waitForExistence(timeout: 5), "Branding text 'internal.merot.com' should appear on login screen")
    }

    @MainActor
    func testUserTypeSelectionIsTappable() throws {
        logoutIfNeeded()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))

        // Tap each user type to verify they're interactive
        app.buttons["Employee"].tap()
        app.buttons["Employer"].tap()
        app.buttons["Admin"].tap()
        // If we get here without crash, the buttons are tappable
    }

    @MainActor
    func testAdminLoginShowsCorrectTabBar() throws {
        logoutIfNeeded()
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))

        selectUserType("Admin")
        enterCredentials(email: "meriton@merot.com", password: "password123")
        tapSignIn()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar should appear after login")

        // Admin should have: Dashboard, Employees, Invoices, Hiring, More
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Admin should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Employees"].exists, "Admin should have Employees tab")
        XCTAssertTrue(app.tabBars.buttons["Invoices"].exists, "Admin should have Invoices tab")
        XCTAssertTrue(app.tabBars.buttons["Hiring"].exists, "Admin should have Hiring tab")
        XCTAssertTrue(app.tabBars.buttons["More"].exists, "Admin should have More tab")
    }

    @MainActor
    func testEmployeeLoginShowsCorrectTabBar() throws {
        logoutIfNeeded()
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5))

        selectUserType("Employee")
        enterCredentials(email: "employee@merot.com", password: "password123")
        tapSignIn()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar should appear after login")

        // Employee should have: Dashboard, Payroll, Clock, Time Off, Profile
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Employee should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Payroll"].exists, "Employee should have Payroll tab")
        XCTAssertTrue(app.tabBars.buttons["Clock"].exists, "Employee should have Clock tab")
        XCTAssertTrue(app.tabBars.buttons["Time Off"].exists, "Employee should have Time Off tab")
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists, "Employee should have Profile tab")
    }
}
