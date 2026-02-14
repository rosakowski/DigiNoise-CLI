import Foundation
import ArgumentParser
import DigiNoiseShared

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
        
        // Filter endpoints by enabled categories
        let enabledEndpoints = APIEndpoint.all.filter { endpoint in
            switch endpoint.category {
            case .reference: return config.enabledCategories.reference
            case .weather: return config.enabledCategories.weather
            case .tech: return config.enabledCategories.tech
            case .news: return config.enabledCategories.news
            case .finance: return config.enabledCategories.finance
            case .science: return config.enabledCategories.science
            case .entertainment: return config.enabledCategories.entertainment
            case .lifestyle: return config.enabledCategories.lifestyle
            case .sports: return config.enabledCategories.sports
            case .recipes: return config.enabledCategories.recipes
            case .travel: return config.enabledCategories.travel
            }
        }
        
        guard !enabledEndpoints.isEmpty else {
            Logger.log("No enabled categories. Skipping.")
            scheduleNextRun()
            return
        }
        
        // Make the API call
        let endpoint = enabledEndpoints.randomElement()!
        Logger.log("Requesting: \(endpoint.description) (\(endpoint.category.rawValue))")
        
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
        subcommands: [Start.self, Stop.self, Status.self, ConfigCmd.self, Categories.self, Install.self, Uninstall.self, Run.self, Log.self, Daemon.self, PersonaCmd.self, List.self, SetPersona.self, Info.self]
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
        let enabledCount = [
            config.enabledCategories.reference,
            config.enabledCategories.weather,
            config.enabledCategories.tech,
            config.enabledCategories.news,
            config.enabledCategories.finance,
            config.enabledCategories.science,
            config.enabledCategories.entertainment,
            config.enabledCategories.lifestyle,
            config.enabledCategories.sports,
            config.enabledCategories.recipes,
            config.enabledCategories.travel
        ].filter { $0 }.count
        
        print("📊 DigiNoise Status")
        print("   State: \(config.isRunning ? "Running ✅" : "Stopped ⏹️")")
        print("   Today's requests: \(config.requestCount)/\(config.dailyLimit)")
        print("   Active hours: \(config.startHour):00-\(config.endHour):00")
        print("   Service installed: \(LaunchDManager.isInstalled() ? "Yes ✅" : "No ❌")")
        print("   Categories enabled: \(enabledCount)/11")
        print("")
        print("Run 'diginoise config' to see all category settings")
    }
}

struct ConfigCmd: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "config",
        abstract: "Configure settings",
        subcommands: [Categories.self]
    )
    
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
            printCurrentConfig(config)
        }
        
        config.save()
        
        if config.isRunning {
            print("")
            print("Note: Changes will take effect on next run")
        }
    }
    
    func printCurrentConfig(_ config: Config) {
        print("Current configuration:")
        print("   Daily limit: \(config.dailyLimit) requests")
        print("   Active hours: \(config.startHour):00-\(config.endHour):00")
        print("")
        print("Enabled categories:")
        print("   Reference (Wikipedia): \(config.enabledCategories.reference ? "✅" : "❌")")
        print("   Weather: \(config.enabledCategories.weather ? "✅" : "❌")")
        print("   Tech: \(config.enabledCategories.tech ? "✅" : "❌")")
        print("   News: \(config.enabledCategories.news ? "✅" : "❌")")
        print("   Finance: \(config.enabledCategories.finance ? "✅" : "❌")")
        print("   Science: \(config.enabledCategories.science ? "✅" : "❌")")
        print("   Entertainment: \(config.enabledCategories.entertainment ? "✅" : "❌")")
        print("   Lifestyle: \(config.enabledCategories.lifestyle ? "✅" : "❌")")
        print("   Sports: \(config.enabledCategories.sports ? "✅" : "❌")")
        print("   Recipes: \(config.enabledCategories.recipes ? "✅" : "❌")")
        print("   Travel: \(config.enabledCategories.travel ? "✅" : "❌")")
        print("")
        print("Usage:")
        print("   diginoise config --limit 5 --start 8 --end 22")
        print("   diginoise config categories --finance --sports")
        print("   diginoise config categories --no-finance --no-sports")
    }
}

