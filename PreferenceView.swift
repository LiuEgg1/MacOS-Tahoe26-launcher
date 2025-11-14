import SwiftUI

struct PreferencesView: View {
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("showHiddenApps") private var showHiddenApps = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("设置")
                .font(.headline)
            
            Toggle("自动刷新应用列表", isOn: $autoRefresh)
            Toggle("显示隐藏的应用", isOn: $showHiddenApps)
            
            Divider()
            
            Button("手动刷新应用缓存") {
                refreshApplicationCache()
            }
            
            Spacer()
        }
        .frame(width: 250, height: 200)
        .padding()
    }
    
    private func refreshApplicationCache() {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["-KILL", "Finder"]
        
        do {
            try task.run()
        } catch {
            print("Failed to refresh cache: \(error)")
        }
    }
}
