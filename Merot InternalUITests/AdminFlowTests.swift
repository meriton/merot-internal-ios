import XCTest

final class AdminFlowTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        loginAsAdmin()
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

    private func loginAsAdmin() {
        // Check if already on admin dashboard
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        let moreTab = app.tabBars.buttons["More"]
        if dashboardTab.waitForExistence(timeout: 3) && moreTab.exists {
            // Already logged in as admin
            dashboardTab.tap()
            return
        }

        // Not logged in or wrong user type — logout and re-login
        logoutIfNeeded()

        let adminButton = app.buttons["Admin"]
        guard adminButton.waitForExistence(timeout: 5) else {
            XCTFail("Login screen should appear")
            return
        }
        adminButton.tap()

        let emailField = app.textFields.firstMatch
        guard emailField.waitForExistence(timeout: 5) else {
            XCTFail("Email field should exist")
            return
        }
        emailField.tap()
        emailField.typeText("meriton@merot.com")

        let passwordField = app.secureTextFields.firstMatch
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["Sign In"].tap()

        // Wait for dashboard to load
        let loaded = app.tabBars.buttons["Dashboard"].waitForExistence(timeout: 10)
        XCTAssertTrue(loaded, "Dashboard tab should appear after admin login")
    }

    // MARK: - Dashboard Tests

    @MainActor
    func testDashboardShowsWelcomeText() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let welcome = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcome.waitForExistence(timeout: 10), "Dashboard should show Welcome text with admin name")
    }

    @MainActor
    func testDashboardShowsActiveEmployeesStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Active Employees"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show 'Active Employees' stat card")
    }

    @MainActor
    func testDashboardShowsClockedInStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Clocked In"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show 'Clocked In' stat card")
    }

    @MainActor
    func testDashboardShowsOutstandingStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Outstanding"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show 'Outstanding' invoices stat card")
    }

    @MainActor
    func testDashboardShowsEmployersStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Employers"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show 'Employers' stat card")
    }

    @MainActor
    func testDashboardShowsPendingTimeOffStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Pending Time Off"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show 'Pending Time Off' stat card")
    }

    @MainActor
    func testDashboardShowsOnLeaveStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["On Leave"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show 'On Leave' stat card")
    }

    // MARK: - Employees Tab Tests

    @MainActor
    func testEmployeesTabLoads() throws {
        app.tabBars.buttons["Employees"].tap()

        // Employees list should load — look for search field or employee rows
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Employees tab should show search field")
    }

    @MainActor
    func testEmployeesTabShowsFilterChips() throws {
        app.tabBars.buttons["Employees"].tap()

        let allFilter = app.buttons["All"]
        XCTAssertTrue(allFilter.waitForExistence(timeout: 10), "Employees tab should show 'All' filter chip")

        let activeFilter = app.buttons["Active"]
        XCTAssertTrue(activeFilter.exists, "Employees tab should show 'Active' filter chip")
    }

    @MainActor
    func testEmployeesTabShowsEmployeeData() throws {
        app.tabBars.buttons["Employees"].tap()

        // Wait for employee list to load — there should be at least one status badge
        // (active/terminated) which indicates data loaded
        let activeBadge = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
        XCTAssertTrue(activeBadge.waitForExistence(timeout: 10), "Employees list should show employee data with status badges")
    }

    @MainActor
    func testEmployeeDetailLoads() throws {
        app.tabBars.buttons["Employees"].tap()

        // Wait for list to load, then tap first employee
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))

        // Wait a moment for the list to populate
        sleep(2)

        // Tap the first cell in the list (employee row)
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        } else {
            // Employees may be in a ScrollView with LazyVStack, not cells
            // Try tapping any navigation link content
            let anyEmployee = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
            if anyEmployee.waitForExistence(timeout: 5) {
                anyEmployee.tap()
            }
        }

        // Verify employee detail page loads with Personal Information section
        let personalInfo = app.staticTexts["Personal Information"]
        XCTAssertTrue(personalInfo.waitForExistence(timeout: 10), "Employee detail should show 'Personal Information' card")
    }

    @MainActor
    func testEmployeeDetailShowsEmail() throws {
        app.tabBars.buttons["Employees"].tap()

        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        sleep(2)

        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        } else {
            let anyEmployee = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
            if anyEmployee.waitForExistence(timeout: 5) {
                anyEmployee.tap()
            }
        }

        // Verify email info row is present
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 10), "Employee detail should show Email info row")
    }

    // MARK: - Invoices Tab Tests

    @MainActor
    func testInvoicesTabLoads() throws {
        app.tabBars.buttons["Invoices"].tap()

        let searchField = app.textFields["Search invoices..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Invoices tab should show search field")
    }

    @MainActor
    func testInvoicesTabShowsStatusFilters() throws {
        app.tabBars.buttons["Invoices"].tap()

        // Invoice status filters should be visible
        let draftFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Draft")).firstMatch
        let paidFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Paid")).firstMatch

        // At least one filter should exist
        let hasFilters = draftFilter.waitForExistence(timeout: 10) || paidFilter.exists
        XCTAssertTrue(hasFilters, "Invoices tab should show status filter chips")
    }

    @MainActor
    func testInvoicesTabShowsInvoiceData() throws {
        app.tabBars.buttons["Invoices"].tap()

        // Invoices should show amounts (containing $ or EUR or currency symbols)
        // or invoice numbers (containing #)
        let invoiceContent = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "INV")).firstMatch
        let amountContent = app.staticTexts.containing(NSPredicate(format: "label MATCHES %@", ".*\\$.*|.*EUR.*|.*MKD.*|.*\\d+\\.\\d{2}.*")).firstMatch

        let hasData = invoiceContent.waitForExistence(timeout: 10) || amountContent.waitForExistence(timeout: 5)
        // If no invoices exist, we should see "No invoices found"
        let emptyState = app.staticTexts["No invoices found"]
        XCTAssertTrue(hasData || emptyState.exists, "Invoices tab should show invoice data or empty state")
    }

    @MainActor
    func testInvoiceDetailLoads() throws {
        app.tabBars.buttons["Invoices"].tap()

        let searchField = app.textFields["Search invoices..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        sleep(2)

        // Check if there are invoices to tap
        let emptyState = app.staticTexts["No invoices found"]
        if emptyState.exists {
            // No invoices to test detail for — skip gracefully
            return
        }

        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        } else {
            // Try tapping an invoice number link
            let invoiceLink = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "INV")).firstMatch
            if invoiceLink.waitForExistence(timeout: 5) {
                invoiceLink.tap()
            }
        }

        // Invoice detail should show Details section and Actions
        let detailsSection = app.staticTexts["Details"]
        let actionsSection = app.staticTexts["Actions"]
        let hasDetail = detailsSection.waitForExistence(timeout: 10) || actionsSection.waitForExistence(timeout: 5)
        XCTAssertTrue(hasDetail, "Invoice detail should show 'Details' or 'Actions' section")
    }

    // MARK: - Hiring Tab Tests

    @MainActor
    func testHiringTabShowsPostingsSegment() throws {
        app.tabBars.buttons["Hiring"].tap()

        let postingsSegment = app.buttons["Postings"]
        XCTAssertTrue(postingsSegment.waitForExistence(timeout: 10), "Hiring tab should show 'Postings' segment")
    }

    @MainActor
    func testHiringTabShowsApplicationsSegment() throws {
        app.tabBars.buttons["Hiring"].tap()

        let applicationsSegment = app.buttons["Applications"]
        XCTAssertTrue(applicationsSegment.waitForExistence(timeout: 10), "Hiring tab should show 'Applications' segment")
    }

    @MainActor
    func testHiringTabPostingsSearchField() throws {
        app.tabBars.buttons["Hiring"].tap()

        // Postings tab should have search field
        let searchField = app.textFields["Search postings..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Hiring Postings should show search field")
    }

    @MainActor
    func testHiringTabSwitchToApplications() throws {
        app.tabBars.buttons["Hiring"].tap()

        let applicationsSegment = app.buttons["Applications"]
        XCTAssertTrue(applicationsSegment.waitForExistence(timeout: 10))
        applicationsSegment.tap()

        // Applications tab should show search field
        let searchField = app.textFields["Search applications..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Hiring Applications should show search field")
    }

    // MARK: - More Tab Tests

    @MainActor
    func testMoreTabShowsEmployersLink() throws {
        app.tabBars.buttons["More"].tap()

        let employers = app.staticTexts["Employers"]
        XCTAssertTrue(employers.waitForExistence(timeout: 10), "More tab should show 'Employers' link")
    }

    @MainActor
    func testMoreTabShowsPayrollLink() throws {
        app.tabBars.buttons["More"].tap()

        let payroll = app.staticTexts["Payroll"]
        XCTAssertTrue(payroll.waitForExistence(timeout: 10), "More tab should show 'Payroll' link")
    }

    @MainActor
    func testMoreTabShowsTimeOffRequestsLink() throws {
        app.tabBars.buttons["More"].tap()

        let timeOff = app.staticTexts["Time Off Requests"]
        XCTAssertTrue(timeOff.waitForExistence(timeout: 10), "More tab should show 'Time Off Requests' link")
    }

    @MainActor
    func testMoreTabShowsSettingsLink() throws {
        app.tabBars.buttons["More"].tap()

        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 10), "More tab should show 'Settings' link")
    }

    @MainActor
    func testMoreTabShowsLogoutButton() throws {
        app.tabBars.buttons["More"].tap()

        // Scroll down to find logout
        app.swipeUp()
        let logout = app.buttons["Logout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 5), "More tab should show 'Logout' button")
    }

    @MainActor
    func testMoreTabShowsAgreementsLinks() throws {
        app.tabBars.buttons["More"].tap()

        let employeeAgreements = app.staticTexts["Employee Agreements"]
        XCTAssertTrue(employeeAgreements.waitForExistence(timeout: 10), "More tab should show 'Employee Agreements' link")

        let serviceAgreements = app.staticTexts["Service Agreements"]
        XCTAssertTrue(serviceAgreements.exists, "More tab should show 'Service Agreements' link")
    }

    @MainActor
    func testMoreTabShowsHolidaysLink() throws {
        app.tabBars.buttons["More"].tap()

        app.swipeUp()
        let holidays = app.staticTexts["Holidays"]
        XCTAssertTrue(holidays.waitForExistence(timeout: 5), "More tab should show 'Holidays' link")
    }

    // MARK: - More Tab Navigation Tests

    @MainActor
    func testMoreTabEmployersNavigationLoadsData() throws {
        app.tabBars.buttons["More"].tap()

        let employers = app.staticTexts["Employers"]
        XCTAssertTrue(employers.waitForExistence(timeout: 10))
        employers.tap()

        // Employers list should load with search field
        let searchField = app.textFields["Search employers..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Employers list should show search field after navigation")
    }

    @MainActor
    func testMoreTabPayrollNavigationLoadsData() throws {
        app.tabBars.buttons["More"].tap()

        let payroll = app.staticTexts["Payroll"]
        XCTAssertTrue(payroll.waitForExistence(timeout: 10))
        payroll.tap()

        // Payroll list should load — either with batch data or empty state
        let hasBatches = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "records")).firstMatch
            .waitForExistence(timeout: 10)
        let emptyState = app.staticTexts["No payroll batches"].exists
        XCTAssertTrue(hasBatches || emptyState, "Payroll page should show batch data or empty state")
    }

    @MainActor
    func testMoreTabSettingsShowsProfileInfo() throws {
        app.tabBars.buttons["More"].tap()

        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()

        // Settings should show profile details
        let profileDetails = app.staticTexts["Profile Details"]
        XCTAssertTrue(profileDetails.waitForExistence(timeout: 10), "Settings should show 'Profile Details' section")
    }

    @MainActor
    func testMoreTabSettingsShowsAppInfo() throws {
        app.tabBars.buttons["More"].tap()

        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()

        // Scroll down to app info
        app.swipeUp()
        let appInfo = app.staticTexts["App Info"]
        XCTAssertTrue(appInfo.waitForExistence(timeout: 10), "Settings should show 'App Info' section")
    }

    @MainActor
    func testMoreTabSettingsShowsUserEmail() throws {
        app.tabBars.buttons["More"].tap()

        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()

        // Should show the logged-in user's email
        let email = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "merot.com")).firstMatch
        XCTAssertTrue(email.waitForExistence(timeout: 10), "Settings should display user email containing 'merot.com'")
    }

    @MainActor
    func testMoreTabTimeOffRequestsLoads() throws {
        app.tabBars.buttons["More"].tap()

        let timeOff = app.staticTexts["Time Off Requests"]
        XCTAssertTrue(timeOff.waitForExistence(timeout: 10))
        timeOff.tap()

        // Time Off view should load — either with requests or empty state
        let hasRequests = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "pending")).firstMatch
            .waitForExistence(timeout: 10)
        let allCaughtUp = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "caught up")).firstMatch.exists
        let noRequests = app.staticTexts["No time off requests"].exists
        let hasFilterChips = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Pending")).firstMatch.exists

        XCTAssertTrue(hasRequests || allCaughtUp || noRequests || hasFilterChips,
                       "Time Off Requests page should show data, empty state, or filter controls")
    }
}
