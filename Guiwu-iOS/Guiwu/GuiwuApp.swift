import SwiftUI

@main
@MainActor
struct GuiwuApp: App {
    @State private var store = ItemStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .tint(AppStyle.accent)
        }
    }
}
