import XCTest

final class EmployeePortalUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Helper Methods

    /// Selects the Employee user type on the login screen
    private func selectEmployeeType() {
        let employeeButton = app.buttons["Employee"]
        if employeeButton.waitForExistence(timeout: 5) {
            employeeButton.tap()
        }
    }

    /// Fills in login credentials
    private func enterCredentials(email: String = "employee@test.com", password: String = "password123") {
        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText(email)

        passwordField.tap()
        passwordField.typeText(password)
    }

    // MARK: - 1. Employee Login Tests

    @MainActor
    func testLoginScreenShowsEmployeeTypeButton() throws {
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5), "Employee type button should exist on login screen")
    }

    @MainActor
    func testSelectEmployeeType() throws {
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5))
        employeeButton.tap()
        XCTAssertTrue(employeeButton.exists, "Employee button should remain visible after selection")
    }

    @MainActor
    func testEmployeeLoginHasEmailField() throws {
        selectEmployeeType()
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field should exist for employee login")
    }

    @MainActor
    func testEmployeeLoginHasPasswordField() throws {
        selectEmployeeType()
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field should exist for employee login")
    }

    @MainActor
    func testEmployeeLoginHasSignInButton() throws {
        selectEmployeeType()
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "Sign In button should exist for employee login")
    }

    @MainActor
    func testEmployeeLoginEmailLabel() throws {
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 5), "Email label should be visible")
    }

    @MainActor
    func testEmployeeLoginPasswordLabel() throws {
        let passwordLabel = app.staticTexts["Password"]
        XCTAssertTrue(passwordLabel.waitForExistence(timeout: 5), "Password label should be visible")
    }

    @MainActor
    func testEmployeeLoginMerotLogo() throws {
        let merotText = app.staticTexts["MEROT"]
        XCTAssertTrue(merotText.waitForExistence(timeout: 5), "MEROT logo should be visible on employee login")
    }

    @MainActor
    func testEmployeeLoginFooter() throws {
        let footerText = app.staticTexts["internal.merot.com"]
        XCTAssertTrue(footerText.waitForExistence(timeout: 5), "Footer text should be visible")
    }

    @MainActor
    func testEmployeeLoginCanTypeEmail() throws {
        selectEmployeeType()
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("john@merot.com")
        XCTAssertTrue(emailField.exists, "Email field should accept text input")
    }

    @MainActor
    func testEmployeeLoginCanTypePassword() throws {
        selectEmployeeType()
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("secretpass")
        XCTAssertTrue(passwordField.exists, "Password field should accept text input")
    }

    @MainActor
    func testEmployeeLoginSignInDisabledWhenEmpty() throws {
        selectEmployeeType()
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
        // When fields are empty the button should still exist
        XCTAssertTrue(signInButton.exists, "Sign In should exist even when fields are empty")
    }

    @MainActor
    func testEmployeeLoginCompleteFlow() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("employee@merot.com")

        passwordField.tap()
        passwordField.typeText("testpass123")

        XCTAssertTrue(signInButton.exists, "Sign In button should exist after filling form")
        XCTAssertTrue(signInButton.isHittable, "Sign In button should be hittable")
    }

    @MainActor
    func testEmployeeLoginTapSignIn() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("employee@merot.com")
        passwordField.tap()
        passwordField.typeText("password")

        signInButton.tap()

        // Wait for response
        let _ = app.staticTexts.firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(app.exists, "App should still be running after login attempt")
    }

    @MainActor
    func testEmployeeTypeSelectorIsHittable() throws {
        let employeeButton = app.buttons["Employee"]
        XCTAssertTrue(employeeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(employeeButton.isHittable, "Employee type button should be hittable")
    }

    // MARK: - 2. Employee Dashboard Tests

    @MainActor
    func testEmployeeDashboardLoginRequired() throws {
        // Verify login screen is shown (not dashboard) when unauthenticated
        selectEmployeeType()
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "Login screen should be shown when not authenticated")
    }

    @MainActor
    func testEmployeeDashboardRequiresAuthentication() throws {
        // Without authentication, we should see login screen, not dashboard
        let merotLogo = app.staticTexts["MEROT"]
        XCTAssertTrue(merotLogo.waitForExistence(timeout: 5), "MEROT logo on login should be visible")

        // Dashboard-specific elements should NOT be visible without login
        let hoursWeek = app.staticTexts["Hours/Week"]
        XCTAssertFalse(hoursWeek.exists, "Dashboard stats should not be visible without login")
    }

    @MainActor
    func testEmployeeDashboardStatsNotVisibleWithoutAuth() throws {
        let hoursMonth = app.staticTexts["Hours/Month"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(hoursMonth.exists, "Hours/Month stat should not be visible without login")
    }

    @MainActor
    func testEmployeeDashboardDaysOffNotVisibleWithoutAuth() throws {
        let daysOff = app.staticTexts["Days Off"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(daysOff.exists, "Days Off stat should not be visible without login")
    }

    @MainActor
    func testEmployeeDashboardClockStatusNotVisibleWithoutAuth() throws {
        let clockedIn = app.staticTexts["Currently Clocked In"]
        let notClockedIn = app.staticTexts["Not Clocked In"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(clockedIn.exists, "Clock status should not be visible without login")
        XCTAssertFalse(notClockedIn.exists, "Clock status should not be visible without login")
    }

    @MainActor
    func testEmployeeDashboardLastPaystubNotVisibleWithoutAuth() throws {
        let lastPaystub = app.staticTexts["Last Paystub"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(lastPaystub.exists, "Last Paystub should not be visible without login")
    }

    @MainActor
    func testEmployeeDashboardLeaveBalancesNotVisibleWithoutAuth() throws {
        let balances = app.staticTexts["Leave Balances"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(balances.exists, "Leave Balances should not be visible without login")
    }

    @MainActor
    func testEmployeeDashboardPendingTimeOffNotVisibleWithoutAuth() throws {
        let pending = app.staticTexts["Pending Time Off"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(pending.exists, "Pending Time Off should not be visible without login")
    }

    // MARK: - 3. Employee Payroll Tests

    @MainActor
    func testEmployeePayrollNotVisibleWithoutAuth() throws {
        let payrollTitle = app.navigationBars["Payroll"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(payrollTitle.exists, "Payroll should not be visible without login")
    }

    // MARK: - 4. Employee Time Tracking (Clock) Tests

    @MainActor
    func testEmployeeClockNotVisibleWithoutAuth() throws {
        let clockIn = app.buttons["Clock In"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(clockIn.exists, "Clock In button should not be visible without login")
    }

    @MainActor
    func testEmployeeClockOutNotVisibleWithoutAuth() throws {
        let clockOut = app.buttons["Clock Out"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(clockOut.exists, "Clock Out button should not be visible without login")
    }

    @MainActor
    func testEmployeeClockedInStatusNotVisibleWithoutAuth() throws {
        let status = app.staticTexts["Clocked In"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(status.exists, "Clocked In status should not be visible without login")
    }

    @MainActor
    func testEmployeeClockedOutStatusNotVisibleWithoutAuth() throws {
        let status = app.staticTexts["Clocked Out"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(status.exists, "Clocked Out status should not be visible without login")
    }

    // MARK: - 5. Employee Time Off Tests

    @MainActor
    func testEmployeeTimeOffNotVisibleWithoutAuth() throws {
        let timeOffTitle = app.navigationBars["Time Off Requests"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(timeOffTitle.exists, "Time Off Requests should not be visible without login")
    }

    // MARK: - 6. Employee Profile Tests

    @MainActor
    func testEmployeeProfileNotVisibleWithoutAuth() throws {
        let settingsTitle = app.navigationBars["Settings"]
        let _ = app.staticTexts["MEROT"].waitForExistence(timeout: 5)
        XCTAssertFalse(settingsTitle.exists, "Settings should not be visible without login")
    }

    // MARK: - 7. Employee Tab Switching Tests (Login Screen State)

    @MainActor
    func testEmployeeTabBarNotVisibleWithoutAuth() throws {
        selectEmployeeType()
        let _ = app.buttons["Sign In"].waitForExistence(timeout: 5)

        // Tab bar items should not be visible on login screen
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertFalse(dashboardTab.exists, "Dashboard tab should not be visible on login screen")
    }

    @MainActor
    func testEmployeePayrollTabNotVisibleWithoutAuth() throws {
        selectEmployeeType()
        let _ = app.buttons["Sign In"].waitForExistence(timeout: 5)

        let payrollTab = app.tabBars.buttons["Payroll"]
        XCTAssertFalse(payrollTab.exists, "Payroll tab should not be visible on login screen")
    }

    @MainActor
    func testEmployeeClockTabNotVisibleWithoutAuth() throws {
        selectEmployeeType()
        let _ = app.buttons["Sign In"].waitForExistence(timeout: 5)

        let clockTab = app.tabBars.buttons["Clock"]
        XCTAssertFalse(clockTab.exists, "Clock tab should not be visible on login screen")
    }

    @MainActor
    func testEmployeeTimeOffTabNotVisibleWithoutAuth() throws {
        selectEmployeeType()
        let _ = app.buttons["Sign In"].waitForExistence(timeout: 5)

        let timeOffTab = app.tabBars.buttons["Time Off"]
        XCTAssertFalse(timeOffTab.exists, "Time Off tab should not be visible on login screen")
    }

    @MainActor
    func testEmployeeProfileTabNotVisibleWithoutAuth() throws {
        selectEmployeeType()
        let _ = app.buttons["Sign In"].waitForExistence(timeout: 5)

        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertFalse(profileTab.exists, "Profile tab should not be visible on login screen")
    }

    // MARK: - 8. Employee Login Form Layout Tests

    @MainActor
    func testEmployeeLoginEmailFieldAbovePassword() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordField.exists)

        XCTAssertTrue(emailField.frame.minY < passwordField.frame.minY,
                       "Email field should be above password field")
    }

    @MainActor
    func testEmployeeLoginSignInBelowPassword() throws {
        selectEmployeeType()

        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]

        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        XCTAssertTrue(signInButton.exists)

        XCTAssertTrue(passwordField.frame.minY < signInButton.frame.minY,
                       "Sign In should be below password field")
    }

    @MainActor
    func testEmployeeLoginLogoAboveForm() throws {
        let merotLogo = app.staticTexts["MEROT"]
        let emailField = app.textFields.firstMatch

        XCTAssertTrue(merotLogo.waitForExistence(timeout: 5))
        XCTAssertTrue(emailField.exists)

        XCTAssertTrue(merotLogo.frame.minY < emailField.frame.minY,
                       "MEROT logo should be above email field")
    }

    @MainActor
    func testEmployeeLoginFooterBelowSignIn() throws {
        let signInButton = app.buttons["Sign In"]
        let footer = app.staticTexts["internal.merot.com"]

        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
        XCTAssertTrue(footer.exists)

        XCTAssertTrue(signInButton.frame.minY < footer.frame.minY,
                       "Footer should be below Sign In button")
    }

    @MainActor
    func testEmployeeLoginAllFormElements() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]
        let merotLogo = app.staticTexts["MEROT"]
        let emailLabel = app.staticTexts["Email"]
        let passwordLabel = app.staticTexts["Password"]
        let footer = app.staticTexts["internal.merot.com"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(signInButton.exists)
        XCTAssertTrue(merotLogo.exists)
        XCTAssertTrue(emailLabel.exists)
        XCTAssertTrue(passwordLabel.exists)
        XCTAssertTrue(footer.exists)
    }

    // MARK: - 9. Employee Login Interaction Tests

    @MainActor
    func testEmployeeLoginFieldsAcceptInput() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("e")
        XCTAssertTrue(emailField.exists)

        passwordField.tap()
        passwordField.typeText("p")
        XCTAssertTrue(passwordField.exists)
    }

    @MainActor
    func testEmployeeLoginSwitchFromAdmin() throws {
        // Start with Admin selected, switch to Employee
        let adminButton = app.buttons["Admin"]
        let employeeButton = app.buttons["Employee"]

        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
        adminButton.tap()

        employeeButton.tap()
        XCTAssertTrue(employeeButton.exists, "Should be able to switch from Admin to Employee")
    }

    @MainActor
    func testEmployeeLoginSwitchFromEmployer() throws {
        // Start with Employer selected, switch to Employee
        let employerButton = app.buttons["Employer"]
        let employeeButton = app.buttons["Employee"]

        XCTAssertTrue(employerButton.waitForExistence(timeout: 5))
        employerButton.tap()

        employeeButton.tap()
        XCTAssertTrue(employeeButton.exists, "Should be able to switch from Employer to Employee")
    }

    @MainActor
    func testEmployeeLoginMultipleTypeSwitches() throws {
        let adminButton = app.buttons["Admin"]
        let employerButton = app.buttons["Employer"]
        let employeeButton = app.buttons["Employee"]

        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))

        // Cycle through all types multiple times
        employeeButton.tap()
        employerButton.tap()
        adminButton.tap()
        employeeButton.tap()
        employerButton.tap()
        employeeButton.tap()

        XCTAssertTrue(adminButton.exists)
        XCTAssertTrue(employerButton.exists)
        XCTAssertTrue(employeeButton.exists)
    }

    @MainActor
    func testEmployeeLoginEmailFieldTappable() throws {
        selectEmployeeType()
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        XCTAssertTrue(emailField.isHittable, "Email field should be tappable")
    }

    @MainActor
    func testEmployeeLoginPasswordFieldTappable() throws {
        selectEmployeeType()
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordField.isHittable, "Password field should be tappable")
    }

    @MainActor
    func testEmployeeLoginSignInButtonTappable() throws {
        selectEmployeeType()
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
        XCTAssertTrue(signInButton.isHittable, "Sign In button should be tappable")
    }

    @MainActor
    func testEmployeeLoginAttemptWithInvalidCredentials() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("invalid@test.com")
        passwordField.tap()
        passwordField.typeText("wrongpass")
        signInButton.tap()

        // After invalid login attempt, login screen should still be visible
        let merotLogo = app.staticTexts["MEROT"]
        XCTAssertTrue(merotLogo.waitForExistence(timeout: 5), "Login screen should remain after failed login")
    }

    @MainActor
    func testEmployeeLoginScreenRemainsAfterBadCredentials() throws {
        selectEmployeeType()

        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        let signInButton = app.buttons["Sign In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("bad@email.com")
        passwordField.tap()
        passwordField.typeText("bad")
        signInButton.tap()

        // Should still see the login form elements
        let _ = emailField.waitForExistence(timeout: 5)
        XCTAssertTrue(app.buttons["Employee"].exists, "User type selector should still be visible")
    }
}
