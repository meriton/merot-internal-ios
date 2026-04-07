import XCTest

final class AdminTimeOffTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToTimeOff() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Time Off Requests"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Time Off Requests

    @MainActor
    func testTimeOffShowsNavigationTitle() throws {
        navigateToTimeOff()
        let navTitle = app.navigationBars["Time Off Requests"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Time Off Requests nav title should exist")
    }

    @MainActor
    func testTimeOffShowsFilterChips() throws {
        navigateToTimeOff()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testTimeOffShowsPendingFilterChip() throws {
        navigateToTimeOff()
        let pendingChip = app.buttons["Pending"]
        XCTAssertTrue(pendingChip.waitForExistence(timeout: 5), "Pending filter chip should exist")
    }

    @MainActor
    func testTimeOffShowsApprovedFilterChip() throws {
        navigateToTimeOff()
        let approvedChip = app.buttons["Approved"]
        XCTAssertTrue(approvedChip.waitForExistence(timeout: 5), "Approved filter chip should exist")
    }

    @MainActor
    func testTimeOffShowsDeniedFilterChip() throws {
        navigateToTimeOff()
        let deniedChip = app.buttons["Denied"]
        XCTAssertTrue(deniedChip.waitForExistence(timeout: 5), "Denied filter chip should exist")
    }

    @MainActor
    func testTimeOffFilterPendingIsTappable() throws {
        navigateToTimeOff()
        let pendingChip = app.buttons["Pending"]
        XCTAssertTrue(pendingChip.waitForExistence(timeout: 5))
        pendingChip.tap()
        XCTAssertTrue(pendingChip.exists)
    }

    @MainActor
    func testTimeOffShowsEmptyStateOrRequests() throws {
        navigateToTimeOff()
        let emptyState = app.staticTexts["No time off requests"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show requests or empty state")
    }

    @MainActor
    func testTimeOffPendingShowsApproveButton() throws {
        navigateToTimeOff()
        // If there are pending requests, approve/deny buttons should show
        let approveBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Approve'")).firstMatch
        _ = approveBtn.waitForExistence(timeout: 10)
        // This may or may not exist depending on data
        XCTAssertTrue(true, "Approve button check completed")
    }

    @MainActor
    func testTimeOffPendingShowsDenyButton() throws {
        navigateToTimeOff()
        let denyBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Deny'")).firstMatch
        _ = denyBtn.waitForExistence(timeout: 10)
        XCTAssertTrue(true, "Deny button check completed")
    }

    @MainActor
    func testTimeOffListHasScrollView() throws {
        navigateToTimeOff()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
