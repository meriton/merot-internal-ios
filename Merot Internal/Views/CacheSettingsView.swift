import SwiftUI

struct CacheSettingsView: View {
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var cacheStatistics: CacheStatistics?
    @State private var showingClearCacheAlert = false
    @State private var isClearing = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Cache Information")) {
                    if let stats = cacheStatistics {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Memory Cache", systemImage: "memorychip")
                                Spacer()
                                Text("\(stats.memoryCacheCount) items")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Label("Disk Cache", systemImage: "externaldrive")
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(stats.diskCacheCount) files")
                                        .foregroundColor(.secondary)
                                    Text(stats.diskCacheSizeFormatted)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading cache information...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Cache Management")) {
                    Button(action: {
                        showingClearCacheAlert = true
                    }) {
                        HStack {
                            Label("Clear All Cache", systemImage: "trash")
                                .foregroundColor(.red)
                            Spacer()
                            if isClearing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isClearing)
                    
                    Button(action: {
                        Task {
                            await refreshCacheStats()
                        }
                    }) {
                        Label("Refresh Statistics", systemImage: "arrow.clockwise")
                    }
                }
                
                Section(header: Text("Cache Settings"), 
                       footer: Text("Cache helps improve app performance by storing frequently accessed data locally. Data is automatically refreshed when you pull to refresh or when it expires.")) {
                    
                    HStack {
                        Label("Auto Cache Cleanup", systemImage: "clock.arrow.circlepath")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Cache Expiration", systemImage: "timer")
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("• Dashboard: 5 minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Lists: 30 minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Profiles: 24 hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Holidays: 7 days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 24)
                    }
                }
            }
            .navigationTitle("Cache Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await refreshCacheStats()
                }
            }
            .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    Task {
                        await clearAllCache()
                    }
                }
            } message: {
                Text("This will clear all cached data. The app will need to reload data from the server on next use.")
            }
        }
    }
    
    private func refreshCacheStats() async {
        await MainActor.run {
            cacheStatistics = cachedAPIService.getCacheStatistics()
        }
    }
    
    private func clearAllCache() async {
        await MainActor.run {
            isClearing = true
        }
        
        cachedAPIService.invalidateAllCache()
        
        // Add a small delay to show the loading state
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            isClearing = false
            cacheStatistics = cachedAPIService.getCacheStatistics()
        }
    }
}

#Preview {
    CacheSettingsView()
}