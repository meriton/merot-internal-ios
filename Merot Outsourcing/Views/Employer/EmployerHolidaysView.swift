import SwiftUI

struct EmployerHolidaysView: View {
    @State private var holidays: [EmployerHoliday] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        List {
            if let error {
                ErrorBanner(message: error)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            if holidays.isEmpty && !isLoading {
                EmptyStateView(icon: "calendar", title: "No upcoming holidays")
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            ForEach(holidays) { holiday in
                HStack(spacing: 12) {
                    VStack {
                        Text(monthAbbr(holiday.date))
                            .font(.caption2).fontWeight(.bold)
                            .foregroundColor(.accent)
                        Text(dayNumber(holiday.date))
                            .font(.title3).bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 50)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(holiday.name ?? "Holiday")
                            .font(.subheadline).foregroundColor(.white)
                        HStack(spacing: 6) {
                            if let dow = holiday.day_of_week {
                                Text(dow)
                                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                            }
                            if let country = holiday.country {
                                Text(country.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                            }
                        }
                        if let type = holiday.holiday_type {
                            Text(type.capitalized)
                                .font(.caption2).foregroundColor(.accent.opacity(0.7))
                        }
                    }
                    Spacer()
                    if holiday.is_weekend == true {
                        Text("Weekend")
                            .font(.caption2).foregroundColor(.white.opacity(0.3))
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.white.opacity(0.06))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Holidays")
        .brandNavBar()
        .refreshable { await loadHolidays() }
        .task { await loadHolidays() }
        .overlay {
            if isLoading && holidays.isEmpty {
                LoadingView()
            }
        }
    }

    private func loadHolidays() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerHolidaysResponse = try await APIService.shared.request("GET", "/employers/holidays", query: ["per_page": "100"])
            holidays = res.data?.holidays ?? []
        } catch {
            self.error = "Failed to load holidays"
            #if DEBUG
            print("[EmployerHolidays] \(error)")
            #endif
        }
        isLoading = false
    }

    private func monthAbbr(_ dateStr: String?) -> String {
        guard let d = dateStr, d.count >= 7 else { return "" }
        let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        let parts = d.prefix(10).split(separator: "-")
        guard parts.count >= 2, let m = Int(parts[1]), m >= 1, m <= 12 else { return "" }
        return months[m - 1]
    }

    private func dayNumber(_ dateStr: String?) -> String {
        guard let d = dateStr, d.count >= 10 else { return "" }
        let parts = d.prefix(10).split(separator: "-")
        guard parts.count >= 3 else { return "" }
        return String(Int(parts[2]) ?? 0)
    }
}
