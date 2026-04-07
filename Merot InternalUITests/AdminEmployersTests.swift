import XCTest

final class AdminEmployersTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToEmployers() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Employers"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Employers List

    @MainActor
    func testEmployersShowsNavigationTitle() throws {
        navigateToEmployers()
        let navTitle = app.navigationBars["Employers"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Employers nav title should exist")
    }

    @MainActor
    func testEmployersShowsSearchBar() throws {
        navigateToEmployers()
        let searchField = app.textFields["Search employers..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search bar should exist")
    }

    @MainActor
    func testEmployersSearchBarAcceptsInput() throws {
        navigateToEmployers()
        let searchField = app.textFields["Search employers..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Acme")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("Acme"), "Search should accept input")
    }

    @MainActor
    func testEmployersShowsEmptyStateOrContent() throws {
        navigateToEmployers()
        let emptyState = app.staticTexts["No employers found"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show empty state or content")
    }

    @MainActor
    func testEmployersListHasScrollView() throws {
        navigateToEmployers()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
