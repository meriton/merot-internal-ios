import SwiftUI

@MainActor
class JobApplicationsViewModel: ObservableObject {
    @Published var applications: [JobApplication] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter = "all"

    let statusOptions = ["all", "new", "screening", "interviewing", "approved", "hired", "rejected"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: JobApplicationsListResponse = try await api.request("GET", "/admin/job_applications", query: query)
            applications = res.data?.job_applications ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load applications"
        }
        isLoading = false
    }
}

@MainActor
class JobApplicationDetailViewModel: ObservableObject {
    @Published var application: JobApplication?
    @Published var events: [JobApplicationEvent] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: JobApplicationDetailResponse = try await api.request("GET", "/admin/job_applications/\(id)")
            application = res.data?.job_application
            events = res.data?.events ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load application"
        }
        isLoading = false
    }

    func updateStatus(id: Int, status: String, notes: String? = nil) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = ["status": status]
            if let n = notes, !n.isEmpty { body["notes"] = n }
            let res: JobApplicationActionResponse = try await api.request("PUT", "/admin/job_applications/\(id)/update_status", body: body)
            successMessage = res.message
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update status"
        }
        isActioning = false
    }

    func scheduleInterview(id: Int, scheduledAt: String, meetLink: String?, notes: String?) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = ["scheduled_at": scheduledAt, "interview_type": "video"]
            if let link = meetLink, !link.isEmpty { body["meet_link"] = link }
            if let n = notes, !n.isEmpty { body["notes"] = n }
            let res: JobApplicationActionResponse = try await api.request("POST", "/admin/job_applications/\(id)/schedule_interview", body: body)
            successMessage = res.message
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to schedule interview"
        }
        isActioning = false
    }

    func convertToEmployee(id: Int) async {
        isActioning = true
        error = nil
        do {
            let _: JobApplicationActionResponse = try await api.request("POST", "/admin/job_applications/\(id)/convert_to_employee")
            successMessage = "Converted to employee successfully"
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to convert to employee"
        }
        isActioning = false
    }

    func downloadResume(id: Int) async -> URL? {
        do {
            let data = try await api.requestData("GET", "/admin/job_applications/\(id)/download_resume")
            let tmpDir = FileManager.default.temporaryDirectory
            let fileURL = tmpDir.appendingPathComponent("resume_\(id).pdf")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.error = "Failed to download resume"
            return nil
        }
    }

    func addEvent(id: Int, eventType: String, notes: String?) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = ["event_type": eventType]
            if let n = notes, !n.isEmpty { body["notes"] = n }
            let res: JobApplicationActionResponse = try await api.request("POST", "/admin/job_applications/\(id)/add_event", body: body)
            successMessage = res.message ?? "Event added"
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to add event"
        }
        isActioning = false
    }
}
