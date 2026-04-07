import XCTest

final class EmployeeFlowTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        loginAsEmployee()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private func logoutIfNeeded() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 3) {
            let moreTab = app.tabBars.buttons["More"]
            let profileTab = app.tabBars.buttons["Profile"]
            if moreTab.exists {
                moreTab.tap()
                let logoutButton = app.buttons["Logout"]
                if logoutButton.waitForExistence(timeout: 3) {
                    logoutButton.tap()
                    return
                }
                app.swipeUp()
                if logoutButton.waitForExistence(timeout: 2) {
                    logoutButton.tap()
                }
            } else if profileTab.exists {
                profileTab.tap()
                // Settings view has a Logout button
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

    private func loginAsEmployee() {
        // Check if already on employee dashboard (has Payroll and Clock tabs)
        let payrollTab = app.tabBars.buttons["Payroll"]
        let clockTab = app.tabBars.buttons["Clock"]
        if payrollTab.waitForExistence(timeout: 3) && clockTab.exists {
            app.tabBars.buttons["Dashboard"].tap()
            return
        }

        // Not logged in as employee — logout and re-login
        logoutIfNeeded()

        let employeeButton = app.buttons["Employee"]
        guard employeeButton.waitForExistence(timeout: 5) else {
            XCTFail("Login screen should appear")
            return
        }
        employeeButton.tap()

        let emailField = app.textFields.firstMatch
        guard emailField.waitForExistence(timeout: 5) else {
            XCTFail("Email field should exist")
            return
        }
        emailField.tap()
        emailField.typeText("employee@merot.com")

        let passwordField = app.secureTextFields.firstMatch
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["Sign In"].tap()

        let loaded = app.tabBars.buttons["Dashboard"].waitForExistence(timeout: 10)
        XCTAssertTrue(loaded, "Dashboard tab should appear after employee login")
    }

    // MARK: - Employee Dashboard Tests

    @MainActor
    func testEmployeeDashboardShowsWelcome() throws {
        app.tabBars.buttons["Dashboard"].tap()

        let welcome = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcome.waitForExistence(timeout: 10), "Employee dashboard should show 'Welcome' text with employee name")
    }

    @MainActor
    func testEmployeeDashboardShowsHoursWeekStat() throws {
        app.tabBars.buttons["Dashboard"].tap()

        let stat = app.staticTexts["Hours/Week"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Employee dashboard should show 'Hours/Week' stat")
    }

    @MainActor
    func testEmployeeDashboardShowsHoursMonthStat() throws {
        app.tabBars.buttons["Dashboard"].tap()

        let stat = app.staticTexts["Hours/Month"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Employee dashboard should show 'Hours/Month' stat")
    }

    @MainActor
    func testEmployeeDashboardShowsDaysOffStat() throws {
        app.tabBars.buttons["Dashboard"].tap()

        let stat = app.staticTexts["Days Off"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Employee dashboard should show 'Days Off' stat")
    }

    @MainActor
    func testEmployeeDashboardShowsClockStatus() throws {
        app.tabBars.buttons["Dashboard"].tap()

        // Should show either "Currently Clocked In" or "Not Clocked In"
        let clockedIn = app.staticTexts["Currently Clocked In"]
        let notClockedIn = app.staticTexts["Not Clocked In"]

        let hasClockStatus = clockedIn.waitForExistence(timeout: 10) || notClockedIn.waitForExistence(timeout: 3)
        XCTAssertTrue(hasClockStatus, "Employee dashboard should show clock in/out status")
    }

    @MainActor
    func testEmployeeDashboardShowsLastPaystub() throws {
        app.tabBars.buttons["Dashboard"].tap()

        // Scroll down to find Last Paystub section
        app.swipeUp()
        let paystub = app.staticTexts["Last Paystub"]
        XCTAssertTrue(paystub.waitForExistence(timeout: 10), "Employee dashboard should show 'Last Paystub' section")
    }

    @MainActor
    func testEmployeeDashboardShowsPaystubAmount() throws {
        app.tabBars.buttons["Dashboard"].tap()

        app.swipeUp()
        let paystub = app.staticTexts["Last Paystub"]
        guard paystub.waitForExistence(timeout: 10) else {
            XCTFail("Last Paystub section should exist")
            return
        }

        // Should show a gross salary amount
        let grossLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "gross")).firstMatch
        XCTAssertTrue(grossLabel.waitForExistence(timeout: 5), "Last Paystub should show gross salary amount")
    }

    @MainActor
    func testEmployeeDashboardShowsLeaveBalances() throws {
        app.tabBars.buttons["Dashboard"].tap()

        // Scroll to find Leave Balances
        app.swipeUp()
        app.swipeUp()
        let balances = app.staticTexts["Leave Balances"]
        XCTAssertTrue(balances.waitForExistence(timeout: 10), "Employee dashboard should show 'Leave Balances' section")
    }

    // MARK: - Payroll Tab Tests

    @MainActor
    func testPayrollTabLoads() throws {
        app.tabBars.buttons["Payroll"].tap()

        // Payroll should show either batch data or empty state
        let hasBatches = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "records")).firstMatch
            .waitForExistence(timeout: 10)
        let emptyState = app.staticTexts["No payroll batches"].exists
        // Or it could show month names like "January", "February", etc.
        let hasMonthLabel = app.staticTexts.containing(NSPredicate(format: "label MATCHES %@", ".*(January|February|March|April|May|June|July|August|September|October|November|December).*")).firstMatch.waitForExistence(timeout: 5)

