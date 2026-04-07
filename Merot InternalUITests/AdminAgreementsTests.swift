import XCTest

final class AdminAgreementsTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToEmployeeAgreements() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Employee Agreements"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    private func navigateToServiceAgreements() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Service Agreements"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Employee Agreements

    @MainActor
    func testEmployeeAgreementsShowsNavigationTitle() throws {
        navigateToEmployeeAgreements()
        let navTitle = app.navigationBars["Employee Agreements"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Employee Agreements nav title should exist")
    }

    @MainActor
    func testEmployeeAgreementsShowsSearchBar() throws {
        navigateToEmployeeAgreements()
        let searchField = app.textFields["Search agreements..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search bar should exist")
    }

    @MainActor
    func testEmployeeAgreementsShowsAllFilterChip() throws {
        navigateToEmployeeAgreements()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testEmployeeAgreementsSearchAcceptsInput() throws {
        navigateToEmployeeAgreements()
        let searchField = app.textFields["Search agreements..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Contract")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("Contract"), "Search should accept input")
    }

    @MainActor
    func testEmployeeAgreementsFilterIsTappable() throws {
        navigateToEmployeeAgreements()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5))
        allChip.tap()
        XCTAssertTrue(allChip.exists)
    }

    @MainActor
    func testEmployeeAgreementsShowsEmptyStateOrContent() throws {
        navigateToEmployeeAgreements()
        let emptyState = app.staticTexts["No employee agreements"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show content or empty state")
    }

    @MainActor
    func testEmployeeAgreementsHasScrollView() throws {
        navigateToEmployeeAgreements()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }

    // MARK: - Service Agreements

    @MainActor
    func testServiceAgreementsShowsNavigationTitle() throws {
        navigateToServiceAgreements()
        let navTitle = app.navigationBars["Service Agreements"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Service Agreements nav title should exist")
    }

    @MainActor
    func testServiceAgreementsShowsSearchBar() throws {
        navigateToServiceAgreements()
        let searchField = app.textFields["Search agreements..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search bar should exist")
    }

    @MainActor
    func testServiceAgreementsShowsAllFilterChip() throws {
        navigateToServiceAgreements()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testServiceAgreementsSearchAcceptsInput() throws {
        navigateToServiceAgreements()
        let searchField = app.textFields["Search agreements..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Service")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("Service"), "Search should accept input")
    }

    @MainActor
    func testServiceAgreementsShowsEmptyStateOrContent() throws {
        navigateToServiceAgreements()
        let emptyState = app.staticTexts["No service agreements"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show content or empty state")
    }

    @MainActor
    func testServiceAgreementsHasScrollView() throws {
        navigateToServiceAgreements()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
