import SwiftUI
import Combine
import DigiNoiseShared

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Category Settings
struct CategorySettings: Codable {
    var reference: Bool = true
    var weather: Bool = true
    var tech: Bool = true
    var news: Bool = true
    var finance: Bool = true
    var science: Bool = true
    var entertainment: Bool = true
    var lifestyle: Bool = true
    var sports: Bool = true
    var recipes: Bool = true
    var travel: Bool = true
}

// MARK: - Shared Configuration
struct Config: Codable {
    var isRunning: Bool = false
    var dailyLimit: Int = 5
    var startHour: Int = 7
    var endHour: Int = 23
    var requestCount: Int = 0
    var lastResetDate: Date = Date()
    var enabledCategories: CategorySettings = CategorySettings()
    var currentPersona: Persona = .general
    
    static let configPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/diginoise/config.json")
    
    static func load() -> Config {
        guard let data = try? Data(contentsOf: Config.configPath),
              let config = try? JSONDecoder().decode(Config.self, from: data) else {
            return Config()
        }
        return config
    }
    
    func save() {
        try? FileManager.default.createDirectory(
            at: Config.configPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: Config.configPath)
        }
    }
}

// MARK: - Log Reader
struct LogReader {
    static let logPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".local/share/diginoise/diginoise.log")
    
    static func recentEntries(count: Int = 10) -> [String] {
        guard let content = try? String(contentsOf: logPath) else { return [] }
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return Array(lines.suffix(count))
    }
}

// MARK: - LaunchD Helper
struct LaunchDHelper {
    static let plistPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents/com.diginoise.daemon.plist")
    
    static func isInstalled() -> Bool {
        // Check if plist exists OR if the service is running
        if FileManager.default.fileExists(atPath: plistPath.path) {
            return true
        }
        // Also check if service is running via launchctl
        return isRunning()
    }
    
    static func isRunning() -> Bool {
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["list", "com.diginoise.daemon"]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus == 0
    }
    
    static func start() {
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["start", "com.diginoise.daemon"]
        task.launch()
        task.waitUntilExit()
    }
    
    static func stop() {
        var config = Config.load()
        config.isRunning = false
        config.save()
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var config = Config.load()
    @Published var recentLogs: [String] = []
    @Published var isServiceInstalled = false
    
    private var timer: Timer?
    
    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.refresh()
        }
    }
    
    func refresh() {
        config = Config.load()
        recentLogs = LogReader.recentEntries(count: 8)
        isServiceInstalled = LaunchDHelper.isInstalled()
    }
    
    func toggleRunning() {
        var newConfig = config
        newConfig.isRunning.toggle()
        newConfig.save()
        
        if newConfig.isRunning {
            LaunchDHelper.start()
        }
        
        refresh()
    }
    
    func openLogFile() {
        NSWorkspace.shared.open(LogReader.logPath)
    }
    
    func openConfigFile() {
        NSWorkspace.shared.open(Config.configPath)
    }
}

