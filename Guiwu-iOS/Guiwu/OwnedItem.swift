import Foundation

enum ItemCategory: String, Codable, CaseIterable, Identifiable {
    case other = "其他"
    case digital = "数码"
    case appliance = "电器"
    case clothing = "衣物"
    case pet = "宠物用品"
    var id: String { rawValue }
}

struct OwnedItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var emoji: String
    var name: String
    var category: ItemCategory
    var purchasePrice: Int
    var purchaseDate: Date
    var createdAt: Date = .now

    func ownedDays(at date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: purchaseDate)
        let end = calendar.startOfDay(for: date)
        let difference = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(difference + 1, 1)
    }

    func dailyCost(at date: Date) -> Decimal {
        Decimal(purchasePrice) / Decimal(ownedDays(at: date))
    }
}

enum Money {
    static func text(_ amount: Decimal, digits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        formatter.roundingMode = .halfUp
        formatter.usesGroupingSeparator = true
        let fallback = digits == 0 ? "0" : "0.00"
        return "¥" + (formatter.string(from: NSDecimalNumber(decimal: amount)) ?? fallback)
    }
}
