import SwiftUI

struct HolidayActionResponse: Codable {
    let data: HolidayActionData?
    let success: Bool?
    let message: String?
}

struct HolidayActionData: Codable {
    let holiday: Holiday?
}

@MainActor
class HolidaysViewModel: ObservableObject {
    @Published var holidays: [Holiday] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?
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

    func create(body: [String: Any]) async -> Bool {
        isActioning = true
        error = nil
        do {
            let res: HolidayActionResponse = try await api.request("POST", "/admin/holidays", body: body)
            successMessage = res.message ?? "Holiday created"
            await load()
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to create holiday"
        }
        isActioning = false
        return false
    }

    func update(id: Int, body: [String: Any]) async -> Bool {
        isActioning = true
        error = nil
        do {
            let res: HolidayActionResponse = try await api.request("PUT", "/admin/holidays/\(id)", body: body)
            successMessage = res.message ?? "Holiday updated"
            await load()
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update holiday"
        }
        isActioning = false
        return false
    }

    func delete(id: Int) async {
        isActioning = true
        error = nil
        do {
            let _: HolidayActionResponse = try await api.request("DELETE", "/admin/holidays/\(id)")
            successMessage = "Holiday deleted"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to delete holiday"
        }
        isActioning = false
    }
}
