# Merot Outsourcing iOS App - Rewrite Plan

## Architecture Overview

Following the merot-hrs-ios patterns exactly:

- **Pattern**: MVVM with @Published properties
- **Networking**: Singleton `APIService` with generic `request<T>()` method
- **Auth**: JWT stored in Keychain via `KeychainHelper`, refresh token support
- **Navigation**: `TabView` with 5 tabs (Dashboard, Employees, Invoices, Hiring, More)
- **Design**: Dark navy theme (#1e3a5f background), white text, teal accents (#5eead4), translucent cards
- **State**: `@StateObject` for ViewModels, `@EnvironmentObject` for auth
- **API**: `https://api.outsourcing.merot.com/api/v2` with v2 endpoints

## Color Scheme (matching hrs-ios)
- Primary/Background: #1e3a5f (navy)
- Primary Light: #2d5a8e
- Accent/Teal: #5eead4
- Green: #2b7a5b (buttons)
- Success: #16a34a
- Warning: #f59e0b
- Error: #dc2626
- Muted: #94a3b8
- Card background: white @ 0.06-0.08 opacity
- Card border: white @ 0.08-0.12 opacity

## API Base
- Production: `https://api.outsourcing.merot.com/api/v2`
- Debug: `http://localhost:3000/api/v2`
- Auth: `POST /api/v2/auth/login` with `{ email, password, user_type: "admin" }`
- Returns: `{ data: { access_token, refresh_token, user: {...}, expires_at } }`

## Folder Structure
```
Merot Internal/
  App/
    MerotInternalApp.swift
    ContentView.swift
  Models/
    User.swift
    Employer.swift
    Employee.swift
    Invoice.swift
    Payroll.swift
    JobPosting.swift
    JobApplication.swift
    Agreement.swift
    TimeOff.swift
    Holiday.swift
    PersonalInfoRequest.swift
    ContactRequest.swift
    Dashboard.swift
  Services/
    APIService.swift
    KeychainHelper.swift
  Resources/
    Colors.swift
  ViewModels/
    AuthViewModel.swift
    DashboardViewModel.swift
    EmployersViewModel.swift
    EmployeesViewModel.swift
    InvoicesViewModel.swift
    PayrollViewModel.swift
    JobPostingsViewModel.swift
    JobApplicationsViewModel.swift
    AgreementsViewModel.swift
    TimeOffViewModel.swift
    HolidaysViewModel.swift
    PersonalInfoViewModel.swift
    ContactRequestsViewModel.swift
    SettingsViewModel.swift
  Views/
    Auth/
      LoginView.swift
    Dashboard/
      DashboardView.swift
    Employers/
      EmployersListView.swift
      EmployerDetailView.swift
    Employees/
      EmployeesListView.swift
      EmployeeDetailView.swift
    Invoices/
      InvoicesListView.swift
      InvoiceDetailView.swift
    Payroll/
      PayrollListView.swift
      PayrollDetailView.swift
    Hiring/
      JobPostingsListView.swift
      JobPostingDetailView.swift
      JobApplicationDetailView.swift
    Agreements/
      EmployeeAgreementsListView.swift
      ServiceAgreementsListView.swift
    TimeOff/
      TimeOffRequestsView.swift
    Holidays/
      HolidaysView.swift
    PersonalInfo/
      PersonalInfoRequestsView.swift
    ContactRequests/
      ContactRequestsView.swift
    Settings/
      SettingsView.swift
    Shared/
      BrandNavBar.swift
      StatusBadge.swift
      LogoView.swift
      LoadingView.swift
      EmptyStateView.swift
      ErrorBanner.swift
      SearchBar.swift
      StatCard.swift
      PdfViewer.swift
```

## Screens & API Endpoints

### 1. Login
- `POST /api/v2/auth/login` { email, password, user_type: "admin" }
- `GET /api/v2/auth/profile`
- `POST /api/v2/auth/refresh` { refresh_token }

### 2. Dashboard
- `GET /api/v2/admin/dashboard`
- Shows: stats cards, pending items, upcoming payroll/holiday, recent activity

### 3. Employers
- `GET /api/v2/admin/employers` (search, status filter)
- `GET /api/v2/admin/employers/:id`

### 4. Employees
- `GET /api/v2/admin/employees` (search, status/employer/type filter)
- `GET /api/v2/admin/employees/:id`

### 5. Invoices
- `GET /api/v2/admin/invoices` (status, search, employer_id filter)
- `GET /api/v2/admin/invoices/:id`
- `POST /api/v2/admin/invoices/:id/approve`
- `POST /api/v2/admin/invoices/:id/mark_sent`
- `POST /api/v2/admin/invoices/:id/mark_paid`
- `POST /api/v2/admin/invoices/:id/send_email`
- `POST /api/v2/admin/invoices/:id/record_payment`

### 6. Payroll
- `GET /api/v2/admin/payroll` (year filter)
- `GET /api/v2/admin/payroll/:id`
- `POST /api/v2/admin/payroll/:id/approve`

### 7. Job Postings
- `GET /api/v2/admin/job_postings` (search, status filter)
- `GET /api/v2/admin/job_postings/:id`
- `PUT /api/v2/admin/job_postings/:id/publish`
- `PUT /api/v2/admin/job_postings/:id/close`
- `PUT /api/v2/admin/job_postings/:id/archive`

### 8. Job Applications
- `GET /api/v2/admin/job_applications` (status, search filter)
- `GET /api/v2/admin/job_applications/:id`
- `PUT /api/v2/admin/job_applications/:id/update_status`
- `POST /api/v2/admin/job_applications/:id/schedule_interview`
- `POST /api/v2/admin/job_applications/:id/convert_to_employee`

### 9. Employee Agreements
- `GET /api/v2/admin/employee_agreements` (status, contract_status filter)
- `GET /api/v2/admin/employee_agreements/:id`

### 10. Service Agreements
- `GET /api/v2/admin/service_agreements` (status, contract_status filter)
- `GET /api/v2/admin/service_agreements/:id`

### 11. Time Off Requests
- `GET /api/v2/admin/time_off_requests` (status filter, default pending)
- `PUT /api/v2/admin/time_off_requests/:id/approve`
- `PUT /api/v2/admin/time_off_requests/:id/deny`

### 12. Holidays
- `GET /api/v2/admin/holidays` (year, country filter)

### 13. Personal Info Requests
- `GET /api/v2/admin/personal_info_requests` (status filter)
- `GET /api/v2/admin/personal_info_requests/:id`
- `POST /api/v2/admin/personal_info_requests/:id/approve`
- `POST /api/v2/admin/personal_info_requests/:id/reject`

### 14. Contact Requests
- `GET /api/v2/admin/contact_requests` (status, search filter)
- `PUT /api/v2/admin/contact_requests/:id` (status update)

### 15. Settings/Profile
- `GET /api/v2/auth/profile`
- `PUT /api/v2/auth/profile`

## Build Order
1. Core infrastructure (APIService, KeychainHelper, Colors, Models, Auth)
2. Login + ContentView + TabView
3. Dashboard
4. Employees (most used)
5. Employers
6. Invoices
7. Payroll
8. Hiring (Job Postings + Applications)
9. Agreements
10. Time Off
11. Personal Info Requests
12. Contact Requests
13. Holidays
14. Settings
15. Tests

## Testing Strategy
- Unit tests for all ViewModels (mock API responses)
- UI tests for login flow and main navigation
