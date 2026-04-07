import SwiftUI

struct HolidaysView: View {
    @StateObject private var vm = HolidaysViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Picker("Year", selection: $vm.selectedYear) {
                    ForEach((2024...2027), id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(.menu)
                .tint(.accent)

                Picker("Country", selection: $vm.countryFilter) {
                    ForEach(vm.countryOptions, id: \.self) { c in
                        Text(c == "all" ? "All Countries" : c).tag(c)
                    }
                }
                .pickerStyle(.menu)
                .tint(.accent)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: vm.selectedYear) { _ in Task { await vm.load() } }
            .onChange(of: vm.countryFilter) { _ in Task { await vm.load() } }

            ScrollView {
                if let error = vm.error {
                    ErrorBanner(message: error)
                }

                if vm.holidays.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "calendar", title: "No holidays found")
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.holidays) { holiday in
                            holidayRow(holiday)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Holidays")
        .brandNavBar()
        .refreshable { await vm.load() }
        .task { await vm.load() }
    }

    private func holidayRow(_ h: Holiday) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(formatDate(h.date))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
                if let dow = h.day_of_week {
                    Text(dow)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(width: 70, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(h.name ?? "Holiday")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    if let type = h.holiday_type {
                        Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    if let country = h.applicable_country {
                        Text(country)
                            .font(.caption2).bold()
                            .foregroundColor(.accent)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.accent.opacity(0.15))
                            .cornerRadius(3)
                    }
                }
            }
            Spacer()
            if h.is_weekend == true {
                Text("Weekend")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}
