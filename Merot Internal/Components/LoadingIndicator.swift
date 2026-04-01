import SwiftUI

struct SmartLoadingIndicator: View {
    let isLoading: Bool
    let hasError: Bool
    let errorMessage: String?
    
    var body: some View {
        if isLoading {
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else if hasError, let errorMessage = errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Error")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct PullToRefreshStatus: View {
    enum Status {
        case idle
        case pulling
        case refreshing
        case cancelled
        case completed
    }
    
    let status: Status
    
    var body: some View {
        HStack(spacing: 6) {
            switch status {
            case .idle:
                EmptyView()
            case .pulling:
                Image(systemName: "arrow.down.circle")
                    .foregroundColor(.blue)
                Text("Pull to refresh")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .refreshing:
                ProgressView()
                    .scaleEffect(0.7)
                Text("Refreshing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .cancelled:
                Image(systemName: "xmark.circle")
                    .foregroundColor(.orange)
                Text("Cancelled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .completed:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("Updated")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .opacity(status == .idle ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: status)
    }
}

#Preview {
    VStack(spacing: 20) {
        SmartLoadingIndicator(
            isLoading: true,
            hasError: false,
            errorMessage: nil
        )
        
        SmartLoadingIndicator(
            isLoading: false,
            hasError: true,
            errorMessage: "Network connection failed. Please try again."
        )
        
        VStack(spacing: 10) {
            PullToRefreshStatus(status: .pulling)
            PullToRefreshStatus(status: .refreshing)
            PullToRefreshStatus(status: .cancelled)
            PullToRefreshStatus(status: .completed)
        }
    }
    .padding()
}