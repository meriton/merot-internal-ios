import XCTest

final class AdminMoreTabTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToMore() {
        let tab = app.tabBars.buttons["More"]
        if tab.waitForExistence(timeout: 10) {
            tab.tap()
        }
    }

    // MARK: - More Tab Navigation Links

    @MainActor
    func testMoreTabShowsNavigationTitle() throws {
        navigateToMore()
        let navTitle = app.navigationBars["More"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "More nav title should exist")
    }

    @MainActor
    func testMoreTabShowsEmployersLink() throws {
        navigateToMore()
        let link = app.staticTexts["Employers"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Employers link should exist")
    }

    @MainActor
    func testMoreTabShowsPayrollLink() throws {
        navigateToMore()
        let link = app.staticTexts["Payroll"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Payroll link should exist")
    }

    @MainActor
    func testMoreTabShowsTimeOffRequestsLink() throws {
        navigateToMore()
        let link = app.staticTexts["Time Off Requests"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Time Off Requests link should exist")
    }

    @MainActor
    func testMoreTabShowsEmployeeAgreementsLink() throws {
        navigateToMore()
        let link = app.staticTexts["Employee Agreements"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Employee Agreements link should exist")
    }

    @MainActor
    func testMoreTabShowsServiceAgreementsLink() throws {
        navigateToMore()
        let link = app.staticTexts["Service Agreements"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Service Agreements link should exist")
    }

    @MainActor
    func testMoreTabShowsPersonalInfoRequestsLink() throws {
        navigateToMore()
        let link = app.staticTexts["Personal Info Requests"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Personal Info Requests link should exist")
    }

    @MainActor
    func testMoreTabShowsContactRequestsLink() throws {
        navigateToMore()
        let link = app.staticTexts["Contact Requests"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Contact Requests link should exist")
    }

    @MainActor
    func testMoreTabShowsHolidaysLink() throws {
        navigateToMore()
        let link = app.staticTexts["Holidays"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Holidays link should exist")
    }

    @MainActor
    func testMoreTabShowsSettingsLink() throws {
        navigateToMore()
        let link = app.staticTexts["Settings"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Settings link should exist")
    }

    @MainActor
    func testMoreTabShowsLogoutButton() throws {
        navigateToMore()
        let logout = app.buttons["Logout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 5), "Logout button should exist")
    }

    // MARK: - Navigation to Sub-screens

    @MainActor
    func testMoreTabCanNavigateToEmployers() throws {
        navigateToMore()
        let link = app.staticTexts["Employers"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Employers"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Employers")
    }

    @MainActor
    func testMoreTabCanNavigateToPayroll() throws {
        navigateToMore()
        let link = app.staticTexts["Payroll"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Payroll"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Payroll")
    }

    @MainActor
    func testMoreTabCanNavigateToTimeOffRequests() throws {
        navigateToMore()
        let link = app.staticTexts["Time Off Requests"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Time Off Requests"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Time Off Requests")
    }

    @MainActor
    func testMoreTabCanNavigateToEmployeeAgreements() throws {
        navigateToMore()
        let link = app.staticTexts["Employee Agreements"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Employee Agreements"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Employee Agreements")
    }

    @MainActor
    func testMoreTabCanNavigateToServiceAgreements() throws {
        navigateToMore()
        let link = app.staticTexts["Service Agreements"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Service Agreements"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Service Agreements")
    }

    @MainActor
    func testMoreTabCanNavigateToPersonalInfoRequests() throws {
        navigateToMore()
        let link = app.staticTexts["Personal Info Requests"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Personal Info Requests"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Personal Info Requests")
    }

    @MainActor
    func testMoreTabCanNavigateToContactRequests() throws {
        navigateToMore()
        let link = app.staticTexts["Contact Requests"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Contact Requests"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Contact Requests")
    }

    @MainActor
    func testMoreTabCanNavigateToHolidays() throws {
        navigateToMore()
        let link = app.staticTexts["Holidays"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Holidays"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Holidays")
    }

    @MainActor
    func testMoreTabCanNavigateToSettings() throws {
        navigateToMore()
        let link = app.staticTexts["Settings"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Settings"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Settings")
    }

    @MainActor
    func testMoreTabCanNavigateAndGoBack() throws {
        navigateToMore()
        let link = app.staticTexts["Employers"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        let navTitle = app.navigationBars["Employers"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
        // Go back
        let backButton = app.navigationBars.buttons["More"]
        if backButton.exists {
            backButton.tap()
            let moreTitle = app.navigationBars["More"]
            XCTAssertTrue(moreTitle.waitForExistence(timeout: 5), "Should return to More screen")
        }
    }
}
