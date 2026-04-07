import XCTest

final class AdminHolidaysTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToHolidays() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Holidays"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Holidays

    @MainActor
    func testHolidaysShowsNavigationTitle() throws {
        navigateToHolidays()
        let navTitle = app.navigationBars["Holidays"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Holidays nav title should exist")
    }

    @MainActor
    func testHolidaysShowsYearPicker() throws {
        navigateToHolidays()
        // Year picker is a Picker with menu style
        let yearPicker = app.buttons.matching(NSPredicate(format: "label CONTAINS '202'")).firstMatch
        XCTAssertTrue(yearPicker.waitForExistence(timeout: 5), "Year picker should exist")
    }

    @MainActor
    func testHolidaysShowsCountryPicker() throws {
        navigateToHolidays()
        let countryPicker = app.buttons.matching(NSPredicate(format: "label CONTAINS 'All Countries' OR label CONTAINS 'MK' OR label CONTAINS 'XK'")).firstMatch
        XCTAssertTrue(countryPicker.waitForExistence(timeout: 5), "Country picker should exist")
    }

    @MainActor
    func testHolidaysShowsEmptyStateOrList() throws {
        navigateToHolidays()
        let emptyState = app.staticTexts["No holidays found"]
        _ = emptyState.waitForExistence(timeout: 10)
        XCTAssertTrue(emptyState.exists || app.scrollViews.firstMatch.exists, "Should show holidays or empty state")
    }

    @MainActor
    func testHolidaysListHasScrollView() throws {
        navigateToHolidays()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
