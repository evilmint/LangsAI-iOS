import ComposableArchitecture
import SwiftUI

@MainActor
final class AppContainer {
    let store = Store(initialState: Main.State()) {
        Main()
    }
}

@main
struct Application: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainView(store: container.store)
                .frame(minWidth: 600, minHeight: 300)
                .toolbar {
                    ToolbarItemGroup {
                        HStack {
                            Button {
                                container.store.send(.next)
                            } label: {
                                Label("Refresh", systemSymbol: .arrowClockwise)
                                    .foregroundStyle(.neutral200)
                                    .font(.title3)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button {
                                container.store.send(.openPreferences)
                            } label: {
                                Label("Preferences", systemSymbol: .gearshape)
                                    .foregroundStyle(.neutral200)
                                    .font(.title3)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
        }.commands {
            CommandGroup(before: .appInfo) {
                Button("Preferences") {
                    container.store.send(.openPreferences)
                }
                .keyboardShortcut("p", modifiers: .command)
            }
        }
        .defaultSize(width: 500, height: 800)
        .windowResizability(.contentSize)
    }
}
