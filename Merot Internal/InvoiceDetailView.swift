import SwiftUI
import QuickLook

struct InvoiceDetailView: View {
    let invoice: Invoice
    @StateObject private var apiService = APIService()
    @State private var detailedInvoice: DetailedInvoice?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isDownloading = false
    @State private var pdfURL: URL?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage) {
                            Task {
                                await loadInvoiceDetails()
                            }
                        }
                    } else {
                        // Always show invoice data - use detailed if available, otherwise basic
                        VStack(alignment: .leading, spacing: 20) {
                            if let detailedInvoice = detailedInvoice {
                                // Header Section
                                InvoiceHeaderCard(invoice: detailedInvoice)
                                
                                // Summary Section
                                InvoiceSummaryCard(invoice: detailedInvoice)
                                
                                // Line Items Section
                                if !detailedInvoice.lineItems.isEmpty {
                                    LineItemsCard(lineItems: detailedInvoice.lineItems)
                                }
                                
                                // Payment Information
                                PaymentInfoCard(invoice: detailedInvoice)
                                
                                // Total Summary at the bottom
                                InvoiceTotalCard(invoice: detailedInvoice)
                            } else {
                                // Show basic invoice data immediately while loading details
                                BasicInvoiceHeaderCard(invoice: invoice)
                                
                                if isLoading {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Loading details...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                }
                                
                                // Basic Total Summary at the bottom
                                BasicInvoiceTotalCard(invoice: invoice)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Invoice Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await downloadPDF()
                        }
                    }) {
                        HStack {
                            if isDownloading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.down.doc")
                            }
                            Text("PDF")
                        }
                    }
                    .disabled(isDownloading)
                }
            }
        }
        .onAppear {
            Task {
                await loadInvoiceDetails()
            }
        }
        .quickLookPreview($pdfURL)
    }
    
    private func loadInvoiceDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            detailedInvoice = try await apiService.getInvoiceDetails(id: invoice.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func downloadPDF() async {
        isDownloading = true
        
        do {
            let pdfData = try await apiService.downloadInvoicePDF(id: invoice.id)
            
            // Save PDF to temporary file for QuickLook
            // Use same naming format as server: EmployerName_invoice_{invoice_number}.pdf
            let employerName = detailedInvoice?.employer?.name ?? "Company"
            let fileName = "\(employerName)_invoice_\(invoice.invoiceNumber).pdf"
                .replacingOccurrences(of: " ", with: "_") // Replace spaces with underscores
                .replacingOccurrences(of: "/", with: "-") // Replace slashes to avoid path issues
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)
            
            try pdfData.write(to: tempURL)
            
            // Open with QuickLook
            DispatchQueue.main.async {
                self.pdfURL = tempURL
            }
        } catch {
            errorMessage = "Failed to download PDF: \(error.localizedDescription)"
        }
        
        isDownloading = false
    }
    
}


