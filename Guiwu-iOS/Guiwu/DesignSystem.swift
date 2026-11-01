import SwiftUI

enum AppStyle {
    static let accent = Color(red: 0.02, green: 0.55, blue: 0.43)
    static let lime = Color(red: 0.80, green: 0.98, blue: 0.52)
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let heroGradient = LinearGradient(
        colors: [Color(red: 0.04, green: 0.27, blue: 0.25), Color(red: 0.02, green: 0.46, blue: 0.37)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    func guiwuCard() -> some View {
        self.padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppStyle.surface, in: RoundedRectangle(cornerRadius: 24))
    }
}

struct CostBanner: View {
    let title: String
    let amount: Decimal
    let subtitle: String
    var addAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label(title, systemImage: "sparkles")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer(minLength: 12)
                if let addAction {
                    Button(action: addAction) {
                        Image(systemName: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color(red: 0.04, green: 0.27, blue: 0.25))
                            .frame(width: 44, height: 44)
                            .background(AppStyle.lime, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("添加物品")
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(Money.text(amount))
                    .font(.system(size: 43, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppStyle.lime)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .contentTransition(.numericText())
                Text("元 / 天").font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppStyle.heroGradient, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: AppStyle.accent.opacity(0.16), radius: 16, x: 0, y: 8)
    }
}
