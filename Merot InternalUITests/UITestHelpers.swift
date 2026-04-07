import XCTest

// MARK: - Shared UI Test Helpers

enum UITestHelpers {

    /// Logs in as the given user type with the provided credentials.
    /// Waits for the Dashboard tab to appear after a successful login.
    static func login(app: XCUIApplication, email: String, password: String, userType: String) {
        // Make sure we're on the login screen
        let typeButton = app.buttons[userType]
        guard typeButton.waitForExistence(timeout: 8) else {
            XCTFail("Login screen did not appear - could not find '\(userType)' button")
            return
        }
        typeButton.tap()

        let emailField = app.textFields.firstMatch
        guard emailField.waitForExistence(timeout: 5) else {
            XCTFail("Email text field not found")
            return
        }
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields.firstMatch
        guard passwordField.waitForExistence(timeout: 3) else {
            XCTFail("Password field not found")
            return
        }
        passwordField.tap()
        passwordField.typeText(password)

        let signIn = app.buttons["Sign In"]
        guard signIn.waitForExistence(timeout: 3) else {
            XCTFail("Sign In button not found")
            return
        }
        signIn.tap()

        let dashboard = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 15),
                      "Dashboard tab should appear after login as \(userType)")
    }

    /// Logs out from any portal. Works for Admin (More tab), Employee (More tab), and Employer (More tab).
    static func logout(app: XCUIApplication) {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 3) {
            moreTab.tap()
            // Admin More has a Logout button directly in the list.
            // Employee More has Profile -> Logout, but Logout is also directly in Admin More.
            // Try finding the logout button, scroll if needed.
            let logoutButton = app.buttons["Logout"]
            if logoutButton.waitForExistence(timeout: 3) {
                logoutButton.tap()
                return
            }
            app.swipeUp()
            if logoutButton.waitForExistence(timeout: 3) {
                logoutButton.tap()
                return
            }
        }
    }

    /// Waits for a staticText containing the given text to appear.
    @discardableResult
    static func waitForText(app: XCUIApplication, text: String, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let element = app.staticTexts.containing(predicate).firstMatch
        return element.waitForExistence(timeout: timeout)
    }

    /// Navigates back using the navigation bar back button.
    static func tapBack(app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.waitForExistence(timeout: 3) {
            backButton.tap()
        }
    }
}
