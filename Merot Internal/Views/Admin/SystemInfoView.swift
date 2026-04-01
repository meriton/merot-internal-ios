import SwiftUI

struct SystemInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var cacheStats: CacheStatistics?
    
    var body: some View {
        NavigationView {
            List {
                Section("Application") {
                    SystemInfoRow(label: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    SystemInfoRow(label: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                    SystemInfoRow(label: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "Unknown")
                }
                
                Section("Device") {
                    SystemInfoRow(label: "Model", value: deviceModel)
                    SystemInfoRow(label: "iOS Version", value: UIDevice.current.systemVersion)
                    SystemInfoRow(label: "Device Name", value: UIDevice.current.name)
                    SystemInfoRow(label: "Available Storage", value: availableStorage)
                }
                
                Section("Performance") {
                    if let stats = cacheStats {
                        SystemInfoRow(label: "Cache Files", value: "\(stats.diskCacheCount)")
                        SystemInfoRow(label: "Cache Size", value: stats.diskCacheSizeFormatted)
                        SystemInfoRow(label: "Memory Cache", value: "\(stats.memoryCacheCount) limit")
                    } else {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading cache statistics...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Network") {
                    SystemInfoRow(label: "Base URL", value: NetworkManager.shared.baseURL)
                    SystemInfoRow(label: "Connection", value: "Active")
                    SystemInfoRow(label: "Last Sync", value: lastSyncTime)
                }
                
                Section("Debug Information") {
                    Button("Copy System Info") {
                        copySystemInfoToClipboard()
                    }
                    
                    Button("Export Logs") {
                        // TODO: Implement log export
                    }
                }
            }
            .navigationTitle("System Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCacheStats()
        }
    }
    
    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private var availableStorage: String {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let freeSize = attributes[.systemFreeSize] as? NSNumber else {
            return "Unknown"
        }
        return ByteCountFormatter.string(fromByteCount: freeSize.int64Value, countStyle: .file)
    }
    
    private var lastSyncTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    private func loadCacheStats() {
        cacheStats = cachedAPIService.getCacheStatistics()
    }
    
    private func copySystemInfoToClipboard() {
        let systemInfo = """
        Merot Internal System Information
        
        Application:
        - Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        - Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
        - Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")
        
        Device:
        - Model: \(deviceModel)
        - iOS Version: \(UIDevice.current.systemVersion)
        - Device Name: \(UIDevice.current.name)
        - Available Storage: \(availableStorage)
        
        Network:
        - Base URL: \(NetworkManager.shared.baseURL)
        - Generated: \(Date())
        """
        
        UIPasteboard.general.string = systemInfo
    }
}

struct SystemInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    SystemInfoView()
}