// MARK: - Menu Bar App
@main
struct DigiNoiseMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var appState = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📡"
        statusItem?.button?.action = #selector(togglePopover)
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView().environmentObject(appState))
        
        updateMenuIcon()
        
        // Watch for config changes
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateMenuIcon()
        }
    }
    
    func updateMenuIcon() {
        let config = Config.load()
        if config.isRunning {
            statusItem?.button?.title = "📡🟢"  // Signal + running indicator
        } else {
            statusItem?.button?.title = "📡🔴"  // Signal + stopped indicator
        }
    }
    
    @objc func togglePopover() {
        guard let statusItem = statusItem, let popover = popover else { return }
        
        appState.refresh()
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

// MARK: - Menu Bar View
struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingSettings = false
    
    private let primaryGradient = LinearGradient(
        colors: [Color(red: 0.39, green: 0.4, blue: 0.95), Color(red: 0.55, green: 0.36, blue: 0.96)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            VStack(spacing: 4) {
                HStack {
                    Text("📡")
                        .font(.system(size: 28))
                    Text("DigiNoise")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                HStack(spacing: 6) {
                    Circle()
                        .fill(appState.config.isRunning ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(appState.config.isRunning ? "Generating Noise" : "Stopped")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(primaryGradient)
            
            // Content
            VStack(spacing: 16) {
                // Persona selection
                PersonaSelectionView(selectedPersona: Binding(
                    get: { appState.config.currentPersona },
                    set: { newPersona in
                        var config = Config.load()
                        config.currentPersona = newPersona
                        config.save()
                        appState.refresh()
                    }
                ))
                    .padding(.top, 12)
                
                Divider()
                statusView
                Divider()
                activityView
                Divider()
                actionButtons
            }
            .padding()
        }
        .frame(width: 320)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    var statusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Status:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(appState.config.isRunning ? "Running" : "Stopped")
                    .fontWeight(.medium)
                    .foregroundColor(appState.config.isRunning ? .green : .red)
            }
            
            HStack {
                Text("Today's Requests:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(appState.config.requestCount)/\(appState.config.dailyLimit)")
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Active Hours:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(appState.config.startHour):00-\(appState.config.endHour):00")
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Categories:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(enabledCategoriesCount)/11")
                    .fontWeight(.medium)
            }
            
            if !appState.isServiceInstalled {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Service not installed")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    var enabledCategoriesCount: Int {
        let cats = appState.config.enabledCategories
        return [
            cats.reference, cats.weather, cats.tech, cats.news,
            cats.finance, cats.science, cats.entertainment,
            cats.lifestyle, cats.sports, cats.recipes, cats.travel
        ].filter { $0 }.count
    }
    
    var activityView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if appState.recentLogs.isEmpty {
                Text("No activity yet")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(appState.recentLogs, id: \.self) { log in
                            Text(log)
                                .font(.system(size: 10, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
                .frame(height: 80)
            }
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 10) {
            Button(action: { appState.toggleRunning() }) {
                HStack {
                    Image(systemName: appState.config.isRunning ? "stop.fill" : "play.fill")
                    Text(appState.config.isRunning ? "Stop" : "Start")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.config.isRunning ? .red : .green)
            
            HStack(spacing: 12) {
                Button("Settings") {
                    showingSettings = true
                }
                .buttonStyle(.bordered)
                
                Button("View Log") {
                    appState.openLogFile()
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @State private var config = Config.load()
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Picker("Tab", selection: $selectedTab) {
                Text("General").tag(0)
                Text("Categories").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if selectedTab == 0 {
                generalSettings
            } else {
                categoriesSettings
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                
                Button("Save") {
                    config.save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 320, height: selectedTab == 0 ? 220 : 400)
    }
    
    var generalSettings: some View {
        Form {
            Stepper("Daily Limit: \(config.dailyLimit)", value: $config.dailyLimit, in: 1...50)
            Stepper("Start Hour: \(config.startHour)", value: $config.startHour, in: 0...23)
            Stepper("End Hour: \(config.endHour)", value: $config.endHour, in: 0...23)
        }
        .frame(width: 280)
    }
    
    var categoriesSettings: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enabled Categories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                CategoryToggle(title: "Reference (Wikipedia)", isOn: $config.enabledCategories.reference)
                CategoryToggle(title: "Weather", isOn: $config.enabledCategories.weather)
                CategoryToggle(title: "Tech", isOn: $config.enabledCategories.tech)
                CategoryToggle(title: "News", isOn: $config.enabledCategories.news)
                CategoryToggle(title: "Finance", isOn: $config.enabledCategories.finance)
                CategoryToggle(title: "Science", isOn: $config.enabledCategories.science)
                CategoryToggle(title: "Entertainment", isOn: $config.enabledCategories.entertainment)
                CategoryToggle(title: "Lifestyle", isOn: $config.enabledCategories.lifestyle)
                CategoryToggle(title: "Sports", isOn: $config.enabledCategories.sports)
                CategoryToggle(title: "Recipes", isOn: $config.enabledCategories.recipes)
                CategoryToggle(title: "Travel", isOn: $config.enabledCategories.travel)
            }
            .padding(.horizontal)
        }
        .frame(width: 280)
    }
}

struct CategoryToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .toggleStyle(.switch)
    }
}
