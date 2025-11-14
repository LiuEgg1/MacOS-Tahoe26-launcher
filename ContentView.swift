import SwiftUI

struct ContentView: View {
    @StateObject private var appManager = ApplicationManager()
    @State private var columns: Int = 6
    @State private var iconSize: CGFloat = 100
    @State private var showingPreferences = false
    
    let spacing: CGFloat = 30
    
    var body: some View {
        ZStack {
            // 背景
            VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 搜索栏
                searchField
                
                // 应用网格
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(iconSize + 60), spacing: spacing), count: columns), spacing: spacing) {
                        ForEach(appManager.filteredApplications) { app in
                            ApplicationIconView(application: app, iconSize: iconSize)
                                .onTapGesture {
                                    appManager.launchApplication(app)
                                }
                                .contextMenu {
                                    Button("打开") {
                                        appManager.launchApplication(app)
                                    }
                                    Button("在Finder中显示") {
                                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: (app.path as NSString).deletingLastPathComponent)
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                // 控制栏
                controlBar
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            setupFullScreen()
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索应用...", text: $appManager.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 18))
            
            if !appManager.searchText.isEmpty {
                Button(action: {
                    appManager.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var controlBar: some View {
        HStack {
            Text("\(appManager.filteredApplications.count) 个应用")
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 图标大小调节
            HStack {
                Text("小")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Slider(value: $iconSize, in: 80...150, step: 10)
                    .frame(width: 150)
                
                Text("大")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            // 列数调节
            HStack {
                Button(action: { decreaseColumns() }) {
                    Image(systemName: "minus.circle")
                }
                
                Text("\(columns) 列")
                    .frame(width: 60)
                
                Button(action: { increaseColumns() }) {
                    Image(systemName: "plus.circle")
                }
            }
            
            Spacer()
            
            Button("刷新") {
                appManager.loadApplications()
            }
            
            Button("设置") {
                showingPreferences.toggle()
            }
            .popover(isPresented: $showingPreferences) {
                PreferencesView()
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
    
    private func setupFullScreen() {
        if let window = NSApplication.shared.windows.first {
            window.toggleFullScreen(nil)
            window.collectionBehavior = [.fullScreenPrimary]
        }
    }
    
    private func increaseColumns() {
        columns = min(columns + 1, 8)
    }
    
    private func decreaseColumns() {
        columns = max(columns - 1, 3)
    }
}

struct ApplicationIconView: View {
    let application: Application
    let iconSize: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(15)
                    .overlay(
                        Image(systemName: "app")
                            .font(.system(size: iconSize * 0.4))
                            .foregroundColor(.white)
                    )
            }
            
            Text(application.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: iconSize + 40)
        }
        .padding(10)
        .contentShape(Rectangle())
    }
}

// 毛玻璃效果视图
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
