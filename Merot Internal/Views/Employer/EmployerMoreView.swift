import SwiftUI

struct EmployerMoreView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        EmployerHolidaysView()
                    } label: {
                        Label("Holidays", systemImage: "calendar")
                            .foregroundColor(.white)
                    }

                    NavigationLink {
                        EmployerServiceAgreementsView()
                    } label: {
                        Label("Service Agreements", systemImage: "signature")
                            .foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))

                Section {
                    NavigationLink {
                        EmployerProfileView()
                    } label: {
                        Label("Profile", systemImage: "person.circle.fill")
                            .foregroundColor(.white)
                    }

                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))
            }
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("More")
            .brandNavBar()
        }
    }
}
