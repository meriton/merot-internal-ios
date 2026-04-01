import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(MerotButtonStyle())
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 40) {
        ErrorView(message: "Unable to load data. Please check your internet connection.")
        
        ErrorView(message: "Failed to connect to server. Please try again later.") {
            print("Retry tapped")
        }
    }
    .padding()
}