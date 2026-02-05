import Foundation
import ArgumentParser

// MARK: - Configuration
struct Config: Codable {
    var isRunning: Bool = false
    var dailyLimit: Int = 5
    var startHour: Int = 7
    var endHour: Int = 23
    var requestCount: Int = 0
    var lastResetDate: Date = Date()
    
    static let defaultConfigPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/diginoise/config.json")
    
    static func load() -> Config {
        guard let data = try? Data(contentsOf: defaultConfigPath),
              let config = try? JSONDecoder().decode(Config.self, from: data) else {
            return Config()
        }
        return config
    }
    
    func save() {
        try? FileManager.default.createDirectory(
            at: defaultConfigPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: defaultConfigPath)
        }
    }
    
    mutating func checkAndResetDaily() {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            requestCount = 0
            lastResetDate = Date()
            save()
        }
    }
    
    var canRunToday: Bool {
        checkAndResetDaily()
        return requestCount < dailyLimit
    }
}

// MARK: - Logger
enum Logger {
    static let logFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".local/share/diginoise/diginoise.log")
    
    static func setup() {
        try? FileManager.default.createDirectory(
            at: logFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    static func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] \(message)\n"
        print(line, terminator: "")
        
        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile.path) {
                if let handle = try? FileHandle(forWritingTo: logFile) {
                    _ = try? handle.seekToEnd()
                    try? handle.write(contentsOf: data)
                    try? handle.close()
                }
            } else {
                try? data.write(to: logFile)
            }
        }
    }
}

// MARK: - API Endpoints
struct APIEndpoint {
    let url: String
    let description: String
    
    static let all: [APIEndpoint] = [
        APIEndpoint(url: "https://en.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "English Wikipedia"),
        APIEndpoint(url: "https://es.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "Spanish Wikipedia"),
        APIEndpoint(url: "https://fr.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "French Wikipedia"),
        APIEndpoint(url: "https://de.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "German Wikipedia"),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=51.5074&longitude=-0.1278&current=temperature_2m", 
                   description: "London Weather"),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=35.6762&longitude=139.6503&current=temperature_2m", 
                   description: "Tokyo Weather"),
        APIEndpoint(url: "https://hacker-news.firebaseio.com/v0/topstories.json?limitToFirst=1", 
                   description: "Hacker News"),
        APIEndpoint(url: "https://api.quotable.io/random", 
                   description: "Random Quote"),
    ]
}

// MARK: - Noise Generator
struct NoiseGenerator {
    static func generate() async {
        var config = Config.load()
        
        guard config.isRunning else {
            Logger.log("Daemon is stopped. Exiting.")
            return
        }
        
        config.checkAndResetDaily()
        
        guard config.canRunToday else {
            Logger.log("Daily limit (\(config.dailyLimit)) reached. Scheduling next check for tomorrow.")
            scheduleNextRun(seconds: secondsUntilTomorrow())
            return
        }
        
        guard isWithinActiveHours(config: config) else {
            Logger.log("Outside active hours (\(config.startHour):00-\(config.endHour):00). Waiting...")
            scheduleNextRun(seconds: secondsUntilActiveHours(config: config))
            return
        }
        
        // Make the API call
        let endpoint = APIEndpoint.all.randomElement()!
        Logger.log("Requesting: \(endpoint.description)")
        
        guard let url = URL(string: endpoint.url) else {
            Logger.log("Invalid URL, skipping")
            scheduleNextRun()
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("DigiNoise-CLI/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 30
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                Logger.log("Success: \(endpoint.description)")
                config.requestCount += 1
                config.save()
            } else {
                Logger.log("Failed: HTTP \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            }
        } catch {
            Logger.log("Error: \(error.localizedDescription)")
        }
        
        // Schedule next run
        scheduleNextRun()
    }
    
    static func scheduleNextRun(seconds: TimeInterval? = nil) {
        let interval = seconds ?? TimeInterval.random(in: 3600...21600) // 1-6 hours
        let nextRun = Date().addingTimeInterval(interval)
        
        Logger.log("Next run scheduled for: \(nextRun)")
        
        // Exit and let launchd reschedule us
        exit(0)
    }
    
    static func isWithinActiveHours(config: Config) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        if config.startHour > config.endHour {
            return hour >= config.startHour || hour < config.endHour
        }
        return hour >= config.startHour && hour < config.endHour
    }
    
    static func secondsUntilActiveHours(config: Config) -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        var targetHour = config.startHour
        if config.startHour > config.endHour {
            // Overnight schedule
            if currentHour >= config.startHour || currentHour < config.endHour {
                return 0 // Already in active hours
            }
            targetHour = currentHour < config.endHour ? 0 : config.startHour
        } else {
            if currentHour >= config.startHour && currentHour < config.endHour {
                return 0
            }
            if currentHour >= config.endHour {
                // After end time, wait until tomorrow's start
                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                   let nextStart = calendar.date(bySettingHour: config.startHour, minute: 0, second: 0, of: tomorrow) {
                    return nextStart.timeIntervalSince(now)
                }
            }
        }
        
        if let nextStart = calendar.date(bySettingHour: targetHour, minute: 0, second: 0, of: now) {
            return nextStart.timeIntervalSince(now)
        }
        
        return 3600 // Default 1 hour
    }
    
    static func secondsUntilTomorrow() -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let midnight = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: tomorrow) {
            return midnight.timeIntervalSince(now)
        }
        return 3600 * 24
    }
}

