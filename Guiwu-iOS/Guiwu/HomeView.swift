import SwiftUI

@MainActor
struct HomeView: View {
    @Environment(ItemStore.self) private var store
    @State private var showingAdd = false
    @State private var selectedCategory: ItemCategory?

    private var visibleItems: [OwnedItem] {
        guard let selectedCategory else { return store.items }
        return store.items.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        CostBanner(
                            title: "拥有的日常成本",
                            amount: store.totalDailyCost(at: context.date),
                            subtitle: "\(store.items.count) 件好物相伴 · 总投入 \(Money.text(store.totalInvestment, digits: 0))",
                            addAction: { showingAdd = true }
                        )
                        .disabled(store.loadError != nil)
                        if let error = store.loadError {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("暂时无法读取物品", systemImage: "exclamationmark.triangle")
                                    .font(.headline).foregroundStyle(.orange)
                                Text(error).font(.footnote).foregroundStyle(.secondary)
                                Button("重试读取") { store.reload() }.buttonStyle(.bordered)
                            }.guiwuCard()
                        } else {
                            collectionHeader
                            categoryFilters
                            itemList(at: context.date)
                        }
                    }
                    .padding(20).padding(.bottom, 20)
                }.background(AppStyle.background)
            }
            .navigationTitle("归物")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Label("本机保存", systemImage: "lock.shield")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $showingAdd) { ItemFormView() }
        }
    }

    private var collectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 5) {
                Text("我的物品").font(.title2.bold())
                Text("好好使用，让每一次拥有更值得").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(visibleItems.count) 件").font(.subheadline.weight(.medium))
                .foregroundStyle(AppStyle.accent)
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryButton("全部", category: nil)
                ForEach(ItemCategory.allCases) { category in
                    categoryButton(category.rawValue, category: category)
                }
            }
        }
    }

    private func categoryButton(_ title: String, category: ItemCategory?) -> some View {
        let selected = selectedCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = category }
        } label: {
            Text(title).font(.subheadline.weight(.medium))
                .padding(.horizontal, 16).padding(.vertical, 11)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(selected ? AppStyle.accent : AppStyle.surface, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    @ViewBuilder
    private func itemList(at date: Date) -> some View {
        if visibleItems.isEmpty {
            ContentUnavailableView(
                store.items.isEmpty ? "让好物各有归处" : "这个分类还没有物品",
                systemImage: "shippingbox",
                description: Text(store.items.isEmpty ? "点击上方 +，记录第一件物品。" : "添加物品，或切换其他分类查看。")
            )
            .frame(maxWidth: .infinity).padding(.vertical, 24)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(visibleItems) { item in
                    NavigationLink {
                        ItemDetailView(itemID: item.id)
                    } label: {
                        ItemRow(item: item, date: date)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ItemRow: View {
    let item: OwnedItem
    let date: Date

    var body: some View {
        HStack(spacing: 14) {
            Text(item.emoji).font(.system(size: 30)).frame(width: 56, height: 56)
                .background(AppStyle.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 7) {
                Text(item.name).font(.headline).foregroundStyle(.primary).lineLimit(1)
                Text("\(item.category.rawValue) · 已拥有 \(item.ownedDays(at: date)) 天")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 7) {
                Text(Money.text(item.dailyCost(at: date)))
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .monospacedDigit().foregroundStyle(AppStyle.accent)
                Text("每天").font(.caption).foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right").font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary).accessibilityHidden(true)
        }
        .padding(16)
        .background(AppStyle.surface, in: RoundedRectangle(cornerRadius: 22))
    }
}
