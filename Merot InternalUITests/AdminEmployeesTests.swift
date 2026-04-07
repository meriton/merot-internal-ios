import XCTest

final class AdminEmployeesTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToEmployees() {
        let tab = app.tabBars.buttons["Employees"]
        if tab.waitForExistence(timeout: 10) {
            tab.tap()
        }
    }

    // MARK: - Employees List

    @MainActor
    func testEmployeesTabShowsNavigationTitle() throws {
        navigateToEmployees()
        let navTitle = app.navigationBars["Employees"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Employees nav title should exist")
    }

    @MainActor
    func testEmployeesListShowsSearchBar() throws {
        navigateToEmployees()
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search bar should exist")
    }

    @MainActor
    func testEmployeesListShowsAllFilterChip() throws {
        navigateToEmployees()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5), "All filter chip should exist")
    }

    @MainActor
    func testEmployeesListShowsActiveFilterChip() throws {
        navigateToEmployees()
        let activeChip = app.buttons["Active"]
        XCTAssertTrue(activeChip.waitForExistence(timeout: 5), "Active filter chip should exist")
    }

    @MainActor
    func testEmployeesListShowsTerminatedFilterChip() throws {
        navigateToEmployees()
        let terminatedChip = app.buttons["Terminated"]
        XCTAssertTrue(terminatedChip.waitForExistence(timeout: 5), "Terminated filter chip should exist")
    }

    @MainActor
    func testEmployeesFilterChipAllIsTappable() throws {
        navigateToEmployees()
        let allChip = app.buttons["All"]
        XCTAssertTrue(allChip.waitForExistence(timeout: 5))
        allChip.tap()
        XCTAssertTrue(allChip.exists, "All chip should remain after tap")
    }

    @MainActor
    func testEmployeesFilterChipActiveIsTappable() throws {
        navigateToEmployees()
        let activeChip = app.buttons["Active"]
        XCTAssertTrue(activeChip.waitForExistence(timeout: 5))
        activeChip.tap()
        XCTAssertTrue(activeChip.exists, "Active chip should remain after tap")
    }

    @MainActor
    func testEmployeesFilterChipTerminatedIsTappable() throws {
        navigateToEmployees()
        let terminatedChip = app.buttons["Terminated"]
        XCTAssertTrue(terminatedChip.waitForExistence(timeout: 5))
        terminatedChip.tap()
        XCTAssertTrue(terminatedChip.exists, "Terminated chip should remain after tap")
    }

    @MainActor
    func testEmployeesSearchBarIsTappable() throws {
        navigateToEmployees()
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        XCTAssertTrue(searchField.exists, "Search field should remain after tap")
    }

    @MainActor
    func testEmployeesSearchBarAcceptsInput() throws {
        navigateToEmployees()
        let searchField = app.textFields["Search employees..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("John")
        let value = searchField.value as? String ?? ""
        XCTAssertTrue(value.contains("John"), "Search field should contain typed text")
    }

    @MainActor
    func testEmployeesListShowsEmptyStateOrRows() throws {
        navigateToEmployees()
        // Either empty state or employee rows should appear
        let emptyState = app.staticTexts["No employees found"]
        let loadingText = app.staticTexts["Loading..."]
        // Wait for content to load
        _ = emptyState.waitForExistence(timeout: 10)
        let hasContent = emptyState.exists || loadingText.exists || app.scrollViews.firstMatch.exists
        XCTAssertTrue(hasContent, "Should show empty state, loading, or content")
    }

    // MARK: - Employee Detail (structure check)

    @MainActor
    func testEmployeesListHasScrollView() throws {
        navigateToEmployees()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Employees should have a scroll view")
    }
}
