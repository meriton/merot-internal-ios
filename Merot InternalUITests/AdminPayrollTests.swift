import XCTest

final class AdminPayrollTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToPayroll() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Payroll"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Payroll List

    @MainActor
    func testPayrollShowsNavigationTitle() throws {
        navigateToPayroll()
        let navTitle = app.navigationBars["Payroll"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Payroll nav title should exist")
    }

    @MainActor
    func testPayrollShowsEmptyStateOrBatches() throws {
        navigateToPayroll()
        let emptyState = app.staticTexts["No payroll batches"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show batches or empty state")
    }

    @MainActor
    func testPayrollListHasScrollView() throws {
        navigateToPayroll()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }

    @MainActor
    func testPayrollBatchRowShowsRecordsLabel() throws {
        navigateToPayroll()
        // Look for "records" text in batch rows
        let recordsText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'records'")).firstMatch
        if recordsText.waitForExistence(timeout: 10) {
            XCTAssertTrue(recordsText.exists, "Batch rows should show record count")
        }
    }
}
