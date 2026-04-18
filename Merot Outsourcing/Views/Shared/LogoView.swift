import SwiftUI

struct LogoView: View {
    var height: CGFloat = 40

    var body: some View {
        Image("MerotLogo")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .foregroundColor(.white)
    }
}
