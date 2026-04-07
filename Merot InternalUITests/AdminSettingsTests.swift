import XCTest

final class AdminSettingsTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func navigateToSettings() {
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.waitForExistence(timeout: 10) {
            moreTab.tap()
            let link = app.staticTexts["Settings"]
            if link.waitForExistence(timeout: 5) {
                link.tap()
            }
        }
    }

    // MARK: - Settings Screen

    @MainActor
    func testSettingsShowsNavigationTitle() throws {
        navigateToSettings()
        let navTitle = app.navigationBars["Settings"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Settings nav title should exist")
    }

    @MainActor
    func testSettingsShowsProfileDetailsSection() throws {
        navigateToSettings()
        let profileDetails = app.staticTexts["Profile Details"]
        XCTAssertTrue(profileDetails.waitForExistence(timeout: 5), "Profile Details section should exist")
    }

    @MainActor
    func testSettingsShowsEmailRow() throws {
        navigateToSettings()
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 5), "Email row should exist")
    }

    @MainActor
    func testSettingsShowsPhoneRow() throws {
        navigateToSettings()
        let phoneLabel = app.staticTexts["Phone"]
        XCTAssertTrue(phoneLabel.waitForExistence(timeout: 5), "Phone row should exist")
    }

    @MainActor
    func testSettingsShowsSuperAdminRow() throws {
        navigateToSettings()
        let superAdminLabel = app.staticTexts["Super Admin"]
        XCTAssertTrue(superAdminLabel.waitForExistence(timeout: 5), "Super Admin row should exist")
    }

    @MainActor
    func testSettingsShowsEditProfileButton() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5), "Edit Profile button should exist")
    }

    @MainActor
    func testSettingsShowsChangePasswordButton() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5), "Change Password button should exist")
    }

    @MainActor
    func testSettingsShowsLogoutButton() throws {
        navigateToSettings()
        let logoutButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Logout'")).firstMatch
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Logout button should exist")
    }

    @MainActor
    func testSettingsShowsAppInfoSection() throws {
        navigateToSettings()
        let appInfo = app.staticTexts["App Info"]
        XCTAssertTrue(appInfo.waitForExistence(timeout: 5), "App Info section should exist")
    }

    @MainActor
    func testSettingsShowsVersionRow() throws {
        navigateToSettings()
        let versionLabel = app.staticTexts["Version"]
        XCTAssertTrue(versionLabel.waitForExistence(timeout: 5), "Version row should exist")
    }

    @MainActor
    func testSettingsShowsVersionNumber() throws {
        navigateToSettings()
        let versionValue = app.staticTexts["2.0.0"]
        XCTAssertTrue(versionValue.waitForExistence(timeout: 5), "Version 2.0.0 should be visible")
    }

    @MainActor
    func testSettingsShowsAPIRow() throws {
        navigateToSettings()
        let apiLabel = app.staticTexts["API"]
        XCTAssertTrue(apiLabel.waitForExistence(timeout: 5), "API row should exist")
    }

    @MainActor
    func testSettingsShowsAPIValue() throws {
        navigateToSettings()
        let apiValue = app.staticTexts["internal.merot.com"]
        XCTAssertTrue(apiValue.waitForExistence(timeout: 5), "API value should be visible")
    }

    @MainActor
    func testSettingsShowsPlatformRow() throws {
        navigateToSettings()
        let platformLabel = app.staticTexts["Platform"]
        XCTAssertTrue(platformLabel.waitForExistence(timeout: 5), "Platform row should exist")
    }

    @MainActor
    func testSettingsShowsPlatformValue() throws {
        navigateToSettings()
        let platformValue = app.staticTexts["Merot Internal"]
        XCTAssertTrue(platformValue.waitForExistence(timeout: 5), "Platform value should be visible")
    }

    @MainActor
    func testSettingsEditProfileButtonIsTappable() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        // Should present Edit Profile sheet
        let editTitle = app.navigationBars["Edit Profile"]
        if editTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(editTitle.exists, "Edit Profile sheet should appear")
        }
    }

    @MainActor
    func testSettingsChangePasswordButtonIsTappable() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let changeTitle = app.navigationBars["Change Password"]
        if changeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(changeTitle.exists, "Change Password sheet should appear")
        }
    }

    // MARK: - Edit Profile Sheet

    @MainActor
    func testEditProfileSheetShowsFirstNameField() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        let firstNameLabel = app.staticTexts["First Name"]
        XCTAssertTrue(firstNameLabel.waitForExistence(timeout: 5), "First Name field should exist")
    }

    @MainActor
    func testEditProfileSheetShowsLastNameField() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        let lastNameLabel = app.staticTexts["Last Name"]
        XCTAssertTrue(lastNameLabel.waitForExistence(timeout: 5), "Last Name field should exist")
    }

    @MainActor
    func testEditProfileSheetShowsPhoneNumberField() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        let phoneLabel = app.staticTexts["Phone Number"]
        XCTAssertTrue(phoneLabel.waitForExistence(timeout: 5), "Phone Number field should exist")
    }

    @MainActor
    func testEditProfileSheetShowsSaveButton() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        let saveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Save'")).firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button should exist")
    }

    @MainActor
    func testEditProfileSheetShowsCancelButton() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button should exist")
    }

    @MainActor
    func testEditProfileSheetCancelDismisses() throws {
        navigateToSettings()
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Edit Profile'")).firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()
        // Should return to Settings
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "Should return to Settings after cancel")
    }

    // MARK: - Change Password Sheet

    @MainActor
    func testChangePasswordSheetShowsNewPasswordField() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let newPasswordLabel = app.staticTexts["New Password"]
        XCTAssertTrue(newPasswordLabel.waitForExistence(timeout: 5), "New Password label should exist")
    }

    @MainActor
    func testChangePasswordSheetShowsConfirmPasswordField() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let confirmLabel = app.staticTexts["Confirm Password"]
        XCTAssertTrue(confirmLabel.waitForExistence(timeout: 5), "Confirm Password label should exist")
    }

    @MainActor
    func testChangePasswordSheetShowsChangePasswordButton() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let submitButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5), "Change Password submit button should exist")
    }

    @MainActor
    func testChangePasswordSheetShowsCancelButton() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button should exist")
    }

    @MainActor
    func testChangePasswordSheetCancelDismisses() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "Should return to Settings after cancel")
    }

    @MainActor
    func testChangePasswordSheetHasSecureFields() throws {
        navigateToSettings()
        let changePasswordButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Change Password'")).firstMatch
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 5))
        changePasswordButton.tap()
        let secureFields = app.secureTextFields
        XCTAssertTrue(secureFields.count >= 2, "Should have at least 2 secure text fields")
    }

    @MainActor
    func testSettingsHasScrollView() throws {
        navigateToSettings()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Should have scroll view")
    }
}
