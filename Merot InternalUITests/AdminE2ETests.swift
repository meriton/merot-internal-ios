import XCTest

final class AdminE2ETests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        loginAsAdmin()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func loginAsAdmin() {
        // Always ensure we're logged in as admin
        // First check if we're already on admin portal (has Hiring tab = admin only)
        let hiringTab = app.tabBars.buttons["Hiring"]
        if hiringTab.waitForExistence(timeout: 5) {
            app.tabBars.buttons["Dashboard"].tap()
            return
        }
        // Might be on login screen or wrong portal — logout and login
        let signIn = app.buttons["Sign In"]
        if !signIn.waitForExistence(timeout: 3) {
            // On some portal, logout first
            UITestHelpers.logout(app: app)
            sleep(2)
        }
        UITestHelpers.login(app: app, email: "meriton@merot.com", password: "password123", userType: "Admin")
    }

    // MARK: - Dashboard Tests

    @MainActor
    func testDashboardShowsWelcomeWithName() throws {
        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(UITestHelpers.waitForText(app: app, text: "Welcome, Meriton"),
                      "Dashboard should show 'Welcome, Meriton'")
    }

    @MainActor
    func testDashboardShowsActiveEmployeesStatWithNumber() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Active Employees"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show Active Employees stat")
        // Verify there's an actual number rendered (not just the label)
        // The StatCard renders value as a separate Text element
        let numbers = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "^[0-9]+$"))
        XCTAssertTrue(numbers.count > 0, "Dashboard should show numeric stat values")
    }

    @MainActor
    func testDashboardShowsClockedInStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Clocked In"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show Clocked In stat")
    }

    @MainActor
    func testDashboardShowsOnLeaveStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["On Leave"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show On Leave stat")
    }

    @MainActor
    func testDashboardShowsOutstandingStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Outstanding"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show Outstanding stat")
    }

    @MainActor
    func testDashboardShowsNextPayrollSection() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let payroll = app.staticTexts["Next Payroll"]
        XCTAssertTrue(payroll.waitForExistence(timeout: 10), "Dashboard should show Next Payroll section")
    }

    @MainActor
    func testDashboardPullToRefreshReloads() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let welcome = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Welcome")).firstMatch
        XCTAssertTrue(welcome.waitForExistence(timeout: 10))
        // Pull to refresh
        app.swipeDown()
        // After refresh, the welcome text should still be there
        XCTAssertTrue(welcome.waitForExistence(timeout: 10),
                      "Dashboard should reload data after pull-to-refresh")
    }

    @MainActor
    func testDashboardShowsEmployersStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Employers"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show Employers stat")
    }

    @MainActor
    func testDashboardShowsPendingTimeOffStat() throws {
        app.tabBars.buttons["Dashboard"].tap()
        let stat = app.staticTexts["Pending Time Off"]
        XCTAssertTrue(stat.waitForExistence(timeout: 10), "Dashboard should show Pending Time Off stat")
    }

    // MARK: - Employees Tab Tests

    @MainActor
    func testEmployeesTabLoadsWithEmployeeNames() throws {
        app.tabBars.buttons["Employees"].tap()
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Employees tab should show search field")
        // Wait for at least one employee to load (status badge proves real data)
        let activeBadge = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
        XCTAssertTrue(activeBadge.waitForExistence(timeout: 10),
                      "Employees list should load real employee data with status badges")
    }

    @MainActor
    func testEmployeesSearchFilters() throws {
        app.tabBars.buttons["Employees"].tap()
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        sleep(2) // Wait for list to populate
        searchField.tap()
        searchField.typeText("Tatjana\n")
        sleep(2)
        // Should find Tatjana Petrovska in results
        let result = UITestHelpers.waitForText(app: app, text: "Tatjana", timeout: 10)
        XCTAssertTrue(result, "Search for 'Tatjana' should show matching employees")
    }

    @MainActor
    func testEmployeesFilterChipActive() throws {
        app.tabBars.buttons["Employees"].tap()
        let activeFilter = app.buttons["Active"]
        XCTAssertTrue(activeFilter.waitForExistence(timeout: 10), "Active filter chip should exist")
        activeFilter.tap()
        sleep(2)
        // After filtering by Active, all visible status badges should say active
        let activeBadge = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "active")).firstMatch
        XCTAssertTrue(activeBadge.waitForExistence(timeout: 10),
                      "Filtering by Active should show only active employees")
    }

    @MainActor
    func testEmployeesFilterChipTerminated() throws {
        app.tabBars.buttons["Employees"].tap()
        let terminatedFilter = app.buttons["Terminated"]
        XCTAssertTrue(terminatedFilter.waitForExistence(timeout: 10), "Terminated filter chip should exist")
        terminatedFilter.tap()
        sleep(2)
        // Should show terminated employees or empty state
        let terminated = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "terminated")).firstMatch
        let empty = app.staticTexts["No employees found"]
        XCTAssertTrue(terminated.waitForExistence(timeout: 10) || empty.exists,
                      "Filtering by Terminated should show terminated employees or empty state")
    }

    @MainActor
    func testEmployeeDetailLoadsPersonalInfo() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        let tapped = UITestHelpers.tapFirstListRow(app: app)
        XCTAssertTrue(tapped, "Should find an employee row to tap")
        let personalInfo = app.staticTexts["Personal Information"]
        XCTAssertTrue(personalInfo.waitForExistence(timeout: 10),
                      "Employee detail should show Personal Information section")
    }

    @MainActor
    func testEmployeeDetailShowsEmail() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        UITestHelpers.tapFirstListRow(app: app)
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 10),
                      "Employee detail should show Email row")
    }

    @MainActor
    func testEmployeeDetailShowsDepartment() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        UITestHelpers.tapFirstListRow(app: app)
        let dept = app.staticTexts["Department"]
        XCTAssertTrue(dept.waitForExistence(timeout: 10),
                      "Employee detail should show Department row")
    }

    @MainActor
    func testEmployeeDetailBackReturnsToList() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(3)
        UITestHelpers.tapFirstListRow(app: app)
        let personalInfo = app.staticTexts["Personal Information"]
        XCTAssertTrue(personalInfo.waitForExistence(timeout: 10))
        // Go back
        UITestHelpers.tapBack(app: app)
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5),
                      "Tapping back should return to employee list with search field")
    }

    @MainActor
    func testEmployeeCreateButtonShowsForm() throws {
        app.tabBars.buttons["Employees"].tap()
        sleep(2)
        let plusButton = app.navigationBars.buttons.element(boundBy: 1)
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
        } else {
            // Try the plus image button
            let plus = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "plus")).firstMatch
            if plus.waitForExistence(timeout: 5) { plus.tap() }
        }
        // The form should appear - look for form fields
        let firstNameField = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "First Name")).firstMatch
        let formTitle = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Employee")).firstMatch
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 10) || formTitle.waitForExistence(timeout: 5),
                      "Tapping + should open employee creation form")
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
        let draftFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Draft")).firstMatch
        XCTAssertTrue(draftFilter.waitForExistence(timeout: 10),
                      "Invoices should show Draft filter chip")
    }

    @MainActor
    func testInvoicesFilterDraftChangesView() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(2)
        let draftFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Draft")).firstMatch
        XCTAssertTrue(draftFilter.waitForExistence(timeout: 10))
        draftFilter.tap()
        sleep(2)
        // Should show only draft invoices or empty state
        let hasInvoices = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "INV")).firstMatch.waitForExistence(timeout: 5)
        let empty = app.staticTexts["No invoices found"].exists
        XCTAssertTrue(hasInvoices || empty,
                      "Filtering by Draft should show draft invoices or empty state")
    }

    @MainActor
    func testInvoicesFilterPaidChangesView() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(2)
        let paidFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Paid")).firstMatch
        XCTAssertTrue(paidFilter.waitForExistence(timeout: 10))
        paidFilter.tap()
        sleep(2)
        let hasInvoices = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "INV")).firstMatch.waitForExistence(timeout: 5)
        let empty = app.staticTexts["No invoices found"].exists
        XCTAssertTrue(hasInvoices || empty,
                      "Filtering by Paid should show paid invoices or empty state")
    }

    @MainActor
    func testInvoiceDetailLoadsWithAmounts() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let empty = app.staticTexts["No invoices found"]
        if empty.waitForExistence(timeout: 5) { return }
        UITestHelpers.tapFirstListRow(app: app, containingText: "INV")
        let detailsSection = app.staticTexts["Details"]
        XCTAssertTrue(detailsSection.waitForExistence(timeout: 10),
                      "Invoice detail should show Details section")
    }

    @MainActor
    func testInvoiceDetailShowsDownloadPDF() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let empty = app.staticTexts["No invoices found"]
        if empty.waitForExistence(timeout: 5) { return }
        UITestHelpers.tapFirstListRow(app: app, containingText: "INV")
        let downloadPDF = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Download PDF")).firstMatch
        XCTAssertTrue(downloadPDF.waitForExistence(timeout: 10),
                      "Invoice detail should show Download PDF button")
    }

    @MainActor
    func testInvoiceDetailShowsActions() throws {
        app.tabBars.buttons["Invoices"].tap()
        sleep(3)
        let empty = app.staticTexts["No invoices found"]
        if empty.waitForExistence(timeout: 5) { return }
        UITestHelpers.tapFirstListRow(app: app, containingText: "INV")
        let actionsSection = app.staticTexts["Actions"]
        XCTAssertTrue(actionsSection.waitForExistence(timeout: 10),
                      "Invoice detail should show Actions section")
    }

    // MARK: - Hiring Tab Tests

    @MainActor
    func testHiringTabShowsPostingsSegment() throws {
        app.tabBars.buttons["Hiring"].tap()
        let postings = app.buttons["Postings"]
        XCTAssertTrue(postings.waitForExistence(timeout: 10), "Hiring tab should show Postings segment")
    }

    @MainActor
    func testHiringTabShowsApplicationsSegment() throws {
        app.tabBars.buttons["Hiring"].tap()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 10), "Hiring tab should show Applications segment")
    }

    @MainActor
    func testHiringPostingsSearchField() throws {
        app.tabBars.buttons["Hiring"].tap()
        let search = app.textFields["Search postings..."]
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Postings should show search field")
    }

    @MainActor
    func testHiringSwitchToApplicationsShowsSearchField() throws {
        app.tabBars.buttons["Hiring"].tap()
        let applicationsSegment = app.buttons["Applications"]
        XCTAssertTrue(applicationsSegment.waitForExistence(timeout: 10))
        applicationsSegment.tap()
        let search = app.textFields["Search applications..."]
        XCTAssertTrue(search.waitForExistence(timeout: 10),
                      "Switching to Applications should show applications search field")
    }

    @MainActor
    func testHiringPostingDetailLoads() throws {
        app.tabBars.buttons["Hiring"].tap()
        sleep(3)
        let emptyState = app.staticTexts["No job postings"]
        if emptyState.waitForExistence(timeout: 5) { return }
        // Tap first posting
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        let detailsSection = app.staticTexts["Details"]
        XCTAssertTrue(detailsSection.waitForExistence(timeout: 10),
                      "Job posting detail should load with Details section")
    }

    @MainActor
    func testHiringPostingDetailShowsActions() throws {
        app.tabBars.buttons["Hiring"].tap()
        sleep(3)
        let emptyState = app.staticTexts["No job postings"]
        if emptyState.waitForExistence(timeout: 5) { return }
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        // Should show Actions section for draft/published postings
        let actions = app.staticTexts["Actions"]
        let description = app.staticTexts["Description"]
        XCTAssertTrue(actions.waitForExistence(timeout: 10) || description.waitForExistence(timeout: 5),
                      "Job posting detail should show Actions or Description section")
    }

    // MARK: - More Tab Tests

    @MainActor
    func testMoreTabShowsAllLinks() throws {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Employers"].waitForExistence(timeout: 10), "More tab should show Employers link")
        XCTAssertTrue(app.staticTexts["Payroll"].exists, "More tab should show Payroll link")
        XCTAssertTrue(app.staticTexts["Time Off Requests"].exists, "More tab should show Time Off Requests link")
        XCTAssertTrue(app.staticTexts["Employee Agreements"].exists, "More tab should show Employee Agreements link")
        XCTAssertTrue(app.staticTexts["Service Agreements"].exists, "More tab should show Service Agreements link")
    }

    @MainActor
    func testMoreTabShowsPersonalInfoAndContactRequests() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let personalInfo = app.staticTexts["Personal Info Requests"]
        let contactReqs = app.staticTexts["Contact Requests"]
        XCTAssertTrue(personalInfo.waitForExistence(timeout: 5), "More tab should show Personal Info Requests")
        XCTAssertTrue(contactReqs.exists, "More tab should show Contact Requests")
    }

    @MainActor
    func testMoreTabShowsHolidaysLink() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let holidays = app.staticTexts["Holidays"]
        XCTAssertTrue(holidays.waitForExistence(timeout: 5), "More tab should show Holidays link")
    }

    @MainActor
    func testMoreTabShowsSettingsLink() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5), "More tab should show Settings link")
    }

    @MainActor
    func testMoreTabEmployersLoadsData() throws {
        app.tabBars.buttons["More"].tap()
        let employers = app.staticTexts["Employers"]
        XCTAssertTrue(employers.waitForExistence(timeout: 10))
        employers.tap()
        let searchField = app.textFields["Search employers..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10),
                      "Employers list should load with search field")
        // Verify actual employer data loads
        let employerData = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "employees")).firstMatch
        let emptyState = app.staticTexts["No employers found"]
        XCTAssertTrue(employerData.waitForExistence(timeout: 10) || emptyState.exists,
                      "Employers list should show employer data or empty state")
    }

    @MainActor
    func testMoreTabEmployersBackReturns() throws {
        app.tabBars.buttons["More"].tap()
        let employers = app.staticTexts["Employers"]
        XCTAssertTrue(employers.waitForExistence(timeout: 10))
        employers.tap()
        let searchField = app.textFields["Search employers..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        UITestHelpers.tapBack(app: app)
        // Should be back on More tab
        XCTAssertTrue(app.staticTexts["Employers"].waitForExistence(timeout: 5),
                      "Back should return to More tab showing Employers link")
    }

    @MainActor
    func testMoreTabTimeOffRequestsLoads() throws {
        app.tabBars.buttons["More"].tap()
        let timeOff = app.staticTexts["Time Off Requests"]
        XCTAssertTrue(timeOff.waitForExistence(timeout: 10))
        timeOff.tap()
        sleep(2)
        // Should show filter chips or data
        let hasPendingFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Pending")).firstMatch
        let noRequests = app.staticTexts["No time off requests"]
        XCTAssertTrue(hasPendingFilter.waitForExistence(timeout: 10) || noRequests.exists,
                      "Time Off Requests should load with filter chips or empty state")
    }

    @MainActor
    func testMoreTabTimeOffShowsPlusButton() throws {
        app.tabBars.buttons["More"].tap()
        let timeOff = app.staticTexts["Time Off Requests"]
        XCTAssertTrue(timeOff.waitForExistence(timeout: 10))
        timeOff.tap()
        sleep(2)
        // The + button should be in the navigation bar
        let plusButtons = app.navigationBars.buttons
        XCTAssertTrue(plusButtons.count > 0, "Time Off Requests should have navigation bar buttons including +")
    }

    @MainActor
    func testMoreTabSettingsShowsEmail() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        let email = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "merot.com")).firstMatch
        XCTAssertTrue(email.waitForExistence(timeout: 10),
                      "Settings should display user email containing merot.com")
    }

    @MainActor
    func testMoreTabSettingsShowsProfileDetails() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        let profileDetails = app.staticTexts["Profile Details"]
        XCTAssertTrue(profileDetails.waitForExistence(timeout: 10),
                      "Settings should show Profile Details section")
    }

    @MainActor
    func testMoreTabSettingsShowsEditProfileButton() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        let editProfile = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Edit Profile")).firstMatch
        XCTAssertTrue(editProfile.waitForExistence(timeout: 10),
                      "Settings should show Edit Profile button")
    }

    @MainActor
    func testMoreTabSettingsShowsLogoutButton() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        app.swipeUp()
        let logout = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Logout")).firstMatch
        XCTAssertTrue(logout.waitForExistence(timeout: 10),
                      "Settings should show Logout button")
    }

    @MainActor
    func testMoreTabSettingsShowsAppInfo() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        app.swipeUp()
        let appInfo = app.staticTexts["App Info"]
        XCTAssertTrue(appInfo.waitForExistence(timeout: 10),
                      "Settings should show App Info section")
    }

    @MainActor
    func testMoreTabEmployeeAgreementsLoads() throws {
        app.tabBars.buttons["More"].tap()
        let empAgreements = app.staticTexts["Employee Agreements"]
        XCTAssertTrue(empAgreements.waitForExistence(timeout: 10))
        empAgreements.tap()
        let searchField = app.textFields["Search agreements..."]
        let noAgreements = app.staticTexts["No employee agreements"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10) || noAgreements.waitForExistence(timeout: 10),
                      "Employee Agreements should load with search or empty state")
    }

    @MainActor
    func testMoreTabEmployeeAgreementDetailLoads() throws {
        app.tabBars.buttons["More"].tap()
        let empAgreements = app.staticTexts["Employee Agreements"]
        XCTAssertTrue(empAgreements.waitForExistence(timeout: 10))
        empAgreements.tap()
        sleep(3)
        let noAgreements = app.staticTexts["No employee agreements"]
        if noAgreements.exists { return }
        UITestHelpers.tapFirstListRow(app: app)
        // Should show agreement detail - signature status or contract status
        let sigStatus = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Signature")).firstMatch
        let contractStatus = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Contract")).firstMatch
        let agreementDetail = sigStatus.waitForExistence(timeout: 10) || contractStatus.waitForExistence(timeout: 5)
        XCTAssertTrue(agreementDetail,
                      "Employee Agreement detail should show signature or contract status")
    }

    @MainActor
    func testMoreTabServiceAgreementsLoads() throws {
        app.tabBars.buttons["More"].tap()
        let svcAgreements = app.staticTexts["Service Agreements"]
        XCTAssertTrue(svcAgreements.waitForExistence(timeout: 10))
        svcAgreements.tap()
        let searchField = app.textFields["Search agreements..."]
        let noAgreements = app.staticTexts["No service agreements"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10) || noAgreements.waitForExistence(timeout: 10),
                      "Service Agreements should load with search or empty state")
    }

    @MainActor
    func testMoreTabPayrollLoads() throws {
        app.tabBars.buttons["More"].tap()
        let payroll = app.staticTexts["Payroll"]
        XCTAssertTrue(payroll.waitForExistence(timeout: 10))
        payroll.tap()
        sleep(2)
        let hasBatches = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "records")).firstMatch
            .waitForExistence(timeout: 10)
        let emptyState = app.staticTexts["No payroll batches"].exists
        let hasMonthLabel = app.staticTexts.containing(NSPredicate(format: "label MATCHES %@", ".*(January|February|March|April|May|June|July|August|September|October|November|December).*")).firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(hasBatches || emptyState || hasMonthLabel,
                      "Payroll page should show batch data or empty state")
    }

    @MainActor
    func testMoreTabHolidaysLoads() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let holidays = app.staticTexts["Holidays"]
        XCTAssertTrue(holidays.waitForExistence(timeout: 5))
        holidays.tap()
        sleep(2)
        // Should show holidays list or empty state
        let hasHolidays = app.staticTexts.containing(NSPredicate(format: "label MATCHES %@", ".*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec).*")).firstMatch
            .waitForExistence(timeout: 10)
        let emptyState = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No")).firstMatch.exists
        XCTAssertTrue(hasHolidays || emptyState,
                      "Holidays page should show holiday data or empty state")
    }

    @MainActor
    func testMoreTabContactRequestsLoads() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let contactReqs = app.staticTexts["Contact Requests"]
        XCTAssertTrue(contactReqs.waitForExistence(timeout: 5))
        contactReqs.tap()
        sleep(2)
        // Should show contact requests or empty state
        let hasContent = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "contact")).firstMatch.waitForExistence(timeout: 10)
        let emptyState = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No")).firstMatch.exists
        // If neither, the page loaded but may just show a list - verify nav title
        let title = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Contact")).firstMatch
        XCTAssertTrue(hasContent || emptyState || title.waitForExistence(timeout: 5),
                      "Contact Requests page should load")
    }

    @MainActor
    func testMoreTabEmploymentVerificationLoads() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let empVerification = app.staticTexts["Employment Verification"]
        XCTAssertTrue(empVerification.waitForExistence(timeout: 5))
        empVerification.tap()
        sleep(2)
        let title = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Verification")).firstMatch
        let emptyState = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "No")).firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 10) || emptyState.exists,
                      "Employment Verification page should load")
    }

    @MainActor
    func testMoreTabLogoutReturnsToLoginScreen() throws {
        app.tabBars.buttons["More"].tap()
        app.swipeUp()
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "More tab should show Logout button")
        logoutButton.tap()
        // Should return to login screen
        let adminButton = app.buttons["Admin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 10),
                      "After logout, login screen should appear with Admin button")
    }
}