struct BasicInvoiceHeaderCard: View {
    let invoice: Invoice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Invoice")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(invoice.invoiceNumber)
                        .font(.title3)
                        .foregroundColor(.merotBlue)
                }
                
                Spacer()
                
                InvoiceStatusBadge(status: invoice.status, isOverdue: invoice.overdue ?? false)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let employer = invoice.employer {
                    DetailRow(label: "Company", value: employer.name)
                }
                DetailRow(label: "Issue Date", value: formatDate(invoice.issueDate))
                DetailRow(label: "Due Date", value: formatDate(invoice.dueDate))
                if let billingPeriod = invoice.billingPeriodDisplay {
                    DetailRow(label: "Billing Period", value: billingPeriod)
                }
            }
            
            if invoice.overdue == true {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("This invoice is \(invoice.daysOverdue ?? 0) days overdue")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct InvoiceHeaderCard: View {
    let invoice: DetailedInvoice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Invoice")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(invoice.invoiceNumber)
                        .font(.title3)
                        .foregroundColor(.merotBlue)
                }
                
                Spacer()
                
                InvoiceStatusBadge(status: invoice.status, isOverdue: invoice.overdue ?? false)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let employer = invoice.employer {
                    DetailRow(label: "Company", value: employer.name)
                }
                DetailRow(label: "Issue Date", value: formatDate(invoice.issueDate))
                DetailRow(label: "Due Date", value: formatDate(invoice.dueDate))
                if let billingPeriod = invoice.billingPeriodDisplay {
                    DetailRow(label: "Billing Period", value: billingPeriod)
                }
            }
            
            if invoice.overdue == true {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("This invoice is \(invoice.daysOverdue ?? 0) days overdue")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct InvoiceSummaryCard: View {
    let invoice: DetailedInvoice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                SummaryRow(label: "Subtotal", amount: invoice.subtotal ?? 0.0)
                
                if let discountAmount = invoice.discountAmount, discountAmount > 0 {
                    SummaryRow(label: "Discount", amount: -discountAmount, isDiscount: true)
                }
                
                if (invoice.taxAmount ?? 0.0) > 0 {
                    SummaryRow(label: "Tax", amount: invoice.taxAmount ?? 0.0)
                }
                
                if let lateFee = invoice.lateFee, lateFee > 0 {
                    SummaryRow(label: "Late Fee", amount: lateFee, isLateFee: true)
                }
                
                Divider()
                
                SummaryRow(label: "Total", amount: invoice.totalAmount, isTotal: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct LineItemsCard: View {
    let lineItems: [InvoiceLineItem]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(lineItems, id: \.id) { item in
                    LineItemRow(item: item)
                    if item.id != lineItems.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct PaymentInfoCard: View {
    let invoice: DetailedInvoice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(label: "Total Employees", value: "\(invoice.totalEmployees ?? 0)")
                
                if let payrollFee = invoice.payrollProcessingFee, payrollFee > 0 {
                    DetailRow(label: "Payroll Processing Fee", value: String(format: "$%.2f", payrollFee))
                }
                
                if let hrFee = invoice.hrServicesFee, hrFee > 0 {
                    DetailRow(label: "HR Services Fee", value: String(format: "$%.2f", hrFee))
                }
                
                if let benefitsFee = invoice.benefitsAdministrationFee, benefitsFee > 0 {
                    DetailRow(label: "Benefits Administration Fee", value: String(format: "$%.2f", benefitsFee))
                }
                
                DetailRow(label: "Currency", value: invoice.currency)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct SummaryRow: View {
    let label: String
    let amount: Double
    var isDiscount: Bool = false
    var isLateFee: Bool = false
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .semibold : .regular)
                .foregroundColor(isTotal ? .primary : .secondary)
            
            Spacer()
            
            Text(String(format: "$%.2f", amount))
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .semibold : .medium)
                .foregroundColor(
                    isDiscount ? .green :
                    isLateFee ? .red :
                    isTotal ? .primary : .secondary
                )
        }
    }
}

struct LineItemRow: View {
    let item: InvoiceLineItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "$%.2f", item.totalPrice))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Qty: \(item.quantity) × $\(String(format: "%.2f", item.unitPrice))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let employeeName = item.employeeName {
                    Text(employeeName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


struct InvoiceTotalCard: View {
    let invoice: DetailedInvoice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice Total")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.merotBlue)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "$%.2f", invoice.subtotal ?? 0.0))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if (invoice.taxAmount ?? 0.0) > 0 {
                    HStack {
                        Text("Tax")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "$%.2f", invoice.taxAmount ?? 0.0))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                if (invoice.discountAmount ?? 0) > 0 {
                    HStack {
                        Text("Discount")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "-$%.2f", invoice.discountAmount ?? 0))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
                
                if (invoice.lateFee ?? 0) > 0 {
                    HStack {
                        Text("Late Fee")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "$%.2f", invoice.lateFee ?? 0))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total Amount")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text(String(format: "$%.2f", invoice.totalAmount))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.merotBlue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct BasicInvoiceTotalCard: View {
    let invoice: Invoice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice Total")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.merotBlue)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "$%.2f", invoice.subtotal ?? 0.0))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if (invoice.taxAmount ?? 0.0) > 0 {
                    HStack {
                        Text("Tax")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "$%.2f", invoice.taxAmount ?? 0.0))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total Amount")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text(String(format: "$%.2f", invoice.totalAmount))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.merotBlue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    InvoiceDetailView(invoice: Invoice(
        id: 1,
        invoiceNumber: "INV-2025-001",
        status: "sent",
        issueDate: "2025-07-01T00:00:00Z",
        dueDate: "2025-07-15T00:00:00Z",
        totalAmount: 1500.00,
        subtotal: 1350.00,
        taxAmount: 150.00,
        discountAmount: 0.0,
        lateFee: 0.0,
        currency: "USD",
        billingPeriodStart: "2025-06-01",
        billingPeriodEnd: "2025-06-30",
        billingPeriodDisplay: "June 2025",
        totalEmployees: 5,
        payrollProcessingFee: 125.0,
        hrServicesFee: 100.0,
        benefitsAdministrationFee: 50.0,
        overdue: false,
        daysOverdue: 0,
        createdAt: "2025-07-01T00:00:00Z",
        updatedAt: "2025-07-01T00:00:00Z"
    ))
}