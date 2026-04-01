import SwiftUI

// MEROT Brand Colors (matching the Rails employer interface)
extension Color {
    static let merotBlue = Color(red: 0.506, green: 0.694, blue: 0.808) // #81b1ce
    static let merotBlueDark = Color(red: 0.420, green: 0.608, blue: 0.765) // #6b9bc3
    static let merotGrayLight = Color(red: 0.976, green: 0.980, blue: 0.984) // #f9fafb
}

// Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                colorScheme == .dark 
                    ? Color(.systemGray6) 
                    : Color.merotGrayLight
            )
            .foregroundColor(Color(.label))
            .accentColor(.merotBlue) // Cursor color
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        colorScheme == .dark 
                            ? Color(.systemGray4) 
                            : Color.merotBlue.opacity(0.3), 
                        lineWidth: 1
                    )
            )
    }
}

// MEROT Button Style (matching the employer login gradient)
struct MerotButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.merotBlue, Color.merotBlueDark]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}