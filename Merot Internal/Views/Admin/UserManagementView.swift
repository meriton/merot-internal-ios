import SwiftUI

struct UserManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiService = APIService()
    @State private var users: [AdminUserDetail] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedRole: UserRole = .all
    @State private var showingAddUser = false
    @State private var showingUserDetails: AdminUserDetail?
    @State private var currentPage = 1
    @State private var hasMoreUsers = true
    
    enum UserRole: String, CaseIterable {
        case all = "All"
        case admin = "Admin"
        case manager = "Manager"
        case employee = "Employee"
        case suspended = "Suspended"
    }
    
    var filteredUsers: [AdminUserDetail] {
        users.filter { user in
            let matchesSearch = searchText.isEmpty || 
                               user.name.localizedCaseInsensitiveContains(searchText) ||
                               user.email.localizedCaseInsensitiveContains(searchText)
            
            let matchesRole = selectedRole == .all || 
                             (user.role?.lowercased() == selectedRole.rawValue.lowercased()) ||
                             (user.status.lowercased() == selectedRole.rawValue.lowercased())
            
            return matchesSearch && matchesRole
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search users", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                Task {
                                    await refreshUsers()
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onSubmit {
                        Task {
                            await refreshUsers()
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                Button(action: {
                                    selectedRole = role
                                    Task {
                                        await refreshUsers()
                                    }
                                }) {
                                    Text(role.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedRole == role ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedRole == role ? .white : .primary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading users...")
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await loadUsers()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else if filteredUsers.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No users found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredUsers) { user in
                            UserRow(user: user) {
                                showingUserDetails = user
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("User Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddUser = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadUsers()
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView()
        }
        .sheet(item: $showingUserDetails) { user in
            UserDetailView(user: user)
        }
    }
    
    private func loadUsers() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await apiService.getAdminUsers(
                page: currentPage,
                perPage: 50,
                search: searchText.isEmpty ? nil : searchText,
                userType: nil,
                role: selectedRole == .all ? nil : selectedRole.rawValue.lowercased(),
                status: nil
            )
            
            await MainActor.run {
                if currentPage == 1 {
                    users = response.users
                } else {
                    users.append(contentsOf: response.users)
                }
                
                hasMoreUsers = response.pagination.currentPage < response.pagination.totalPages
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load users: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func refreshUsers() async {
        await MainActor.run {
            currentPage = 1
            hasMoreUsers = true
        }
        await loadUsers()
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

struct UserRow: View {
    let user: AdminUserDetail
    let onTap: () -> Void
    
    var roleColor: Color {
        guard let role = user.role else { return .gray }
        switch role.lowercased() {
        case "admin": return .red
        case "manager": return .orange
        case "employee": return .blue
        case "employer": return .purple
        default: return .gray
        }
    }
    
    var statusColor: Color {
        switch user.status.lowercased() {
        case "active": return .green
        case "suspended": return .red
        case "pending": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Show employer if available
                        if let employer = user.employer {
                            Text("@ \(employer.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(user.role?.capitalized ?? user.userType.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(roleColor.opacity(0.2))
                            .foregroundColor(roleColor)
                            .cornerRadius(8)
                        
                        Text(user.status.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(8)
                    }
                }
                
                HStack {
                    if let lastLogin = user.lastLogin,
                       let loginDate = ISO8601DateFormatter().date(from: lastLogin) {
                        Label("Last login: \(loginDate, style: .relative)", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Label("Never logged in", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("ID: \(user.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var userType = "admin"
    @State private var sendWelcomeEmail = true
    
    let userTypes = [
        ("admin", "Admin"),
        ("employer", "Employer")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Full Name", text: $name)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Picker("User Type", selection: $userType) {
                        ForEach(userTypes, id: \.0) { type, title in
                            Text(title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Toggle("Send Welcome Email", isOn: $sendWelcomeEmail)
                }
            }
            .navigationTitle("Add User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // TODO: Implement user creation
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

struct UserDetailView: View {
    let user: AdminUserDetail
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    
    var roleColor: Color {
        guard let role = user.role else { return .gray }
        switch role.lowercased() {
        case "admin": return .red
        case "manager": return .orange
        case "employee": return .blue
        case "employer": return .purple
        default: return .gray
        }
    }
    
    var statusColor: Color {
        switch user.status.lowercased() {
        case "active": return .green
        case "suspended": return .red
        case "pending": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // User Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("User Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            InfoRow(label: "Name", value: user.name)
                            InfoRow(label: "Email", value: user.email)
                            InfoRow(label: "User ID", value: "\(user.id)")
                            InfoRow(label: "User Type", value: user.userType.capitalized)
                            
                            if let employer = user.employer {
                                InfoRow(label: "Company", value: employer.name)
                            }
                            
                            if let department = user.department {
                                InfoRow(label: "Department", value: department)
                            }
                            
                            if let employeeId = user.employeeId {
                                InfoRow(label: "Employee ID", value: employeeId)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Access Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Access")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Role")
                                Spacer()
                                Text(user.role?.capitalized ?? user.userType.capitalized)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(roleColor.opacity(0.2))
                                    .foregroundColor(roleColor)
                                    .cornerRadius(8)
                            }
                            
                            HStack {
                                Text("Status")
                                Spacer()
                                Text(user.status.capitalized)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(statusColor.opacity(0.2))
                                    .foregroundColor(statusColor)
                                    .cornerRadius(8)
                            }
                            
                            if user.isSuperAdmin == true {
                                HStack {
                                    Text("Super Admin")
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Activity Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            if let lastLogin = user.lastLogin,
                               let loginDate = ISO8601DateFormatter().date(from: lastLogin) {
                                InfoRow(label: "Last Login", value: loginDate.formatted(date: .abbreviated, time: .shortened))
                            } else {
                                InfoRow(label: "Last Login", value: "Never")
                            }
                            
                            if let createdDate = ISO8601DateFormatter().date(from: user.createdAt) {
                                InfoRow(label: "Account Created", value: createdDate.formatted(date: .abbreviated, time: .omitted))
                            }
                            
                            if let signInCount = user.signInCount {
                                InfoRow(label: "Sign In Count", value: "\(signInCount)")
                            }
                            
                            if let suspendedAt = user.suspendedAt,
                               let suspendedDate = ISO8601DateFormatter().date(from: suspendedAt) {
                                InfoRow(label: "Suspended On", value: suspendedDate.formatted(date: .abbreviated, time: .shortened))
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            Button("Reset Password") {
                                // TODO: Implement password reset with API call
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            Button("Send Welcome Email") {
                                // TODO: Implement welcome email
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            if user.status.lowercased() == "active" {
                                Button("Suspend User") {
                                    // TODO: Implement user suspension with API call
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            } else {
                                Button("Activate User") {
                                    // TODO: Implement user activation with API call
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button("Delete User") {
                                showingDeleteConfirmation = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("User Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Delete User", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // TODO: Implement user deletion
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(user.name)? This action cannot be undone.")
        }
    }
}

#Preview {
    UserManagementView()
}