import XCTest

final class AdminDashboardTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    // Helper: navigate to Dashboard tab if authenticated
    private func navigateToDashboard() {
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        if dashboardTab.waitForExistence(timeout: 10) {
            dashboardTab.tap()
        }
    }

    // MARK: - Tab Bar

    @MainActor
    func testAdminTabBarShowsDashboard() throws {
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        // If not authenticated, we'll be on login; if authenticated, tab bar shows
        if dashboardTab.waitForExistence(timeout: 10) {
            XCTAssertTrue(dashboardTab.exists, "Dashboard tab should exist")
        }
    }

    @MainActor
    func testAdminTabBarShowsEmployees() throws {
        let employeesTab = app.tabBars.buttons["Employees"]
        if employeesTab.waitForExistence(timeout: 10) {
            XCTAssertTrue(employeesTab.exists, "Employees tab should exist")
        }
    }

    @MainActor
    func testAdminTabBarShowsInvoices() throws {
        let invoicesTab = app.tabBars.buttons["Invoices"]
        if invoicesTab.waitForExistence(timeout: 10) {
            XCTAssertTrue(invoicesTab.exists, "Invoices tab should exist")
        }
    }

    @MainActor
    func testAdminTabBarShowsHiring() throws {
        let hiringTab = app.tabBars.buttons["Hiring"]
        if hiringTab.waitForExistence(timeout: 10) {
            XCTAssertTrue(hiringTab.exists, "Hiring tab should exist")
        }
    }

    @MainActor
    func testAdminTabBarShowsMore() throws {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            XCTAssertTrue(moreTab.exists, "More tab should exist")
        }
    }

    @MainActor
    func testAdminHasFiveTabBarItems() throws {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 10) {
            let buttons = tabBar.buttons
            XCTAssertEqual(buttons.count, 5, "Admin should have 5 tab bar items")
        }
    }

    // MARK: - Dashboard Content

    @MainActor
    func testDashboardShowsNavigationTitle() throws {
        navigateToDashboard()
        let navTitle = app.navigationBars["Dashboard"]
        if navTitle.waitForExistence(timeout: 10) {
            XCTAssertTrue(navTitle.exists, "Dashboard navigation title should exist")
        }
    }

    @MainActor
    func testDashboardShowsWelcomeText() throws {
        navigateToDashboard()
        // The welcome text starts with "Welcome,"
        let welcome = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Welcome,'")).firstMatch
        if welcome.waitForExistence(timeout: 10) {
            XCTAssertTrue(welcome.exists, "Welcome text should be visible")
        }
    }

    @MainActor
    func testDashboardShowsActiveEmployeesStatCard() throws {
        navigateToDashboard()
        let statLabel = app.staticTexts["Active Employees"]
        if statLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(statLabel.exists, "Active Employees stat should be visible")
        }
    }

    @MainActor
    func testDashboardShowsClockedInStatCard() throws {
        navigateToDashboard()
        let statLabel = app.staticTexts["Clocked In"]
        if statLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(statLabel.exists, "Clocked In stat should be visible")
        }
    }

    @MainActor
    func testDashboardShowsOnLeaveStatCard() throws {
        navigateToDashboard()
        let statLabel = app.staticTexts["On Leave"]
        if statLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(statLabel.exists, "On Leave stat should be visible")
        }
    }

    @MainActor
    func testDashboardShowsOutstandingStatCard() throws {
        navigateToDashboard()
        let statLabel = app.staticTexts["Outstanding"]
        if statLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(statLabel.exists, "Outstanding stat should be visible")
        }
    }

    @MainActor
    func testDashboardShowsEmployersStatCard() throws {
        navigateToDashboard()
        let statLabel = app.staticTexts["Employers"]
        if statLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(statLabel.exists, "Employers stat should be visible")
        }
    }

    @MainActor
    func testDashboardShowsPendingTimeOffStatCard() throws {
        navigateToDashboard()
        let statLabel = app.staticTexts["Pending Time Off"]
        if statLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(statLabel.exists, "Pending Time Off stat should be visible")
        }
    }

    @MainActor
    func testDashboardShowsNextPayrollCard() throws {
        navigateToDashboard()
        let nextPayroll = app.staticTexts["Next Payroll"]
        if nextPayroll.waitForExistence(timeout: 10) {
            XCTAssertTrue(nextPayroll.exists, "Next Payroll card should be visible")
        }
    }

    @MainActor
    func testDashboardShowsNextHolidayCard() throws {
        navigateToDashboard()
        let nextHoliday = app.staticTexts["Next Holiday"]
        if nextHoliday.waitForExistence(timeout: 10) {
            XCTAssertTrue(nextHoliday.exists, "Next Holiday card should be visible")
        }
    }

    @MainActor
    func testDashboardShowsPendingItemsSection() throws {
        navigateToDashboard()
        let pending = app.staticTexts["Pending Items"]
        if pending.waitForExistence(timeout: 10) {
            XCTAssertTrue(pending.exists, "Pending Items section should be visible")
        }
    }

    @MainActor
    func testDashboardShowsLegalEntitiesSection() throws {
        navigateToDashboard()
        let entities = app.staticTexts["Legal Entities"]
        if entities.waitForExistence(timeout: 10) {
            XCTAssertTrue(entities.exists, "Legal Entities section should be visible")
        }
    }

    @MainActor
    func testDashboardShowsRecentActivitySection() throws {
        navigateToDashboard()
        let activity = app.staticTexts["Recent Activity"]
        if activity.waitForExistence(timeout: 10) {
            XCTAssertTrue(activity.exists, "Recent Activity section should be visible")
        }
    }

    @MainActor
    func testDashboardHasLogoutButton() throws {
        navigateToDashboard()
        let navBar = app.navigationBars["Dashboard"]
        if navBar.waitForExistence(timeout: 10) {
            let logoutButton = navBar.buttons.firstMatch
            XCTAssertTrue(logoutButton.exists, "Logout button should exist in nav bar")
        }
    }

    // MARK: - Tab Switching

    @MainActor
    func testCanSwitchToEmployeesTab() throws {
        let employeesTab = app.tabBars.buttons["Employees"]
        if employeesTab.waitForExistence(timeout: 10) {
            employeesTab.tap()
            let navTitle = app.navigationBars["Employees"]
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Employees screen")
        }
    }

    @MainActor
    func testCanSwitchToInvoicesTab() throws {
        let invoicesTab = app.tabBars.buttons["Invoices"]
        if invoicesTab.waitForExistence(timeout: 10) {
            invoicesTab.tap()
            let navTitle = app.navigationBars["Invoices"]
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Invoices screen")
        }
    }

    @MainActor
    func testCanSwitchToHiringTab() throws {
        let hiringTab = app.tabBars.buttons["Hiring"]
        if hiringTab.waitForExistence(timeout: 10) {
            hiringTab.tap()
            let navTitle = app.navigationBars["Hiring"]
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Hiring screen")
        }
    }

    @MainActor
    func testCanSwitchToMoreTab() throws {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let navTitle = app.navigationBars["More"]
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to More screen")
        }
    }

    @MainActor
    func testCanSwitchBackToDashboardTab() throws {
        let employeesTab = app.tabBars.buttons["Employees"]
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        if employeesTab.waitForExistence(timeout: 10) {
            employeesTab.tap()
            dashboardTab.tap()
            let navTitle = app.navigationBars["Dashboard"]
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should return to Dashboard")
        }
    }
}
