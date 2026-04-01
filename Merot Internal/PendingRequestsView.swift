import SwiftUI

struct PendingRequestsView: View {
    @StateObject private var apiService = APIService()
    @State private var pendingRequests: [TimeOffRequest] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedRequest: TimeOffRequest?
    @State private var processingRequestId: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading pending requests...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if pendingRequests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("No Pending Requests")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("All time off requests have been processed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(pendingRequests, id: \.id) { request in
                            PendingRequestRow(
                                request: request,
                                isProcessing: processingRequestId == request.id,
                                onApprove: { await approveRequest(request) },
                                onDeny: { await denyRequest(request) },
                                onTap: {
                                    selectedRequest = request
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await loadPendingRequests()
                    }
                }
                
                if let errorMessage = errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                        
                        Button("Retry") {
                            Task {
                                await loadPendingRequests()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Pending Requests")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await loadPendingRequests()
                }
            }
            .sheet(item: $selectedRequest) { request in
                RequestDetailView(request: request) {
                    Task {
                        await loadPendingRequests()
                    }
                }
            }
        }
    }
    
    private func loadPendingRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pendingRequests = try await apiService.getTimeOffRequests(status: "pending")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func approveRequest(_ request: TimeOffRequest) async {
        processingRequestId = request.id
        
        do {
            _ = try await apiService.approveTimeOffRequest(id: request.id)
            await loadPendingRequests()
        } catch {
            errorMessage = "Failed to approve request: \(error.localizedDescription)"
        }
        
        processingRequestId = nil
    }
    
    private func denyRequest(_ request: TimeOffRequest) async {
        processingRequestId = request.id
        
        do {
            _ = try await apiService.denyTimeOffRequest(id: request.id)
            await loadPendingRequests()
        } catch {
            errorMessage = "Failed to deny request: \(error.localizedDescription)"
        }
        
        processingRequestId = nil
    }
}

struct PendingRequestRow: View {
    let request: TimeOffRequest
    let isProcessing: Bool
    let onApprove: () async -> Void
    let onDeny: () async -> Void
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.employee?.fullName ?? request.employeeName ?? "Unknown Employee")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(request.employee?.department ?? "N/A")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(request.days ?? 0) day\((request.days ?? 0) == 1 ? "" : "s")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        StatusBadge(status: request.approvalStatus ?? request.status)
                    }
                }
                
                // Details row
                HStack {
                    Label {
                        Text("\(formattedDate(request.startDate)) - \(formattedDate(request.endDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let leaveType = request.timeOffRecord?.leaveType {
                        Label {
                            Text(leaveType.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Action buttons row
                HStack(spacing: 6) {
                    Button(action: {
                        Task {
                            await onApprove()
                        }
                    }) {
                        HStack(spacing: 3) {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                            }
                            Text("Approve")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(isProcessing)
                    
                    Button(action: {
                        Task {
                            await onDeny()
                        }
                    }) {
                        HStack(spacing: 3) {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "xmark")
                                    .font(.caption)
                            }
                            Text("Deny")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(isProcessing)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .listRowSeparator(.hidden)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        // Try alternative format without milliseconds
        let alternativeFormatter = DateFormatter()
        alternativeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = alternativeFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

struct RequestDetailView: View {
    let request: TimeOffRequest
    let onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Employee Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Employee Information")
                            .font(.headline)
                        
                        RequestInfoRow(label: "Name", value: request.employee?.fullName ?? request.employeeName ?? "Unknown Employee")
                        RequestInfoRow(label: "Employee ID", value: request.employee?.employeeId ?? "N/A")
                        RequestInfoRow(label: "Department", value: request.employee?.department ?? "N/A")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Request Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Request Details")
                            .font(.headline)
                        
                        RequestInfoRow(label: "Leave Type", value: request.timeOffRecord?.leaveType?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Unknown")
                        RequestInfoRow(label: "Start Date", value: formattedDate(request.startDate))
                        RequestInfoRow(label: "End Date", value: formattedDate(request.endDate))
                        RequestInfoRow(label: "Duration", value: "\(request.days ?? 0) day\((request.days ?? 0) == 1 ? "" : "s")")
                        RequestInfoRow(label: "Status", value: (request.approvalStatus ?? request.status).capitalized)
                        RequestInfoRow(label: "Requested", value: formattedDate(request.createdAt))
                        
                        if let balance = request.timeOffRecord?.balance {
                            RequestInfoRow(label: "Available Balance", value: "\(balance) days")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Request Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        // Try alternative format without milliseconds
        let alternativeFormatter = DateFormatter()
        alternativeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = alternativeFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

struct RequestInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    PendingRequestsView()
}