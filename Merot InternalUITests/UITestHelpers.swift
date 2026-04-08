import XCTest

enum UITestHelpers {

    /// Ensures the app is logged in as the given user type. If already on the correct portal, does nothing.
    /// If on wrong portal or login screen, logs out if needed and logs in.
    static func ensureLoggedIn(app: XCUIApplication, email: String, password: String, userType: String, portalIdentifier: String) {
        // Check if we're already on the right portal by looking for a unique tab
        let identifier = app.tabBars.buttons[portalIdentifier]
        if identifier.waitForExistence(timeout: 8) {
            app.tabBars.buttons["Dashboard"].tap()
            return
        }

        // Either on login screen or wrong portal — logout first
        let signIn = app.buttons["Sign In"]
        if !signIn.waitForExistence(timeout: 3) {
            logout(app: app)
            sleep(2)
        }

        login(app: app, email: email, password: password, userType: userType)
    }

    /// Logs in with credentials. Assumes we're on the login screen.
    static func login(app: XCUIApplication, email: String, password: String, userType: String) {
        let typeButton = app.buttons[userType]
        guard typeButton.waitForExistence(timeout: 10) else {
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

    /// Logs out from any portal.
    static func logout(app: XCUIApplication) {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 3) {
            moreTab.tap()
            sleep(1)
            let logoutButton = app.buttons["Logout"]
            if logoutButton.waitForExistence(timeout: 3) {
                logoutButton.tap()
                return
            }
            app.swipeUp()
            sleep(1)
            if logoutButton.waitForExistence(timeout: 3) {
                logoutButton.tap()
            }
        }
    }

    /// Taps the first tappable row in a SwiftUI List.
    @discardableResult
    static func tapFirstListRow(app: XCUIApplication, containingText: String? = nil, timeout: TimeInterval = 10) -> Bool {
        sleep(2)
        if let text = containingText {
            let pred = NSPredicate(format: "label CONTAINS[c] %@", text)
            let match = app.buttons.matching(pred).firstMatch
            if match.waitForExistence(timeout: timeout) { match.tap(); return true }
            let textMatch = app.staticTexts.matching(pred).firstMatch
            if textMatch.waitForExistence(timeout: 3) { textMatch.tap(); return true }
        }
        let cell = app.cells.firstMatch
        if cell.waitForExistence(timeout: 3) { cell.tap(); return true }
        return false
    }

    /// Waits for a staticText containing the given text.
    @discardableResult
    static func waitForText(app: XCUIApplication, text: String, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let element = app.staticTexts.containing(predicate).firstMatch
        return element.waitForExistence(timeout: timeout)
    }

    /// Navigates back.
    static func tapBack(app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.waitForExistence(timeout: 3) {
            backButton.tap()
        }
    }
}
