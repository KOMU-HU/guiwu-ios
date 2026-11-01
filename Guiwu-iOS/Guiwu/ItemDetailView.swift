import SwiftUI

@MainActor
struct ItemDetailView: View {
    @Environment(ItemStore.self) private var store
    let itemID: UUID
    @State private var showingEdit = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            ScrollView {
                if let item = store.item(withID: itemID) {
                    detailContent(item, at: context.date)
                } else {
                    ContentUnavailableView("未找到物品", systemImage: "shippingbox", description: Text("请返回首页查看其他物品。"))
                        .padding(.top, 60)
                }
            }.background(AppStyle.background)
        }
        .navigationTitle("物品详情").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") { showingEdit = true }.fontWeight(.semibold)
                    .disabled(store.item(withID: itemID) == nil)
            }
        }
        .sheet(isPresented: $showingEdit) {
            if let item = store.item(withID: itemID) { ItemFormView(item: item) }
        }
    }

    private func detailContent(_ item: OwnedItem, at date: Date) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 14) {
                Text(item.emoji).font(.system(size: 70)).frame(width: 132, height: 132)
                    .background(AppStyle.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 38))
                Text(item.name).font(.title.bold()).multilineTextAlignment(.center)
                Text(item.category.rawValue).font(.caption.weight(.semibold))
                    .foregroundStyle(AppStyle.accent).padding(.horizontal, 14).padding(.vertical, 7)
                    .background(AppStyle.accent.opacity(0.1), in: Capsule())
            }.frame(maxWidth: .infinity).padding(.top, 12)
            CostBanner(title: "这件物品的日均成本", amount: item.dailyCost(at: date), subtitle: "已陪伴你 \(item.ownedDays(at: date)) 天")
            VStack(spacing: 18) {
                LabeledContent("购买金额", value: Money.text(Decimal(item.purchasePrice), digits: 0))
                Divider()
                LabeledContent("购买日期", value: item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                Divider()
                LabeledContent("持有天数", value: "\(item.ownedDays(at: date)) 天")
            }.font(.subheadline).guiwuCard()
            VStack(alignment: .leading, spacing: 10) {
                Label("陪伴越久，每天越值", systemImage: "leaf.fill").font(.headline).foregroundStyle(AppStyle.accent)
                Text("日均成本 = 购买金额 ÷ 持有天数").font(.subheadline).foregroundStyle(.secondary)
                Text("购买当天计为第 1 天，金额四舍五入保留两位小数。").font(.caption).foregroundStyle(.secondary)
            }.guiwuCard()
        }.padding(20).padding(.bottom, 20)
    }
}
