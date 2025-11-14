import SwiftUI
import AppKit

struct Application: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let bundleIdentifier: String
    var icon: NSImage?
    
    static func == (lhs: Application, rhs: Application) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class ApplicationManager: ObservableObject {
    @Published var applications: [Application] = []
    @Published var searchText: String = ""
    
    var filteredApplications: [Application] {
        if searchText.isEmpty {
            return applications
        } else {
            return applications.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    init() {
        loadApplications()
    }
    
    func loadApplications() {
        applications.removeAll()
        
        // 搜索常见应用目录
        let appDirectories = [
            "/Applications",
            "/System/Applications",
            NSHomeDirectory() + "/Applications"
        ]
        
        for directory in appDirectories {
            loadApplications(from: directory)
        }
        
        // 从Launch Services获取更多应用
        loadApplicationsFromLaunchServices()
    }
    
    private func loadApplications(from directory: String) {
        let fileManager = FileManager.default
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: directory) else {
            return
        }
        
        for item in contents where item.hasSuffix(".app") {
            let appPath = "\(directory)/\(item)"
            let appName = (item as NSString).deletingPathExtension
            let appBundleIdentifier = getBundleIdentifier(for: appPath)
            
            var application = Application(
                name: appName,
                path: appPath,
                bundleIdentifier: appBundleIdentifier ?? "unknown"
            )
            
            application.icon = getIcon(for: appPath)
            applications.append(application)
        }
    }
    
    private func loadApplicationsFromLaunchServices() {
        // 使用Launch Services获取所有注册的应用
        guard let apps = LSCopyApplicationURLsForBundleIdentifier("com.apple" as CFString, nil)?.takeRetainedValue() as? [URL] else {
            return
        }
        
        for appURL in apps {
            let appPath = appURL.path
            let appName = appURL.deletingPathExtension().lastPathComponent
            
            if !applications.contains(where: { $0.path == appPath }) {
                var application = Application(
                    name: appName,
                    path: appPath,
                    bundleIdentifier: getBundleIdentifier(for: appPath) ?? "unknown"
                )
                
                application.icon = getIcon(for: appPath)
                applications.append(application)
            }
        }
    }
    
    private func getBundleIdentifier(for appPath: String) -> String? {
        guard let bundle = Bundle(path: appPath) else {
            return nil
        }
        return bundle.bundleIdentifier
    }
    
    private func getIcon(for appPath: String) -> NSImage? {
        guard let bundle = Bundle(path: appPath) else {
            return NSImage(named: NSImage.applicationIconName)
        }
        
        if let iconFile = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String {
            if let iconPath = bundle.pathForImageResource(iconFile) {
                return NSImage(contentsOfFile: iconPath)
            }
        }
        
        // 如果没有找到图标文件，尝试从bundle加载
        if let icon = NSWorkspace.shared.icon(forFile: appPath) as NSImage? {
            return icon
        }
        
        return NSImage(named: NSImage.applicationIconName)
    }
    
    func launchApplication(_ application: Application) {
        let workspace = NSWorkspace.shared
        
        do {
            try workspace.launchApplication(at: URL(fileURLWithPath: application.path))
        } catch {
            print("Failed to launch application: \(error)")
            
            // 备用启动方式
            workspace.open(URL(fileURLWithPath: application.path))
        }
    }
}