        XCTAssertTrue(hasBatches || emptyState || hasMonthLabel, "Payroll tab should show batch data or empty state")
    }

    // MARK: - Clock Tab Tests

    @MainActor
    func testClockTabShowsClockButton() throws {
        app.tabBars.buttons["Clock"].tap()

        // Should show "Clock In" or "Clock Out" button
        let clockIn = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock In")).firstMatch
        let clockOut = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock Out")).firstMatch

        let hasClockButton = clockIn.waitForExistence(timeout: 10) || clockOut.waitForExistence(timeout: 3)
        XCTAssertTrue(hasClockButton, "Clock tab should show 'Clock In' or 'Clock Out' button")
    }

    @MainActor
    func testClockTabShowsClockStatus() throws {
        app.tabBars.buttons["Clock"].tap()

        // Should show status text "Clocked In" or "Clocked Out"
        let clockedIn = app.staticTexts["Clocked In"]
        let clockedOut = app.staticTexts["Clocked Out"]

        let hasStatus = clockedIn.waitForExistence(timeout: 10) || clockedOut.waitForExistence(timeout: 3)
        XCTAssertTrue(hasStatus, "Clock tab should show current clock status text")
    }

    // MARK: - Time Off Tab Tests

    @MainActor
    func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()

        // Time Off view should load with filter chips or content
        let hasFilterChips = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Pending")).firstMatch
            .waitForExistence(timeout: 10)
        let noRequests = app.staticTexts["No time off requests"].exists
        let allCaughtUp = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "caught up")).firstMatch.exists

        XCTAssertTrue(hasFilterChips || noRequests || allCaughtUp,
                       "Time Off tab should show filter controls, data, or empty state")
    }

    // MARK: - Profile Tab Tests

    @MainActor
    func testProfileTabLoadsSettings() throws {
        app.tabBars.buttons["Profile"].tap()

        // Profile tab renders SettingsView which shows Profile Details
        let profileDetails = app.staticTexts["Profile Details"]
        XCTAssertTrue(profileDetails.waitForExistence(timeout: 10), "Profile tab should show 'Profile Details' section")
    }

    @MainActor
    func testProfileTabShowsEmail() throws {
        app.tabBars.buttons["Profile"].tap()

        // Should show the employee's email
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 10), "Profile should show 'Email' info row")
    }

    @MainActor
    func testProfileTabShowsEditProfileButton() throws {
        app.tabBars.buttons["Profile"].tap()

        let editProfile = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Edit Profile")).firstMatch
        XCTAssertTrue(editProfile.waitForExistence(timeout: 10), "Profile should show 'Edit Profile' button")
    }

    @MainActor
    func testProfileTabShowsChangePasswordButton() throws {
        app.tabBars.buttons["Profile"].tap()

        let changePassword = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Change Password")).firstMatch
        XCTAssertTrue(changePassword.waitForExistence(timeout: 10), "Profile should show 'Change Password' button")
    }

    @MainActor
    func testProfileTabShowsLogoutButton() throws {
        app.tabBars.buttons["Profile"].tap()

        app.swipeUp()
        let logout = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Logout")).firstMatch
        XCTAssertTrue(logout.waitForExistence(timeout: 10), "Profile should show 'Logout' button")
    }

    @MainActor
    func testProfileTabShowsAppVersion() throws {
        app.tabBars.buttons["Profile"].tap()

        app.swipeUp()
        let appInfo = app.staticTexts["App Info"]
        XCTAssertTrue(appInfo.waitForExistence(timeout: 10), "Profile should show 'App Info' section")

        let version = app.staticTexts["2.0.0"]
        XCTAssertTrue(version.exists, "Profile should show app version '2.0.0'")
    }
}
