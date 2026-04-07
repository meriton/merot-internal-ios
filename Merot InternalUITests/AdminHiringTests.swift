import XCTest

final class AdminHiringTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToHiring() {
        let tab = app.tabBars.buttons["Hiring"]
        if tab.waitForExistence(timeout: 10) {
            tab.tap()
        }
    }

    // MARK: - Hiring Tab Structure

    @MainActor
    func testHiringTabShowsNavigationTitle() throws {
        navigateToHiring()
        let navTitle = app.navigationBars["Hiring"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Hiring nav title should exist")
    }

    @MainActor
    func testHiringTabShowsSegmentedControl() throws {
        navigateToHiring()
        // Segmented control has Postings and Applications
        let postings = app.buttons["Postings"]
        XCTAssertTrue(postings.waitForExistence(timeout: 5), "Postings segment should exist")
    }

    @MainActor
    func testHiringTabShowsApplicationsSegment() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5), "Applications segment should exist")
    }

    @MainActor
    func testHiringDefaultsToPostingsTab() throws {
        navigateToHiring()
        // Postings search bar should be visible by default
        let searchField = app.textFields["Search postings..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Postings search should be visible by default")
    }

    @MainActor
    func testHiringCanSwitchToApplications() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5))
        applications.tap()
        let searchField = app.textFields["Search applications..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Applications search should appear")
    }

    @MainActor
    func testHiringCanSwitchBackToPostings() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        let postings = app.buttons["Postings"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5))
        applications.tap()
        postings.tap()
        let searchField = app.textFields["Search postings..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Postings search should reappear")
    }

    // MARK: - Job Postings List

    @MainActor
    func testJobPostingsShowsSearchBar() throws {
        navigateToHiring()
        let searchField = app.textFields["Search postings..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search bar should exist")
    }

    @MainActor
    func testJobPostingsSearchAcceptsInput() throws {
        navigateToHiring()
        let searchField = app.textFields["Search postings..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Developer")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("Developer"), "Search should accept input")
    }

    @MainActor
    func testJobPostingsShowsFilterChips() throws {
        navigateToHiring()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testJobPostingsShowsEmptyStateOrContent() throws {
        navigateToHiring()
        let emptyState = app.staticTexts["No job postings"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show content or empty state")
    }

    // MARK: - Job Applications List

    @MainActor
    func testJobApplicationsShowsSearchBar() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5))
        applications.tap()
        let searchField = app.textFields["Search applications..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Applications search bar should exist")
    }

    @MainActor
    func testJobApplicationsSearchAcceptsInput() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5))
        applications.tap()
        let searchField = app.textFields["Search applications..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Jane")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("Jane"), "Search should accept input")
    }

    @MainActor
    func testJobApplicationsShowsFilterChips() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5))
        applications.tap()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist in applications")
    }

    @MainActor
    func testJobApplicationsShowsEmptyStateOrContent() throws {
        navigateToHiring()
        let applications = app.buttons["Applications"]
        XCTAssertTrue(applications.waitForExistence(timeout: 5))
        applications.tap()
        let emptyState = app.staticTexts["No applications"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show content or empty state")
    }
}
