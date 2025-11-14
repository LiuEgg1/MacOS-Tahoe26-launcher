import SwiftUI

@main
struct DesktopLauncherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .saveItem) { }
            
            CommandMenu("应用") {
                Button("刷新列表") {
                    // 通过NotificationCenter发送刷新命令
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshApplications"), object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
