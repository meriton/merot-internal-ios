import SwiftUI

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var selectedExportTypes: Set<ExportType> = []
    @State private var exportFormat: ExportFormat = .csv
    @State private var dateRange: DateRange = .lastMonth
    @State private var isExporting = false
    @State private var exportProgress: Double = 0.0
    @State private var exportError: String?
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    enum ExportType: String, CaseIterable, Identifiable {
        case employees = "employees"
        case employers = "employers"
        case timeOffRequests = "time_off_requests"
        case invoices = "invoices"
        case systemLogs = "system_logs"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .employees: return "Employees"
            case .employers: return "Employers"
            case .timeOffRequests: return "Time Off Requests"
            case .invoices: return "Invoices"
            case .systemLogs: return "System Logs"
            }
        }
        
        var icon: String {
            switch self {
            case .employees: return "person.3"
            case .employers: return "building.2"
            case .timeOffRequests: return "calendar.badge.clock"
            case .invoices: return "doc.text"
            case .systemLogs: return "doc.text.magnifyingglass"
            }
        }
    }
    
    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case pdf = "PDF"
    }
    
    enum DateRange: String, CaseIterable {
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        case lastQuarter = "Last Quarter"
        case lastYear = "Last Year"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Export Data Types") {
                    ForEach(ExportType.allCases) { type in
                        HStack {
                            Image(systemName: type.icon)
                                .frame(width: 20)
                                .foregroundColor(.blue)
                            
                            Text(type.displayName)
                            
                            Spacer()
                            
                            if selectedExportTypes.contains(type) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleExportType(type)
                        }
                    }
                }
                
                Section("Export Settings") {
                    HStack {
                        Label("Format", systemImage: "doc")
                        Spacer()
                        Picker("Format", selection: $exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Label("Date Range", systemImage: "calendar")
                        Spacer()
                        Picker("Date Range", selection: $dateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                if !selectedExportTypes.isEmpty {
                    Section("Preview") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Export will include:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ForEach(Array(selectedExportTypes), id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundColor(.blue)
                                        .frame(width: 16)
                                    Text(type.displayName)
                                        .font(.caption)
                                    Spacer()
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Format:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(exportFormat.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Time Period:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(dateRange.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if isExporting {
                    Section("Export Progress") {
                        VStack(spacing: 8) {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Exporting data...")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            ProgressView(value: exportProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            HStack {
                                Text("\(Int(exportProgress * 100))% complete")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if let error = exportError {
                    Section("Error") {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        Task {
                            await performExport()
                        }
                    }
                    .disabled(selectedExportTypes.isEmpty || isExporting)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                AdminShareSheet(items: [url])
            }
        }
    }
    
    private func toggleExportType(_ type: ExportType) {
        if selectedExportTypes.contains(type) {
            selectedExportTypes.remove(type)
        } else {
            selectedExportTypes.insert(type)
        }
    }
    
    private func performExport() async {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            exportError = nil
        }
        
        do {
            // Simulate export process with progress updates
            for i in 1...10 {
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                await MainActor.run {
                    exportProgress = Double(i) / 10.0
                }
            }
            
            // Create a temporary file for the export
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "merot_export_\(Date().timeIntervalSince1970).\(exportFormat.rawValue.lowercased())"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            // Generate export content
            let exportContent = generateExportContent()
            try exportContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            await MainActor.run {
                exportedFileURL = fileURL
                showingShareSheet = true
                isExporting = false
            }
            
        } catch {
            await MainActor.run {
                exportError = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
        }
    }
    
    private func generateExportContent() -> String {
        var content = ""
        
        switch exportFormat {
        case .csv:
            content = generateCSVContent()
        case .json:
            content = generateJSONContent()
        case .pdf:
            content = generatePDFContent()
        }
        
        return content
    }
    
    private func generateCSVContent() -> String {
        var csvContent = ""
        
        for type in selectedExportTypes {
            csvContent += "\n\(type.displayName.uppercased())\n"
            
            switch type {
            case .employees:
                csvContent += "ID,Name,Email,Department,Status\n"
                csvContent += "Sample data for employees...\n"
            case .employers:
                csvContent += "ID,Company Name,Contact Email,Created Date\n"
                csvContent += "Sample data for employers...\n"
            case .timeOffRequests:
                csvContent += "ID,Employee,Start Date,End Date,Status\n"
                csvContent += "Sample data for time off requests...\n"
            case .invoices:
                csvContent += "ID,Employer,Amount,Status,Due Date\n"
                csvContent += "Sample data for invoices...\n"
            case .systemLogs:
                csvContent += "Timestamp,Level,Message\n"
                csvContent += "Sample log entries...\n"
            }
            csvContent += "\n"
        }
        
        return csvContent
    }
    
    private func generateJSONContent() -> String {
        var jsonData: [String: Any] = [:]
        jsonData["export_date"] = ISO8601DateFormatter().string(from: Date())
        jsonData["date_range"] = dateRange.rawValue
        jsonData["format"] = exportFormat.rawValue
        
        var data: [String: Any] = [:]
        
        for type in selectedExportTypes {
            switch type {
            case .employees:
                data["employees"] = ["Sample employee data"]
            case .employers:
                data["employers"] = ["Sample employer data"]
            case .timeOffRequests:
                data["time_off_requests"] = ["Sample time off data"]
            case .invoices:
                data["invoices"] = ["Sample invoice data"]
            case .systemLogs:
                data["system_logs"] = ["Sample log data"]
            }
        }
        
        jsonData["data"] = data
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "Error generating JSON content"
    }
    
    private func generatePDFContent() -> String {
        // For PDF, we'll return HTML content that could be converted to PDF
        var htmlContent = """
        <html>
        <head><title>Merot Internal Data Export</title></head>
        <body>
        <h1>Merot Internal Data Export</h1>
        <p>Export Date: \(Date())</p>
        <p>Date Range: \(dateRange.rawValue)</p>
        """
        
        for type in selectedExportTypes {
            htmlContent += "<h2>\(type.displayName)</h2>"
            htmlContent += "<p>Sample data for \(type.displayName.lowercased())...</p>"
        }
        
        htmlContent += "</body></html>"
        return htmlContent
    }
}

struct AdminShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DataExportView()
}