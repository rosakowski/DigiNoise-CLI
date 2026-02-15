import Foundation

// MARK: - Noise Generator (Shared between CLI and MenuBar)
// Uses APIEndpoint from Personas.swift

// Menu Bar mode: set to false to prevent app from exiting after noise
public var noiseGeneratorShouldExit = true

public struct NoiseGenerator {
    
    public static func generate() async {
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
        
        // Filter endpoints by enabled categories (using persona's endpoints if set)
        let allEndpoints = config.currentPersona == .general 
            ? APIEndpoint.all 
            : config.currentPersona.defaultEndpoints
        
        let enabledEndpoints = allEndpoints.filter { endpoint in
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
    
    public static func scheduleNextRun(seconds: TimeInterval? = nil) {
        let interval = seconds ?? TimeInterval.random(in: 3600...21600) // 1-6 hours
        let nextRun = Date().addingTimeInterval(interval)
        
        Logger.log("Next run scheduled for: \(nextRun)")
        
        // Exit only for CLI/daemon mode - Menu Bar should keep running
        if noiseGeneratorShouldExit {
            exit(0)
        }
    }
    
    public static func isWithinActiveHours(config: Config) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        if config.startHour > config.endHour {
            return hour >= config.startHour || hour < config.endHour
        }
        return hour >= config.startHour && hour < config.endHour
    }
    
    public static func secondsUntilActiveHours(config: Config) -> TimeInterval {
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
    
    public static func secondsUntilTomorrow() -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let midnight = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: tomorrow) {
            return midnight.timeIntervalSince(now)
        }
        return 3600 * 24
    }
}
