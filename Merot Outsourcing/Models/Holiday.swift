import Foundation

struct Holiday: Codable, Identifiable {
    let id: Int
    let name: String?
    let date: String?
    let holiday_type: String?
    let applicable_group: String?
    let applicable_country: String?
    let is_weekend: Bool?
    let day_of_week: String?
    let created_at: String?
    let updated_at: String?

    var dateValue: Date? {
        guard let d = date, d.count >= 10 else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: String(d.prefix(10)))
    }
}

struct HolidaysListResponse: Codable {
    let data: HolidaysListData?
    let success: Bool?
}

struct HolidaysListData: Codable {
    let holidays: [Holiday]
    let meta: PaginationMeta?
}
