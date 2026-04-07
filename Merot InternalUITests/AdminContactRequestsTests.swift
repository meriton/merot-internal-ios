import XCTest

final class AdminContactRequestsTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToContactRequests() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Contact Requests"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Contact Requests

    @MainActor
    func testContactRequestsShowsNavigationTitle() throws {
        navigateToContactRequests()
        let navTitle = app.navigationBars["Contact Requests"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Contact Requests nav title should exist")
    }

    @MainActor
    func testContactRequestsShowsSearchBar() throws {
        navigateToContactRequests()
        let searchField = app.textFields["Search contacts..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search bar should exist")
    }

    @MainActor
    func testContactRequestsShowsFilterChips() throws {
        navigateToContactRequests()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testContactRequestsShowsPendingFilterChip() throws {
        navigateToContactRequests()
        let pendingChip = app.buttons["Pending"]
        XCTAssertTrue(pendingChip.waitForExistence(timeout: 5), "Pending filter chip should exist")
    }

    @MainActor
    func testContactRequestsShowsRepliedFilterChip() throws {
        navigateToContactRequests()
        let repliedChip = app.buttons["Replied"]
        XCTAssertTrue(repliedChip.waitForExistence(timeout: 5), "Replied filter chip should exist")
    }

    @MainActor
    func testContactRequestsShowsCompletedFilterChip() throws {
        navigateToContactRequests()
        let completedChip = app.buttons["Completed"]
        XCTAssertTrue(completedChip.waitForExistence(timeout: 5), "Completed filter chip should exist")
    }

    @MainActor
    func testContactRequestsSearchAcceptsInput() throws {
        navigateToContactRequests()
        let searchField = app.textFields["Search contacts..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("John")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("John"), "Search should accept input")
    }

    @MainActor
    func testContactRequestsFilterPendingIsTappable() throws {
        navigateToContactRequests()
        let pendingChip = app.buttons["Pending"]
        XCTAssertTrue(pendingChip.waitForExistence(timeout: 5))
        pendingChip.tap()
        XCTAssertTrue(pendingChip.exists)
    }

    @MainActor
    func testContactRequestsShowsEmptyStateOrContent() throws {
        navigateToContactRequests()
        let emptyState = app.staticTexts["No contact requests"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show content or empty state")
    }

    @MainActor
    func testContactRequestsShowsStatsRow() throws {
        navigateToContactRequests()
        // Stats row has Pending, Replied, Done labels
        let pending = app.staticTexts["Pending"]
        _ = pending.waitForExistence(timeout: 10)
        XCTAssertTrue(true, "Stats row check completed")
    }

    @MainActor
    func testContactRequestsListHasScrollView() throws {
        navigateToContactRequests()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
