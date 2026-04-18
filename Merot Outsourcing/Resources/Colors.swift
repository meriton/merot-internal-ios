import SwiftUI

extension Color {
    static let brand = Color(hex: "0a0a0a")
    static let brandLight = Color(hex: "1a1a1a")
    static let accent = Color(hex: "5eead4")
    static let brandAccent = Color(hex: "6366f1") // matches outsourcing logo dot
    static let brandGreen = Color(hex: "2b7a5b")
    static let success = Color(hex: "16a34a")
    static let warning = Color(hex: "f59e0b")
    static let error = Color(hex: "dc2626")
    static let bgLight = Color(hex: "f8fafc")
    static let muted = Color(hex: "94a3b8")
    static let textDark = Color(hex: "0f172a")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
