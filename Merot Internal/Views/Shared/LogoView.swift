import SwiftUI

struct LogoView: View {
    var height: CGFloat = 40

    var body: some View {
        Text("MEROT")
            .font(.system(size: height * 0.5, weight: .bold, design: .default))
            .foregroundColor(.white)
            .tracking(4)
    }
}
