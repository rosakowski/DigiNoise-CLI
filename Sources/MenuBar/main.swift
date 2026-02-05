import SwiftUI
import Combine

// MARK: - Shared Configuration
struct Config: Codable {
    var isRunning: Bool = false
    var dailyLimit: Int = 5
    var startHour: Int = 7
    var endHour: Int = 23
    var requestCount: Int = 0
    var lastResetDate: Date = Date()
    
    static let configPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/diginoise/config.json")
    
    static func load() -> Config {
        guard let data = try? Data(contentsOf: configPath),
              let config = try? JSONDecoder().decode(Config.self, from: data) else {
            return Config()
        }
        return config
    }
    
    func save() {
        try? FileManager.default.createDirectory(
            at: configPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: configPath)
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
        FileManager.default.fileExists(atPath: plistPath.path)
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
        statusItem = NSStatusBar.shared.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🌐"
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
            statusItem?.button?.title = "🟢"
        } else {
            statusItem?.button?.title = "🔴"
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
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            Divider()
            statusView
            Divider()
            activityView
            Divider()
            actionButtons
        }
        .padding()
        .frame(width: 300)
    }
    
    var headerView: some View {
        HStack {
            Text("DigiNoise")
                .font(.system(size: 18, weight: .bold))
            Spacer()
            Circle()
                .fill(appState.config.isRunning ? Color.green : Color.red)
                .frame(width: 10, height: 10)
        }
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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Section {
                    Stepper("Daily Limit: \(config.dailyLimit)", value: $config.dailyLimit, in: 1...50)
                    Stepper("Start Hour: \(config.startHour)", value: $config.startHour, in: 0...23)
                    Stepper("End Hour: \(config.endHour)", value: $config.endHour, in: 0...23)
                }
            }
            .frame(width: 250)
            
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
        .frame(width: 300, height: 250)
    }
}
