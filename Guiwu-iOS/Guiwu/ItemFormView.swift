import SwiftUI

@MainActor
struct ItemFormView: View {
    @Environment(ItemStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    private let originalItem: OwnedItem?
    @State private var emoji: String
    @State private var name: String
    @State private var category: ItemCategory
    @State private var priceText: String
    @State private var purchaseDate: Date
    @State private var saveError = ""
    @State private var showingSaveError = false
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case emoji, name, price }
    private let suggestedEmoji = ["📦", "📱", "💻", "🎧", "📷", "⌚️", "👕", "👟", "🛋️", "🐱", "🐶", "🎮"]

    init(item: OwnedItem? = nil) {
        originalItem = item
        _emoji = State(initialValue: item?.emoji ?? "📦")
        _name = State(initialValue: item?.name ?? "")
        _category = State(initialValue: item?.category ?? .other)
        _priceText = State(initialValue: item.map { String($0.purchasePrice) } ?? "")
        _purchaseDate = State(initialValue: item?.purchaseDate ?? .now)
    }

    private var cleanName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanEmoji: String { emoji.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var parsedPrice: Int? {
        let text = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text.allSatisfy({ "0123456789".contains($0) }) else { return nil }
        return Int(text)
    }
    private var isValidEmoji: Bool {
        cleanEmoji.count == 1 && cleanEmoji.unicodeScalars.contains {
            ($0.properties.isEmoji && $0.value > 0x7F) || $0.value == 0x20E3
        }
    }
    private var validationMessage: String? {
        if !isValidEmoji { return "请选择或输入一个 Emoji 作为图标。" }
        if cleanName.isEmpty { return "请填写物品名称。" }
        if cleanName.count > 40 { return "物品名称最多 40 个字。" }
        guard let price = parsedPrice, (0...999_999_999).contains(price) else {
            return "请输入 0～999999999 之间的整数金额。"
        }
        let calendar = Calendar.current
        if calendar.startOfDay(for: purchaseDate) > calendar.startOfDay(for: .now) {
            return "购买日期不能晚于今天。"
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 16) {
                        Text(cleanEmoji.isEmpty ? "📦" : cleanEmoji).font(.system(size: 58))
                            .frame(width: 106, height: 106)
                            .background(AppStyle.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 30))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(suggestedEmoji, id: \.self) { value in
                                    Button {
                                        focusedField = nil
                                        emoji = value
                                    } label: {
                                        Text(value).font(.title2).frame(width: 44, height: 44)
                                            .background(
                                                emoji == value ? AppStyle.accent.opacity(0.15) : Color.clear,
                                                in: RoundedRectangle(cornerRadius: 12)
                                            )
                                    }.buttonStyle(.plain).accessibilityLabel("选择图标 \(value)")
                                }
                            }
                        }
                    }.frame(maxWidth: .infinity).padding(.vertical, 12)
                    HStack {
                        Text("自定义 Emoji")
                        Spacer()
                        TextField("📦", text: $emoji).multilineTextAlignment(.trailing)
                            .frame(width: 100).focused($focusedField, equals: .emoji)
                    }
                } header: { Text("为它选个图标") }
                Section("基本信息") {
                    TextField("物品名称，例如：降噪耳机", text: $name).focused($focusedField, equals: .name)
                    Picker("分类", selection: $category) {
                        ForEach(ItemCategory.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section {
                    HStack {
                        Text("购买金额")
                        Spacer()
                        Text("¥").foregroundStyle(.secondary)
                        TextField("0", text: $priceText).keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing).frame(minWidth: 80, maxWidth: 160)
                            .focused($focusedField, equals: .price)
                    }
                    DatePicker("购买日期", selection: $purchaseDate, in: ...Date.now, displayedComponents: .date)
                } header: { Text("购买信息") } footer: {
                    Text(validationMessage ?? "购买当天计为第 1 天，日均成本会随持有时间自动变化。")
                }
                if validationMessage == nil, let price = parsedPrice {
                    Section("成本预览") {
                        LabeledContent("当前日均成本", value: Money.text(Decimal(price) / Decimal(previewDays)))
                            .foregroundStyle(AppStyle.accent)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(originalItem == nil ? "添加物品" : "编辑物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save).fontWeight(.semibold).disabled(validationMessage != nil)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") { focusedField = nil }
                }
            }
            .alert("保存失败", isPresented: $showingSaveError) {
                Button("知道了", role: .cancel) {}
            } message: { Text(saveError) }
        }
    }

    private var previewDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: purchaseDate)
        let today = calendar.startOfDay(for: .now)
        return max((calendar.dateComponents([.day], from: start, to: today).day ?? 0) + 1, 1)
    }

    private func save() {
        guard validationMessage == nil, let price = parsedPrice else { return }
        let item = OwnedItem(
            id: originalItem?.id ?? UUID(), emoji: cleanEmoji, name: cleanName,
            category: category, purchasePrice: price,
            purchaseDate: Calendar.current.startOfDay(for: purchaseDate),
            createdAt: originalItem?.createdAt ?? .now
        )
        do {
            try store.upsert(item)
            dismiss()
        } catch {
            saveError = error.localizedDescription
            showingSaveError = true
        }
    }
}
