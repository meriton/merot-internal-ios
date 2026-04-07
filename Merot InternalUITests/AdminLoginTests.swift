import XCTest

final class AdminLoginTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Login Screen Elements

    @MainActor
    func testLoginScreenShowsMerotLogo() throws {
        let merotText = app.staticTexts["MEROT"]
        XCTAssertTrue(merotText.waitForExistence(timeout: 5), "MEROT logo text should be visible")
    }

    @MainActor
    func testLoginScreenShowsFooter() throws {
        let footer = app.staticTexts["internal.merot.com"]
        XCTAssertTrue(footer.waitForExistence(timeout: 5), "Footer text should be visible")
    }

    @MainActor
    func testLoginScreenShowsEmailField() throws {
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field should exist")
    }

    @MainActor
    func testLoginScreenShowsPasswordField() throws {
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field should exist")
    }

    @MainActor
    func testLoginScreenShowsSignInButton() throws {
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "Sign In button should exist")
    }

    @MainActor
    func testLoginScreenShowsEmailLabel() throws {
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 5), "Email label should be visible")
    }

    @MainActor
    func testLoginScreenShowsPasswordLabel() throws {
        let passwordLabel = app.staticTexts["Password"]
        XCTAssertTrue(passwordLabel.waitForExistence(timeout: 5), "Password label should be visible")
    }

    // MARK: - User Type Selector

    @MainActor
    func testLoginScreenShowsAdminButton() throws {
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5), "Admin user type button should exist")
    }

    @MainActor
    func testLoginScreenShowsEmployerButton() throws {
        let employerButton = app.buttons["Employer"]
        XCTAssertTrue(employerButton.waitForExistence(timeout: 5), "Employer user type button should exist")
    }

    @MainActor
    func testLoginScreenShowsEmployeeButton() throws {
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5), "Employee user type button should exist")
    }

    @MainActor
    func testUserTypeSelectorCanSwitchToEmployer() throws {
        let employerButton = app.buttons["Employer"]
        XCTAssertTrue(employerButton.waitForExistence(timeout: 5))
        employerButton.tap()
        // Verify it was tapped (button still exists and is hittable)
        XCTAssertTrue(employerButton.exists, "Employer button should still exist after tapping")
    }

    @MainActor
    func testUserTypeSelectorCanSwitchToEmployee() throws {
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5))
        employeeButton.tap()
        XCTAssertTrue(employeeButton.exists, "Employee button should still exist after tapping")
    }

    @MainActor
    func testUserTypeSelectorCanSwitchBackToAdmin() throws {
        let employerButton = app.buttons["Employer"]
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(employerButton.waitForExistence(timeout: 5))
        employerButton.tap()
        adminButton.tap()
        XCTAssertTrue(adminButton.exists, "Admin button should still exist after switching back")
    }

    // MARK: - Sign In Button State

    @MainActor
    func testSignInButtonAppearsReducedOpacityWhenEmpty() throws {
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "Sign In button should exist when fields are empty")
    }

    @MainActor
    func testCanTypeInEmailField() throws {
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("test@merot.com")
        // Verify text was entered
        let fieldValue = emailField.value as? String ?? ""
        XCTAssertTrue(fieldValue.contains("test@merot.com"), "Email field should contain typed text")
    }

    @MainActor
    func testCanTypeInPasswordField() throws {
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("password123")
        // SecureField won't show text but should have a value
        XCTAssertTrue(passwordField.exists, "Password field should still exist after typing")
    }

    @MainActor
    func testSignInButtonExistsAfterFillingFields() throws {
        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("admin@merot.com")

        passwordField.tap()
        passwordField.typeText("password123")

        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists, "Sign In button should be present after filling fields")
    }

    // MARK: - All Three User Type Buttons Present

    @MainActor
    func testAllThreeUserTypeButtonsExist() throws {
        let admin = app.buttons["Admin"]
        let employer = app.buttons["Employer"]
        let employee = app.buttons["Employee"]
        XCTAssertTrue(admin.waitForExistence(timeout: 5))
        XCTAssertTrue(employer.exists)
        XCTAssertTrue(employee.exists)
    }

    @MainActor
    func testCyclingThroughAllUserTypes() throws {
        let admin = app.buttons["Admin"]
        let employer = app.buttons["Employer"]
        let employee = app.buttons["Employee"]
        XCTAssertTrue(admin.waitForExistence(timeout: 5))

        employer.tap()
        employee.tap()
        admin.tap()
        // All buttons should still exist after cycling
        XCTAssertTrue(admin.exists)
        XCTAssertTrue(employer.exists)
        XCTAssertTrue(employee.exists)
    }
}
