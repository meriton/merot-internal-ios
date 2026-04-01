import SwiftUI

struct CacheIndicator: View {
    let isFromCache: Bool
    
    var body: some View {
        if isFromCache {
            HStack(spacing: 4) {
                Image(systemName: "externaldrive.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Text("Cached")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct RefreshIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.clockwise")
                .font(.caption2)
                .foregroundColor(.green)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
                .onDisappear {
                    isAnimating = false
                }
            Text("Refreshing")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DataSourceIndicator: View {
    enum DataSource {
        case cache
        case network
        case refreshing
    }
    
    let source: DataSource
    
    var body: some View {
        switch source {
        case .cache:
            CacheIndicator(isFromCache: true)
        case .network:
            HStack(spacing: 4) {
                Image(systemName: "wifi")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("Live")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        case .refreshing:
            RefreshIndicator()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DataSourceIndicator(source: .cache)
        DataSourceIndicator(source: .network)
        DataSourceIndicator(source: .refreshing)
    }
    .padding()
}