struct Categories: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Toggle API categories")
    
    @Flag(name: .customLong("reference"), help: "Toggle Wikipedia") var reference: Bool = false
    @Flag(name: .customLong("no-reference"), help: "Disable Wikipedia") var noReference: Bool = false
    
    @Flag(name: .customLong("weather"), help: "Toggle weather APIs") var weather: Bool = false
    @Flag(name: .customLong("no-weather"), help: "Disable weather") var noWeather: Bool = false
    
    @Flag(name: .customLong("tech"), help: "Toggle tech APIs") var tech: Bool = false
    @Flag(name: .customLong("no-tech"), help: "Disable tech") var noTech: Bool = false
    
    @Flag(name: .customLong("news"), help: "Toggle news APIs") var news: Bool = false
    @Flag(name: .customLong("no-news"), help: "Disable news") var noNews: Bool = false
    
    @Flag(name: .customLong("finance"), help: "Toggle finance APIs") var finance: Bool = false
    @Flag(name: .customLong("no-finance"), help: "Disable finance") var noFinance: Bool = false
    
    @Flag(name: .customLong("science"), help: "Toggle science APIs") var science: Bool = false
    @Flag(name: .customLong("no-science"), help: "Disable science") var noScience: Bool = false
    
    @Flag(name: .customLong("entertainment"), help: "Toggle entertainment APIs") var entertainment: Bool = false
    @Flag(name: .customLong("no-entertainment"), help: "Disable entertainment") var noEntertainment: Bool = false
    
    @Flag(name: .customLong("lifestyle"), help: "Toggle lifestyle APIs") var lifestyle: Bool = false
    @Flag(name: .customLong("no-lifestyle"), help: "Disable lifestyle") var noLifestyle: Bool = false
    
    @Flag(name: .customLong("sports"), help: "Toggle sports APIs") var sports: Bool = false
    @Flag(name: .customLong("no-sports"), help: "Disable sports") var noSports: Bool = false
    
    @Flag(name: .customLong("recipes"), help: "Toggle recipe APIs") var recipes: Bool = false
    @Flag(name: .customLong("no-recipes"), help: "Disable recipes") var noRecipes: Bool = false
    
    @Flag(name: .customLong("travel"), help: "Toggle travel APIs") var travel: Bool = false
    @Flag(name: .customLong("no-travel"), help: "Disable travel") var noTravel: Bool = false
    
    func run() async throws {
        var config = Config.load()
        var changed = false
        
        if reference { config.enabledCategories.reference.toggle(); changed = true }
        if noReference { config.enabledCategories.reference = false; changed = true }
        
        if weather { config.enabledCategories.weather.toggle(); changed = true }
        if noWeather { config.enabledCategories.weather = false; changed = true }
        
        if tech { config.enabledCategories.tech.toggle(); changed = true }
        if noTech { config.enabledCategories.tech = false; changed = true }
        
        if news { config.enabledCategories.news.toggle(); changed = true }
        if noNews { config.enabledCategories.news = false; changed = true }
        
        if finance { config.enabledCategories.finance.toggle(); changed = true }
        if noFinance { config.enabledCategories.finance = false; changed = true }
        
        if science { config.enabledCategories.science.toggle(); changed = true }
        if noScience { config.enabledCategories.science = false; changed = true }
        
        if entertainment { config.enabledCategories.entertainment.toggle(); changed = true }
        if noEntertainment { config.enabledCategories.entertainment = false; changed = true }
        
        if lifestyle { config.enabledCategories.lifestyle.toggle(); changed = true }
        if noLifestyle { config.enabledCategories.lifestyle = false; changed = true }
        
        if sports { config.enabledCategories.sports.toggle(); changed = true }
        if noSports { config.enabledCategories.sports = false; changed = true }
        
        if recipes { config.enabledCategories.recipes.toggle(); changed = true }
        if noRecipes { config.enabledCategories.recipes = false; changed = true }
        
        if travel { config.enabledCategories.travel.toggle(); changed = true }
        if noTravel { config.enabledCategories.travel = false; changed = true }
        
        if changed {
            config.save()
            print("Category settings updated!")
        }
        
        print("")
        print("Enabled categories:")
        print("   Reference: \(config.enabledCategories.reference ? "✅" : "❌")")
        print("   Weather: \(config.enabledCategories.weather ? "✅" : "❌")")
        print("   Tech: \(config.enabledCategories.tech ? "✅" : "❌")")
        print("   News: \(config.enabledCategories.news ? "✅" : "❌")")
        print("   Finance: \(config.enabledCategories.finance ? "✅" : "❌")")
        print("   Science: \(config.enabledCategories.science ? "✅" : "❌")")
        print("   Entertainment: \(config.enabledCategories.entertainment ? "✅" : "❌")")
        print("   Lifestyle: \(config.enabledCategories.lifestyle ? "✅" : "❌")")
        print("   Sports: \(config.enabledCategories.sports ? "✅" : "❌")")
        print("   Recipes: \(config.enabledCategories.recipes ? "✅" : "❌")")
        print("   Travel: \(config.enabledCategories.travel ? "✅" : "❌")")
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
    static var configuration = CommandConfiguration(abstract: "Run one iteration (for testing)")
    
    func run() async throws {
        Logger.setup()
        await NoiseGenerator.generate()
    }
}

struct Log: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "View recent log entries")
    
    @Option(name: .shortAndLong, help: "Number of lines to show")
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
    static var configuration = CommandConfiguration(abstract: "Run daemon mode (called by launchd)")
    
    func run() async throws {
        Logger.setup()
        await NoiseGenerator.generate()
    }
}
