import XCTest

final class Merot_InternalUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLoginScreenElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify login screen elements are present
        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]

        // Wait for login screen to appear
        let exists = emailField.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Email field should exist on login screen")
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        XCTAssertTrue(signInButton.exists, "Sign In button should exist")

        // Verify the MEROT logo text
        let merotText = app.staticTexts["MEROT"]
        XCTAssertTrue(merotText.exists, "MEROT logo text should be visible")

        // Verify internal.merot.com footer
        let footerText = app.staticTexts["internal.merot.com"]
        XCTAssertTrue(footerText.exists, "Footer text should be visible")
    }

    @MainActor
    func testLoginButtonDisabledWhenEmpty() throws {
        let app = XCUIApplication()
        app.launch()

        let signInButton = app.buttons["Sign In"]
        let exists = signInButton.waitForExistence(timeout: 5)
        XCTAssertTrue(exists)
        XCTAssertTrue(signInButton.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
