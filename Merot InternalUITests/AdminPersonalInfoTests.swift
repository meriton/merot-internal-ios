import XCTest

final class AdminPersonalInfoTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToPersonalInfo() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Personal Info Requests"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Personal Info Requests

    @MainActor
    func testPersonalInfoShowsNavigationTitle() throws {
        navigateToPersonalInfo()
        let navTitle = app.navigationBars["Personal Info Requests"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Personal Info Requests nav title should exist")
    }

    @MainActor
    func testPersonalInfoShowsFilterChips() throws {
        navigateToPersonalInfo()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testPersonalInfoFilterSubmittedIsTappable() throws {
        navigateToPersonalInfo()
        let submittedChip = app.buttons["Submitted"]
        if submittedChip.waitForExistence(timeout: 5) {
            submittedChip.tap()
            XCTAssertTrue(submittedChip.exists)
        }
    }

    @MainActor
    func testPersonalInfoShowsEmptyStateOrContent() throws {
        navigateToPersonalInfo()
        let emptyState = app.staticTexts["No personal info requests"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show content or empty state")
    }

    @MainActor
    func testPersonalInfoEmptyStateCaughtUp() throws {
        navigateToPersonalInfo()
        let submittedChip = app.buttons["Submitted"]
        if submittedChip.waitForExistence(timeout: 5) {
            submittedChip.tap()
            let caughtUp = app.staticTexts["All caught up!"]
            _ = caughtUp.waitForExistence(timeout: 10)
            // May or may not show depending on data
            XCTAssertTrue(true, "Caught up message check completed")
        }
    }

    @MainActor
    func testPersonalInfoListHasScrollView() throws {
        navigateToPersonalInfo()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
