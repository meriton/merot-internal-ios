import SwiftUI

struct StatusBadge: View {
    let status: String

    private var color: Color {
        switch status.lowercased() {
        case "active", "approved", "completed", "paid", "published", "hired", "signed":
            return .green
        case "pending", "pending_review", "draft", "new", "submitted", "viewing":
            return .yellow
        case "sent", "processing", "screening", "interviewing", "viewed":
            return .blue
        case "denied", "rejected", "cancelled", "terminated", "overdue", "suspended", "deactivated":
            return .red
        case "closed", "archived", "expired":
            return .gray
        default:
            return .gray
        }
    }

    var body: some View {
        Text(status.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(6)
    }
}
