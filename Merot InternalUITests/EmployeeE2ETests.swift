import XCTest

final class EmployeeE2ETests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        loginAsEmployee()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func loginAsEmployee() {
        // Employee portal has: Dashboard, Payroll, Clock, Time Off, More
        let payrollTab = app.tabBars.buttons["Payroll"]
        let clockTab = app.tabBars.buttons["Clock"]
        if payrollTab.waitForExistence(timeout: 3) && clockTab.exists {
            app.tabBars.buttons["Dashboard"].tap()
            return
        }
        UITestHelpers.logout(app: app)
        UITestHelpers.login(app: app, email: "employee@merot.com", password: "password123", userType: "Employee")
    }

    // MARK: - Dashboard Tests

    @MainActor
    func testDashboardShowsWelcomeName() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome,"),
                      "Employee dashboard should show Welcome text with name")
    }

    @MainActor
    func testDashboardShowsHoursWeekStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Hours/Week"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10),
                      "Employee dashboard should show Hours/Week stat")
    }

    @MainActor
    func testDashboardShowsHoursMonthStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Hours/Month"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10),
                      "Employee dashboard should show Hours/Month stat")
    }

    @MainActor
    func testDashboardShowsDaysOffStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Days Off"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10),
                      "Employee dashboard should show Days Off stat")
    }

    @MainActor
    func testDashboardShowsClockStatus() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let clockedIn = app.staticTexts["Currently Clocked In"]
        let notClockedIn = app.staticTexts["Not Clocked In"]
        let hasStatus = clockedIn.waitForExistence(timeout: 10) || notClockedIn.waitForExistence(timeout: 3)
        XCTAssertTrue(hasStatus,
                      "Employee dashboard should show clock status (Currently Clocked In or Not Clocked In)")
    }

    @MainActor
    func testDashboardShowsLastPaystub() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        let paystub = app.staticTexts["Last Paystub"]
        XCTAssertTrue(paystub.waitForExistence(timeout: 10),
                      "Employee dashboard should show Last Paystub section")
    }

    @MainActor
    func testDashboardLastPaystubShowsGrossAmount() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        let paystub = app.staticTexts["Last Paystub"]
        guard paystub.waitForExistence(timeout: 10) else {
            XCTFail("Last Paystub section should exist")
            return
        }
        let grossLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "gross")).firstMatch
        XCTAssertTrue(grossLabel.waitForExistence(timeout: 5),
                      "Last Paystub should show gross salary amount")
    }

    @MainActor
    func testDashboardShowsLeaveBalances() throws {
        app.tabBars.buttons["Dashboard"].tap()
        app.swipeUp()
        app.swipeUp()
        let balances = app.staticTexts["Leave Balances"]
        XCTAssertTrue(balances.waitForExistence(timeout: 10),
                      "Employee dashboard should show Leave Balances section")
    }

    @MainActor
    func testDashboardPullToRefreshWorks() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let welcome = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcome.waitForExistence(timeout: 10))
        app.swipeDown()
        XCTAssertTrue(welcome.waitForExistence(timeout: 10),
                      "Dashboard should reload after pull-to-refresh")
    }

    // MARK: - Payroll Tab Tests

    @MainActor
    func testPayrollTabLoads() throws {
        app.tabBars.buttons["Payroll"].tap()
        sleep(2)
        // Should show payroll records or empty state
        let hasRecords = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Net")).firstMatch
            .waitForExistence(timeout: 10)
        let emptyState = app.staticTexts["No payroll records"].exists
        let hasMonthLabel = app.staticTexts.containing(NSPredicate(format: "label MATCHES %@", ".*(January|February|March|April|May|June|July|August|September|October|November|December).*")).firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(hasRecords || emptyState || hasMonthLabel,
                      "Payroll tab should show payroll records or empty state")
    }

    @MainActor
    func testPayrollRecordDetailShowsEarningsAndDeductions() throws {
        app.tabBars.buttons["Payroll"].tap()
        sleep(3)
        let emptyState = app.staticTexts["No payroll records"]
        if emptyState.waitForExistence(timeout: 5) { return }
        // Tap first payroll record
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        let earnings = app.staticTexts["Earnings"]
        XCTAssertTrue(earnings.waitForExistence(timeout: 10),
                      "Payroll detail should show Earnings section")
        let deductions = app.staticTexts["Deductions"]
        XCTAssertTrue(deductions.exists,
                      "Payroll detail should show Deductions section")
    }

    @MainActor
    func testPayrollRecordDetailShowsDownloadPaystub() throws {
        app.tabBars.buttons["Payroll"].tap()
        sleep(3)
        let emptyState = app.staticTexts["No payroll records"]
        if emptyState.waitForExistence(timeout: 5) { return }
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        app.swipeUp()
        let download = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Download Paystub")).firstMatch
        XCTAssertTrue(download.waitForExistence(timeout: 10),
                      "Payroll detail should show Download Paystub button")
    }

    // MARK: - Clock Tab Tests

    @MainActor
    func testClockTabShowsClockButton() throws {
        app.tabBars.buttons["Clock"].tap()
        let clockIn = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock In")).firstMatch
        let clockOut = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock Out")).firstMatch
        let hasButton = clockIn.waitForExistence(timeout: 10) || clockOut.waitForExistence(timeout: 3)
        XCTAssertTrue(hasButton,
                      "Clock tab should show Clock In or Clock Out button")
    }

    @MainActor
    func testClockTabShowsClockStatus() throws {
        app.tabBars.buttons["Clock"].tap()
        let clockedIn = app.staticTexts["Clocked In"]
        let clockedOut = app.staticTexts["Clocked Out"]
        let hasStatus = clockedIn.waitForExistence(timeout: 10) || clockedOut.waitForExistence(timeout: 3)
        XCTAssertTrue(hasStatus,
                      "Clock tab should show current clock status (Clocked In or Clocked Out)")
    }

    @MainActor
    func testClockTabToggleChangesState() throws {
        app.tabBars.buttons["Clock"].tap()
        sleep(2)
        let clockIn = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock In")).firstMatch
        let clockOut = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock Out")).firstMatch
        let wasClockedIn = clockOut.exists
        // Tap the clock button
        if wasClockedIn {
            clockOut.tap()
        } else if clockIn.exists {
            clockIn.tap()
        }
        sleep(3)
        // Status should have toggled
        if wasClockedIn {
            let nowClockIn = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock In")).firstMatch
            XCTAssertTrue(nowClockIn.waitForExistence(timeout: 10),
                          "After clocking out, should show Clock In button")
        } else {
            let nowClockOut = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock Out")).firstMatch
            XCTAssertTrue(nowClockOut.waitForExistence(timeout: 10),
                          "After clocking in, should show Clock Out button")
        }
        // Toggle back to restore original state
        let currentButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Clock")).firstMatch
        if currentButton.waitForExistence(timeout: 5) {
            currentButton.tap()
            sleep(2)
        }
    }

    @MainActor
    func testClockTabShowsRecentActivity() throws {
        app.tabBars.buttons["Clock"].tap()
        let recentActivity = app.staticTexts["Recent Activity"]
        XCTAssertTrue(recentActivity.waitForExistence(timeout: 10),
                      "Clock tab should show Recent Activity section")
    }

    // MARK: - Time Off Tab Tests

    @MainActor
    func testTimeOffTabLoads() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let noRequests = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No time off")).firstMatch
        let hasRequests = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Time Off")).firstMatch
        XCTAssertTrue(noRequests.waitForExistence(timeout: 10) || hasRequests.waitForExistence(timeout: 5),
                      "Time Off tab should show requests or empty state")
    }

    @MainActor
    func testTimeOffPlusOpensCreateForm() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        // Tap the + button in the navigation bar
        let plusButton = app.navigationBars.buttons.element(boundBy: 0)
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
        }
        // Should show the create form with "New Time Off Request" title or "Leave Type"
        let formTitle = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Leave Type")).firstMatch
        let navTitle = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "New Time Off")).firstMatch
        let startDate = app.staticTexts["Start Date"]
        XCTAssertTrue(formTitle.waitForExistence(timeout: 10) || navTitle.waitForExistence(timeout: 5) || startDate.waitForExistence(timeout: 5),
                      "Tapping + should open time off request creation form")
    }

    @MainActor
    func testTimeOffCreateFormHasDatePickers() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let plusButton = app.navigationBars.buttons.element(boundBy: 0)
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
        }
        sleep(2)
        let startDate = app.staticTexts["Start Date"]
        let endDate = app.staticTexts["End Date"]
        XCTAssertTrue(startDate.waitForExistence(timeout: 10),
                      "Create time off form should show Start Date picker")
        XCTAssertTrue(endDate.exists,
                      "Create time off form should show End Date picker")
    }

    @MainActor
    func testTimeOffCreateFormCancelReturns() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(2)
        let plusButton = app.navigationBars.buttons.element(boundBy: 0)
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
        }
        sleep(2)
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()
        // Should return to time off list
        let tabBar = app.tabBars.buttons["Time Off"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5),
                      "Cancelling form should return to time off list")
    }

    @MainActor
    func testTimeOffShowsPendingRequests() throws {
        app.tabBars.buttons["Time Off"].tap()
        sleep(3)
        // Check for pending status badges or empty state
        let pendingBadge = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "pending")).firstMatch
        let noRequests = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No time off")).firstMatch
        let approvedBadge = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "approved")).firstMatch
        XCTAssertTrue(pendingBadge.waitForExistence(timeout: 10) || noRequests.exists || approvedBadge.exists,
                      "Time Off should show requests with status or empty state")
    }

    // MARK: - More Tab Tests (Employee)

    @MainActor
    func testMoreTabShowsVerificationLettersLink() throws {
        app.tabBars.buttons["More"].tap()
        let verificationLink = app.staticTexts["Verification Letters"]
        XCTAssertTrue(verificationLink.waitForExistence(timeout: 10),
                      "Employee More tab should show Verification Letters link")
    }

    @MainActor
    func testMoreTabShowsProfileLink() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10),
                      "Employee More tab should show Profile link")
    }

    @MainActor
    func testMoreTabProfileShowsEmail() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10))
        profileLink.tap()
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 10),
                      "Employee profile should show Email row")
    }

    @MainActor
    func testMoreTabProfileShowsName() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10))
        profileLink.tap()
        // Should show the employee's name
        let hasName = UITestHelpers.waitForText(app: app, text: "Contact Info", timeout: 10)
        XCTAssertTrue(hasName, "Employee profile should load with Contact Info section")
    }

    @MainActor
    func testMoreTabProfileShowsEditProfileButton() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10))
        profileLink.tap()
        let editProfile = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Edit Profile")).firstMatch
        XCTAssertTrue(editProfile.waitForExistence(timeout: 10),
                      "Employee profile should show Edit Profile button")
    }

    @MainActor
    func testMoreTabProfileShowsChangePasswordButton() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10))
        profileLink.tap()
        let changePassword = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Change Password")).firstMatch
        XCTAssertTrue(changePassword.waitForExistence(timeout: 10),
                      "Employee profile should show Change Password button")
    }

    @MainActor
    func testMoreTabProfileShowsLogoutButton() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10))
        profileLink.tap()
        app.swipeUp()
        let logout = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Logout")).firstMatch
        XCTAssertTrue(logout.waitForExistence(timeout: 10),
                      "Employee profile should show Logout button")
    }

    @MainActor
    func testMoreTabVerificationLettersLoads() throws {
        app.tabBars.buttons["More"].tap()
        let verificationLink = app.staticTexts["Verification Letters"]
        XCTAssertTrue(verificationLink.waitForExistence(timeout: 10))
        verificationLink.tap()
        sleep(2)
        // Should show verification requests or empty state
        let emptyState = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No verification")).firstMatch
        let title = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Verification")).firstMatch
        XCTAssertTrue(emptyState.waitForExistence(timeout: 10) || title.waitForExistence(timeout: 5),
                      "Verification Letters page should load")
    }

    @MainActor
    func testMoreTabProfileShowsAppVersion() throws {
        app.tabBars.buttons["More"].tap()
        let profileLink = app.staticTexts["Profile"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 10))
        profileLink.tap()
        app.swipeUp()
        let appInfo = app.staticTexts["App Info"]
        XCTAssertTrue(appInfo.waitForExistence(timeout: 10),
                      "Employee profile should show App Info section")
        let version = app.staticTexts["2.0.0"]
        XCTAssertTrue(version.exists,
                      "Employee profile should show app version 2.0.0")
    }

    // MARK: - Login / Tab Bar Tests

    @MainActor
    func testEmployeeTabBarHasCorrectTabs() throws {
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists, "Employee should have Dashboard tab")
        XCTAssertTrue(app.tabBars.buttons["Payroll"].exists, "Employee should have Payroll tab")
        XCTAssertTrue(app.tabBars.buttons["Clock"].exists, "Employee should have Clock tab")
        XCTAssertTrue(app.tabBars.buttons["Time Off"].exists, "Employee should have Time Off tab")
        XCTAssertTrue(app.tabBars.buttons["More"].exists, "Employee should have More tab")
    }
}
