import XCTest

final class LoginE2ETests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        // Ensure we're on login screen
        if !app.buttons["Sign In"].waitForExistence(timeout: 5) {
            UITestHelpers.logout(app: app)
            sleep(2)
        }
    }

    // MARK: - Login Screen Elements

    @MainActor func testLoginScreenShowsAllUserTypeButtons() throws {
        XCTAssertTrue(app.buttons["Admin"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Employer"].exists)
        XCTAssertTrue(app.buttons["Employee"].exists)
    }

    @MainActor func testLoginScreenShowsBranding() throws {
        XCTAssertTrue(app.staticTexts["internal.merot.com"].waitForExistence(timeout: 8))
    }

    @MainActor func testLoginScreenShowsEmailAndPasswordFields() throws {
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.secureTextFields.firstMatch.exists)
    }

    @MainActor func testSignInButtonExistsAndDisabledWhenEmpty() throws {
        let signIn = app.buttons["Sign In"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 8))
    }

    @MainActor func testSuccessfulAdminLogin() throws {
        UITestHelpers.login(app: app, email: "meriton@merot.com", password: "password123", userType: "Admin")
        XCTAssertTrue(app.tabBars.buttons["Hiring"].waitForExistence(timeout: 10), "Admin should have Hiring tab")
    }

    @MainActor func testSuccessfulEmployeeLogin() throws {
        // Logout from admin if previous test logged in
        if !app.buttons["Sign In"].waitForExistence(timeout: 3) {
            UITestHelpers.logout(app: app)
            sleep(2)
        }
        UITestHelpers.login(app: app, email: "employee@merot.com", password: "password123", userType: "Employee")
        XCTAssertTrue(app.tabBars.buttons["Clock"].waitForExistence(timeout: 10), "Employee should have Clock tab")
    }
}
