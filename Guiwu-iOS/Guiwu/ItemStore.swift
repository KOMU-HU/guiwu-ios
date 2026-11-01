import Foundation
import Observation

@MainActor
@Observable
final class ItemStore {
    private(set) var items: [OwnedItem] = []
    private(set) var loadError: String?
    @ObservationIgnored private var fileURL: URL?

    init() { reload() }

    var totalInvestment: Decimal {
        items.reduce(Decimal.zero) { $0 + Decimal($1.purchasePrice) }
    }

    func totalDailyCost(at date: Date) -> Decimal {
        items.reduce(Decimal.zero) { $0 + $1.dailyCost(at: date) }
    }

    func item(withID id: UUID) -> OwnedItem? {
        items.first { $0.id == id }
    }

    func reload() {
        do {
            let manager = FileManager.default
            let support = try manager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let directory = support.appendingPathComponent("Guiwu", isDirectory: true)
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent("items.json")
            let loaded: [OwnedItem]
            if manager.fileExists(atPath: url.path) {
                loaded = try JSONDecoder().decode([OwnedItem].self, from: Data(contentsOf: url))
            } else {
                loaded = []
            }
            guard Set(loaded.map(\.id)).count == loaded.count,
                  loaded.allSatisfy({
                      !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      && !$0.emoji.isEmpty
                      && (0...999_999_999).contains($0.purchasePrice)
                      && $0.purchaseDate.timeIntervalSinceReferenceDate.isFinite
                  }) else { throw StorageError.invalidData }
            items = loaded.sorted { $0.createdAt > $1.createdAt }
            fileURL = url
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    func upsert(_ item: OwnedItem) throws {
        guard loadError == nil, let fileURL else { throw StorageError.unavailable }
        var updated = items
        if let index = updated.firstIndex(where: { $0.id == item.id }) {
            updated[index] = item
        } else {
            updated.insert(item, at: 0)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(updated).write(to: fileURL, options: .atomic)
        items = updated
    }

    private enum StorageError: LocalizedError {
        case invalidData, unavailable
        var errorDescription: String? {
            switch self {
            case .invalidData: return "本地记录格式异常，暂时无法读取。"
            case .unavailable: return "本地记录暂时不可用，请返回首页重试读取。"
            }
        }
    }
}