// MARK: - LaunchD Manager
struct LaunchDManager {
    static let plistName = "com.diginoise.daemon.plist"
    static let launchdDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents")
    static let plistPath = launchdDir.appendingPathComponent(plistName)
    
    static func install() {
        try? FileManager.default.createDirectory(at: launchdDir, withIntermediateDirectories: true)
        
        let binaryPath = ProcessInfo.processInfo.arguments[0]
        
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.diginoise.daemon</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(binaryPath)</string>
                <string>daemon</string>
            </array>
            <key>StartInterval</key>
            <integer>900</integer>
            <key>RunAtLoad</key>
            <true/>
            <key>StandardOutPath</key>
            <string>/dev/null</string>
            <key>StandardErrorPath</key>
            <string>/dev/null</string>
        </dict>
        </plist>
        """
        
        try? plist.write(to: plistPath, atomically: true, encoding: .utf8)
        
        // Load the service
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", plistPath.path]
        task.launch()
        task.waitUntilExit()
        
        Logger.log("Installed launchd service")
    }
    
    static func uninstall() {
        // Unload the service
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["unload", plistPath.path]
        task.launch()
        task.waitUntilExit()
        
        try? FileManager.default.removeItem(at: plistPath)
        Logger.log("Uninstalled launchd service")
    }
    
    static func isInstalled() -> Bool {
        FileManager.default.fileExists(atPath: plistPath.path)
    }
    
    static func restart() {
        uninstall()
        install()
    }
}

// MARK: - CLI Commands
@main
struct DigiNoiseCLI: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "diginoise",
        abstract: "Generate digital noise to obfuscate your online footprint",
        subcommands: [Start.self, Stop.self, Status.self, Config.self, Install.self, Uninstall.self, Run.self, Log.self]
    )
}

struct Start: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Start the noise generator")
    
    func run() async throws {
        Logger.setup()
        
        guard LaunchDManager.isInstalled() else {
            print("DigiNoise is not installed as a service.")
            print("Run 'diginoise install' first.")
            throw ExitCode.failure
        }
        
        var config = Config.load()
        config.isRunning = true
        config.save()
        
        // Start the service
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["start", "com.diginoise.daemon"]
        task.launch()
        task.waitUntilExit()
        
        print("✅ DigiNoise started")
        print("   Daily limit: \(config.dailyLimit) requests")
        print("   Active hours: \(config.startHour):00-\(config.endHour):00")
        print("   Run 'diginoise status' to check progress")
    }
}

struct Stop: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Stop the noise generator")
    
    func run() async throws {
        Logger.setup()
        
        var config = Config.load()
        config.isRunning = false
        config.save()
        
        print("⏹️  DigiNoise stopped")
        print("   Made \(config.requestCount)/\(config.dailyLimit) requests today")
    }
}

struct Status: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Show current status")
    
    func run() async throws {
        let config = Config.load()
        
        print("📊 DigiNoise Status")
        print("   State: \(config.isRunning ? "Running ✅" : "Stopped ⏹️")")
        print("   Today's requests: \(config.requestCount)/\(config.dailyLimit)")
        print("   Active hours: \(config.startHour):00-\(config.endHour):00")
        print("   Service installed: \(LaunchDManager.isInstalled() ? "Yes ✅" : "No ❌")")
    }
}

struct Config: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Configure settings")
    
    @Option(name: .shortAndLong, help: "Daily request limit (0-50)")
    var limit: Int?
    
    @Option(name: .shortAndLong, help: "Start hour (0-23)")
    var start: Int?
    
    @Option(name: .shortAndLong, help: "End hour (0-23)")
    var end: Int?
    
    func validate() throws {
        if let limit = limit, (limit < 0 || limit > 50) {
            throw ValidationError("Limit must be between 0 and 50")
        }
        if let start = start, (start < 0 || start > 23) {
            throw ValidationError("Start hour must be between 0 and 23")
        }
        if let end = end, (end < 0 || end > 23) {
            throw ValidationError("End hour must be between 0 and 23")
        }
    }
    
    func run() async throws {
        var config = Config.load()
        
        if let limit = limit {
            config.dailyLimit = limit
            print("Daily limit set to \(limit)")
        }
        
        if let start = start {
            config.startHour = start
            print("Start hour set to \(start):00")
        }
        
        if let end = end {
            config.endHour = end
            print("End hour set to \(end):00")
        }
        
        if limit == nil && start == nil && end == nil {
            print("Current configuration:")
            print("   Daily limit: \(config.dailyLimit) requests")
            print("   Active hours: \(config.startHour):00-\(config.endHour):00")
            print("")
            print("Usage: diginoise config --limit 5 --start 8 --end 22")
        }
        
        config.save()
        
        if config.isRunning {
            print("")
            print("Note: Changes will take effect on next run")
        }
    }
}

struct Install: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Install as system service")
    
    func run() async throws {
        Logger.setup()
        LaunchDManager.install()
        print("✅ DigiNoise installed as system service")
        print("   Run 'diginoise start' to begin generating noise")
    }
}

struct Uninstall: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Uninstall system service")
    
    func run() async throws {
        Logger.setup()
        LaunchDManager.uninstall()
        print("❌ DigiNoise uninstalled")
    }
}

struct Run: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Run one iteration (for testing)", shouldBeHidden: true)
    
    func run() async throws {
        Logger.setup()
        await NoiseGenerator.generate()
    }
}

struct Log: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "View recent log entries")
    
    @Option(name: .shortAndLong, help: "Number of lines to show", transform: Int.init)
    var lines: Int = 20
    
    func run() async throws {
        guard FileManager.default.fileExists(atPath: Logger.logFile.path) else {
            print("No log file found")
            return
        }
        
        guard let content = try? String(contentsOf: Logger.logFile) else {
            print("Could not read log file")
            return
        }
        
        let allLines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let lastLines = allLines.suffix(lines)
        
        print("Recent activity (last \(lines) lines):")
        print("")
        for line in lastLines {
            print(line)
        }
    }
}

struct Daemon: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Run daemon mode (called by launchd)", shouldBeHidden: true)
    
    func run() async throws {
        Logger.setup()
        await NoiseGenerator.generate()
    }
}
