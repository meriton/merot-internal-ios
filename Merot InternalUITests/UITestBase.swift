import XCTest

/// Base class for all E2E UI tests.
/// Seeds the test database once before the suite runs,
/// and purges it after all tests complete.
///
/// The Rails server must be running in test mode on port 3001:
///   RAILS_ENV=test rails s -p 3001
class UITestBase: XCTestCase {

    // Test credentials (created by seed)
    static let adminEmail = "admin@test.merot.com"
    static let adminPassword = "password123"
    static let employerEmail = "employer@test.merot.com"
    static let employerPassword = "password123"
    static let employeeEmail = "employee@test.merot.com"
    static let employeePassword = "password123"

    static let testServerURL = "http://localhost:3001/api/v2"

    // Seed runs once per test suite
    private static var isSeeded = false

    override func setUpWithError() throws {
        continueAfterFailure = true

        if !UITestBase.isSeeded {
            seedTestData()
            UITestBase.isSeeded = true
        }
    }

    /// Calls the test server to seed predictable test data.
    private func seedTestData() {
        let url = URL(string: "\(UITestBase.testServerURL)/test/seed")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let semaphore = DispatchSemaphore(value: 0)
        var seedError: String?

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error {
                seedError = "Seed request failed: \(error.localizedDescription)"
                return
            }
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            if code != 200 {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                seedError = "Seed returned \(code): \(body.prefix(200))"
            }
        }
        task.resume()
        let result = semaphore.wait(timeout: .now() + 30)

        if result == .timedOut {
            print("⚠️ Test seed timed out — tests may fail if data is missing")
        } else if let err = seedError {
            print("⚠️ Test seed failed: \(err) — tests may fail if data is missing")
        } else {
            print("✅ Test database seeded successfully")
        }
    }

    /// Creates and launches the app in UI testing mode.
    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        return app
    }
}
