//
//  SplashScreenView.swift
//  Merot Internal
//
//  Created by Claude on 8/5/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: Double = 1.5
    @State private var backgroundOpacity: Double = 1.0
    @State private var showMainContent = false
    @State private var phraseOpacities: [Double] = [0.0, 0.0]
    @Environment(\.colorScheme) var colorScheme
    
    private let taglinePhrases = ["Your Team,", "Beyond Borders."]
    
    var body: some View {
        ZStack {
            // Main content (always present but initially invisible)
            MainContentView()
                .opacity(showMainContent ? 1.0 : 0.0)
            
            // Splash overlay
            if backgroundOpacity > 0 {
                ZStack {
                    // Background
                    (colorScheme == .dark ? Color.black : Color.white)
                        .ignoresSafeArea()
                        .opacity(backgroundOpacity)
                    
                    // Logo and tagline centered in screen
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image("MerotLogo")
                            .renderingMode(colorScheme == .dark ? .template : .original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                            .foregroundColor(colorScheme == .dark ? .white : nil)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                        
                        // Animated tagline
                        HStack(spacing: 8) {
                            ForEach(0..<taglinePhrases.count, id: \.self) { index in
                                Text(taglinePhrases[index])
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .opacity(phraseOpacities[index])
                            }
                        }
                        
                        Spacer()
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Fade in logo (centered and scaled up)
        withAnimation(.easeOut(duration: 0.5)) {
            logoOpacity = 1.0
        }
        
        // Phase 2: Animate tagline phrases one by one
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            for index in 0..<taglinePhrases.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.8) {
                    withAnimation(.easeIn(duration: 1.0)) {
                        phraseOpacities[index] = 1.0
                    }
                }
            }
        }
        
        // Phase 3: Hold for a moment after tagline completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            // Phase 4: Fade in main content while keeping logo visible
            withAnimation(.easeInOut(duration: 0.8)) {
                showMainContent = true
            }
            
            // Phase 5: Fade out splash overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    backgroundOpacity = 0.0
                }
            }
        }
    }
}

struct MainContentView: View {
    @StateObject private var authService = AuthenticationService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if let currentUser = authService.currentUser {
                    if currentUser.userType == "admin" {
                        AdminDashboardView()
                            .environmentObject(authService)
                    } else {
                        DashboardView()
                            .environmentObject(authService)
                    }
                } else {
                    // Show loading while fetching user profile
                    VStack {
                        ProgressView("Loading...")
                        Text("Getting your profile...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
        .onAppear {
            Task {
                if authService.isAuthenticated && authService.currentUser == nil {
                    await authService.getProfile()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}