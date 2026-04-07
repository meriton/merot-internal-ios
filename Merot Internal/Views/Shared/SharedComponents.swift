import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
            Text(message)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.2))
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.4))
            if let sub = subtitle {
                Text(sub)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.white)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.8))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

// MARK: - Success Banner

struct SuccessBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.white)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.8))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}

// MARK: - Card Container

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color.white.opacity(0.06))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            if let action = action, let label = actionLabel {
                Button(action: action) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.accent)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Money Formatter

func formatMoney(_ value: FlexDouble?, currency: String? = nil) -> String {
    return formatMoney(value?.value, currency: currency)
}

func formatMoney(_ value: Double?, currency: String? = nil) -> String {
    guard let v = value else { return "-" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = ","
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    let formatted = formatter.string(from: NSNumber(value: v)) ?? String(format: "%.2f", v)
    if let c = currency {
        return "\(formatted) \(c)"
    }
    return formatted
}

// MARK: - Date Formatter

func formatDate(_ iso: String?) -> String {
    guard let iso = iso, iso.count >= 10 else { return "-" }
    let s = String(iso.prefix(10))
    let parts = s.split(separator: "-")
    guard parts.count == 3 else { return s }
    return "\(parts[2]).\(parts[1]).\(parts[0])"
}

func formatDateShort(_ iso: String?) -> String {
    guard let iso = iso, iso.count >= 10 else { return "-" }
    let s = String(iso.prefix(10))
    let parts = s.split(separator: "-")
    guard parts.count == 3 else { return s }
    return "\(parts[2]).\(parts[1])"
}
