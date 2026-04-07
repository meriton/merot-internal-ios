import SwiftUI

struct EmployerInvoicesView: View {
    @State private var invoices: [EmployerInvoice] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var selectedFilter = "all"

    private let filters = ["all", "draft", "sent", "paid", "overdue"]

    private var filtered: [EmployerInvoice] {
        if selectedFilter == "all" { return invoices }
        if selectedFilter == "overdue" {
            return invoices.filter { $0.overdue == true }
        }
        return invoices.filter { ($0.status ?? "").lowercased() == selectedFilter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter.capitalized)
                                    .font(.caption).fontWeight(.medium)
                                    .foregroundColor(selectedFilter == filter ? .brand : .white.opacity(0.6))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(selectedFilter == filter ? Color.accent : Color.white.opacity(0.08))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                List {
                    if let error {
                        ErrorBanner(message: error)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    if filtered.isEmpty && !isLoading {
                        EmptyStateView(icon: "doc.text", title: "No invoices found")
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    ForEach(filtered) { inv in
                        NavigationLink(value: inv.id) {
                            invoiceRow(inv)
                        }
                        .listRowBackground(Color.white.opacity(0.06))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Invoices")
            .brandNavBar()
            .refreshable { await loadInvoices() }
            .task { await loadInvoices() }
            .navigationDestination(for: Int.self) { id in
                EmployerInvoiceDetailView(invoiceId: id)
            }
            .overlay {
                if isLoading && invoices.isEmpty {
                    LoadingView()
                }
            }
        }
    }

    private func invoiceRow(_ inv: EmployerInvoice) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(inv.invoice_number ?? "Invoice")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                StatusBadge(status: inv.status ?? "draft")
            }
            if let period = inv.billing_period_display {
                Text(period)
                    .font(.caption2).foregroundColor(.white.opacity(0.4))
            }
            HStack {
                Text(formatMoney(inv.total_amount, currency: inv.currency))
                    .font(.headline).foregroundColor(.accent)
                Spacer()
                if let due = inv.due_date {
                    Text("Due: \(formatDate(due))")
                        .font(.caption2).foregroundColor(inv.overdue == true ? .red : .white.opacity(0.3))
                }
            }
            if inv.overdue == true, let days = inv.days_overdue, days > 0 {
                Text("\(days) days overdue")
                    .font(.caption2).fontWeight(.semibold).foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadInvoices() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerInvoicesResponse = try await APIService.shared.request("GET", "/employers/invoices", query: ["per_page": "100"])
            invoices = res.data?.invoices ?? []
        } catch {
            self.error = "Failed to load invoices"
            #if DEBUG
            print("[EmployerInvoices] \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Invoice Detail

struct EmployerInvoiceDetailView: View {
    let invoiceId: Int
    @State private var invoice: EmployerInvoiceDetail?
    @State private var isLoading = true
    @State private var error: String?
    @State private var isDownloading = false
    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    var body: some View {
        ScrollView {
            if isLoading && invoice == nil {
                LoadingView()
            } else if let error {
                VStack(spacing: 16) {
                    ErrorBanner(message: error)
                    Button("Retry") { Task { await load() } }
                        .foregroundColor(.accent)
                }
                .padding(.top, 40)
            } else if let inv = invoice {
                VStack(spacing: 12) {
                    // Header
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(inv.invoice_number ?? "Invoice")
                                    .font(.title3).bold().foregroundColor(.white)
                                Spacer()
                                StatusBadge(status: inv.status ?? "draft")
                            }
                            if let period = inv.billing_period_display {
                                Text(period)
                                    .font(.caption).foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }

                    // Amounts
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Summary").font(.headline).foregroundColor(.white.opacity(0.7))
                            HStack {
                                Text("Total")
                                    .font(.subheadline).foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Text(formatMoney(inv.total_amount, currency: inv.currency))
                                    .font(.title2).bold().foregroundColor(.accent)
                            }
                            Divider().overlay(Color.white.opacity(0.1))
                            InfoRow(icon: "doc.text", label: "Subtotal", value: formatMoney(inv.subtotal, currency: inv.currency))
                            if inv.tax_amount?.value ?? 0 > 0 {
                                InfoRow(icon: "percent", label: "Tax", value: formatMoney(inv.tax_amount, currency: inv.currency))
                            }
                            if inv.discount_amount?.value ?? 0 > 0 {
                                InfoRow(icon: "tag", label: "Discount", value: "-\(formatMoney(inv.discount_amount, currency: inv.currency))")
                            }
                            if inv.late_fee?.value ?? 0 > 0 {
                                InfoRow(icon: "exclamationmark.triangle", label: "Late Fee", value: formatMoney(inv.late_fee, currency: inv.currency))
                            }
                        }
                    }

                    // Dates
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Dates").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "calendar", label: "Issue Date", value: formatDate(inv.issue_date))
                            InfoRow(icon: "calendar.badge.exclamationmark", label: "Due Date", value: formatDate(inv.due_date))
                            if let employees = inv.total_employees {
                                InfoRow(icon: "person.3", label: "Employees", value: "\(employees)")
                            }
                        }
                    }

                    // Line Items
                    if let items = inv.line_items, !items.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Line Items").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(items) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.description ?? "Item")
                                                .font(.subheadline).foregroundColor(.white)
                                            Spacer()
                                            Text(formatMoney(item.total_price, currency: inv.currency))
                                                .font(.subheadline).bold().foregroundColor(.accent)
                                        }
                                        HStack(spacing: 8) {
                                            if let empName = item.employee_name {
                                                Text(empName)
                                                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                                            }
                                            if let cat = item.service_category {
                                                Text(cat.replacingOccurrences(of: "_", with: " ").capitalized)
                                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                                            }
                                        }
                                        if let qty = item.quantity, let price = item.unit_price {
                                            Text("\(Int(qty.value)) x \(formatMoney(price, currency: inv.currency))")
                                                .font(.caption2).foregroundColor(.white.opacity(0.25))
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    if item.id != items.last?.id {
                                        Divider().overlay(Color.white.opacity(0.1))
                                    }
                                }
                            }
                        }
                    }

                    // Download PDF Button
                    Button {
                        Task { await downloadPDF() }
                    } label: {
                        HStack {
                            if isDownloading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "arrow.down.doc.fill")
                                Text("Download PDF")
                            }
                        }
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .cornerRadius(10)
                    }
                    .disabled(isDownloading)
                    .padding(.top, 4)
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Invoice")
        .brandNavBar()
        .refreshable { await load() }
        .task { await load() }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerInvoiceDetailResponse = try await APIService.shared.request("GET", "/employers/invoices/\(invoiceId)")
            invoice = res.data?.invoice
        } catch {
            self.error = "Failed to load invoice"
            #if DEBUG
            print("[EmployerInvDetail] \(error)")
            #endif
        }
        isLoading = false
    }

    private func downloadPDF() async {
        isDownloading = true
        do {
            let data = try await APIService.shared.requestData("GET", "/employers/invoices/\(invoiceId)/download_pdf")
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "invoice-\(invoice?.invoice_number ?? "\(invoiceId)").pdf"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try data.write(to: fileURL)
            pdfURL = fileURL
            showShareSheet = true
        } catch {
            self.error = "Failed to download PDF"
            #if DEBUG
            print("[EmployerPDF] \(error)")
            #endif
        }
        isDownloading = false
    }
}

