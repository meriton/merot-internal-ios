import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enableBiometrics = false
    @State private var enableAutoLock = true
    @State private var autoLockDuration = 300 // 5 minutes
    @State private var enableTwoFactor = false
    @State private var sessionTimeout = 1800 // 30 minutes
    @State private var enableSecureBackup = true
    @State private var enableAuditLogging = true
    @State private var showingPasswordPolicy = false
    @State private var showingSecurityAudit = false
    @State private var biometricType: LABiometryType = .none
    
    let autoLockOptions = [
        (title: "1 minute", value: 60),
        (title: "5 minutes", value: 300),
        (title: "15 minutes", value: 900),
        (title: "30 minutes", value: 1800),
        (title: "Never", value: 0)
    ]
    
    let sessionTimeoutOptions = [
        (title: "15 minutes", value: 900),
        (title: "30 minutes", value: 1800),
        (title: "1 hour", value: 3600),
        (title: "4 hours", value: 14400),
        (title: "8 hours", value: 28800)
    ]
    
    var body: some View {
        NavigationView {
            List {
                // Authentication Section
                Section("Authentication") {
                    if biometricType != .none {
                        Toggle(isOn: $enableBiometrics) {
                            HStack {
                                Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                                    .foregroundColor(.blue)
                                Text(biometricType == .faceID ? "Face ID" : "Touch ID")
                            }
                        }
                    }
                    
                    Toggle(isOn: $enableTwoFactor) {
                        Label("Two-Factor Authentication", systemImage: "key.fill")
                    }
                    
                    Button(action: {
                        showingPasswordPolicy = true
                    }) {
                        HStack {
                            Label("Password Policy", systemImage: "lock.doc")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // Session Management Section
                Section("Session Management") {
                    Toggle(isOn: $enableAutoLock) {
                        Label("Auto Lock", systemImage: "lock.circle")
                    }
                    
                    if enableAutoLock {
                        HStack {
                            Label("Auto Lock Duration", systemImage: "timer")
                            Spacer()
                            Picker("Duration", selection: $autoLockDuration) {
                                ForEach(autoLockOptions, id: \.value) { option in
                                    Text(option.title).tag(option.value)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    HStack {
                        Label("Session Timeout", systemImage: "clock.badge.exclamationmark")
                        Spacer()
                        Picker("Timeout", selection: $sessionTimeout) {
                            ForEach(sessionTimeoutOptions, id: \.value) { option in
                                Text(option.title).tag(option.value)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Data Protection Section
                Section("Data Protection") {
                    Toggle(isOn: $enableSecureBackup) {
                        Label("Secure Backup", systemImage: "icloud.and.arrow.up.fill")
                    }
                    
                    Toggle(isOn: $enableAuditLogging) {
                        Label("Audit Logging", systemImage: "doc.text.magnifyingglass")
                    }
                    
                    Button("Clear Security Logs") {
                        // TODO: Implement log clearing
                    }
                    .foregroundColor(.orange)
                }
                
                // Security Analysis Section
                Section("Security Analysis") {
                    Button(action: {
                        showingSecurityAudit = true
                    }) {
                        HStack {
                            Label("Security Audit", systemImage: "shield.checkerboard")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    SecurityStatusRow(
                        title: "Encryption Status",
                        status: "Active",
                        statusColor: .green,
                        icon: "lock.shield.fill"
                    )
                    
                    SecurityStatusRow(
                        title: "Certificate Validity",
                        status: "Valid",
                        statusColor: .green,
                        icon: "checkmark.seal.fill"
                    )
                    
                    SecurityStatusRow(
                        title: "Last Security Scan",
                        status: "2 hours ago",
                        statusColor: .blue,
                        icon: "magnifyingglass"
                    )
                }
                
                // Emergency Actions Section
                Section("Emergency Actions") {
                    Button("Force Logout All Sessions") {
                        // TODO: Implement force logout
                    }
                    .foregroundColor(.red)
                    
                    Button("Reset Security Settings") {
                        resetSecuritySettings()
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Security Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            checkBiometricAvailability()
        }
        .sheet(isPresented: $showingPasswordPolicy) {
            PasswordPolicyView()
        }
        .sheet(isPresented: $showingSecurityAudit) {
            SecurityAuditView()
        }
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
    
    private func resetSecuritySettings() {
        enableBiometrics = false
        enableAutoLock = true
        autoLockDuration = 300
        enableTwoFactor = false
        sessionTimeout = 1800
        enableSecureBackup = true
        enableAuditLogging = true
    }
}

struct SecurityStatusRow: View {
    let title: String
    let status: String
    let statusColor: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(statusColor)
                .frame(width: 20)
            
            Text(title)
            
            Spacer()
            
            Text(status)
                .foregroundColor(statusColor)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct PasswordPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Current Policy") {
                    PolicyRow(requirement: "Minimum 8 characters", isEnabled: true)
                    PolicyRow(requirement: "At least 1 uppercase letter", isEnabled: true)
                    PolicyRow(requirement: "At least 1 lowercase letter", isEnabled: true)
                    PolicyRow(requirement: "At least 1 number", isEnabled: true)
                    PolicyRow(requirement: "At least 1 special character", isEnabled: false)
                    PolicyRow(requirement: "No common passwords", isEnabled: true)
                    PolicyRow(requirement: "Password expiry (90 days)", isEnabled: false)
                }
                
                Section("Password Strength") {
                    HStack {
                        Text("Required Strength")
                        Spacer()
                        Text("Medium")
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }
                
                Section("Security Recommendations") {
                    Text("• Use a unique password for each account")
                    Text("• Consider using a password manager")
                    Text("• Enable two-factor authentication")
                    Text("• Change passwords regularly")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .navigationTitle("Password Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PolicyRow: View {
    let requirement: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
            
            Text(requirement)
                .foregroundColor(isEnabled ? .primary : .secondary)
            
            Spacer()
        }
    }
}

struct SecurityAuditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRunningAudit = false
    @State private var auditProgress: Double = 0.0
    @State private var auditResults: [AuditResult] = []
    
    var body: some View {
        NavigationView {
            List {
                if isRunningAudit {
                    Section("Security Scan in Progress") {
                        VStack(spacing: 12) {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Scanning security settings...")
                                Spacer()
                            }
                            
                            ProgressView(value: auditProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("\(Int(auditProgress * 100))% complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                } else if auditResults.isEmpty {
                    Section("Security Audit") {
                        VStack(spacing: 16) {
                            Image(systemName: "shield.checkerboard")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Run Security Audit")
                                .font(.headline)
                            
                            Text("Analyze your security settings and identify potential vulnerabilities.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Start Audit") {
                                Task {
                                    await runSecurityAudit()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    Section("Audit Results") {
                        ForEach(auditResults) { result in
                            AuditResultRow(result: result)
                        }
                    }
                    
                    Section("Actions") {
                        Button("Run New Audit") {
                            Task {
                                await runSecurityAudit()
                            }
                        }
                        
                        Button("Export Results") {
                            // TODO: Implement export
                        }
                    }
                }
            }
            .navigationTitle("Security Audit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func runSecurityAudit() async {
        await MainActor.run {
            isRunningAudit = true
            auditProgress = 0.0
            auditResults = []
        }
        
        // Simulate audit process
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            await MainActor.run {
                auditProgress = Double(i) / 10.0
            }
        }
        
        // Generate sample audit results
        let sampleResults = [
            AuditResult(category: "Authentication", issue: "Two-Factor Authentication", status: .warning, description: "2FA is not enabled for admin users"),
            AuditResult(category: "Password Policy", issue: "Special Characters", status: .info, description: "Consider requiring special characters in passwords"),
            AuditResult(category: "Session Management", issue: "Auto Lock", status: .pass, description: "Auto lock is properly configured"),
            AuditResult(category: "Data Protection", issue: "Encryption", status: .pass, description: "All data is properly encrypted"),
            AuditResult(category: "Audit Logging", issue: "Log Retention", status: .warning, description: "Logs are not being archived for long-term storage")
        ]
        
        await MainActor.run {
            auditResults = sampleResults
            isRunningAudit = false
        }
    }
}

struct AuditResult: Identifiable {
    let id = UUID()
    let category: String
    let issue: String
    let status: Status
    let description: String
    
    enum Status {
        case pass
        case warning
        case error
        case info
        
        var color: Color {
            switch self {
            case .pass: return .green
            case .warning: return .orange
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .pass: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
}

struct AuditResultRow: View {
    let result: AuditResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.status.icon)
                    .foregroundColor(result.status.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.issue)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(result.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(result.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enablePushNotifications = true
    @State private var enableEmailNotifications = true
    @State private var enableTimeOffAlerts = true
    @State private var enableInvoiceAlerts = true
    @State private var enableSystemAlerts = true
    @State private var enableNewUserAlerts = true
    @State private var quietHoursEnabled = false
    @State private var quietHoursStart = Date()
    @State private var quietHoursEnd = Date()
    
    var body: some View {
        NavigationView {
            List {
                Section("Push Notifications") {
                    Toggle("Enable Push Notifications", isOn: $enablePushNotifications)
                    
                    if enablePushNotifications {
                        Toggle("Time Off Requests", isOn: $enableTimeOffAlerts)
                        Toggle("Invoice Updates", isOn: $enableInvoiceAlerts)
                        Toggle("System Alerts", isOn: $enableSystemAlerts)
                        Toggle("New User Registrations", isOn: $enableNewUserAlerts)
                    }
                }
                
                Section("Email Notifications") {
                    Toggle("Enable Email Notifications", isOn: $enableEmailNotifications)
                    
                    if enableEmailNotifications {
                        Text("Daily digest emails will be sent at 9:00 AM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Quiet Hours") {
                    Toggle("Enable Quiet Hours", isOn: $quietHoursEnabled)
                    
                    if quietHoursEnabled {
                        DatePicker("Start Time", selection: $quietHoursStart, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $quietHoursEnd, displayedComponents: .hourAndMinute)
                        
                        Text("No notifications will be sent during quiet hours")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SecuritySettingsView()
}