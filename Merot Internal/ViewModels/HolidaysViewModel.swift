import SwiftUI

@MainActor
class HolidaysViewModel: ObservableObject {
    @Published var holidays: [Holiday] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var countryFilter = "all"

    let countryOptions = ["all", "MK", "XK"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["year": "\(selectedYear)", "per_page": "100"]
            if countryFilter != "all" { query["applicable_country"] = countryFilter }
            let res: HolidaysListResponse = try await api.request("GET", "/admin/holidays", query: query)
            holidays = res.data?.holidays ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load holidays"
        }
        isLoading = false
    }
}
