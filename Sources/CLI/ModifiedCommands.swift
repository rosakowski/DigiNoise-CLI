import Foundation
import ArgumentParser
import DigiNoiseShared

// MARK: - Modified CLI Commands with Persona Support
extension DigiNoiseCLI {
    static var configuration = CommandConfiguration(
        commandName: "diginoise",
        abstract: "Generate digital noise to obfuscate your online footprint",
        subcommands: [Start.self, Stop.self, Status.self, ConfigCmd.self, Install.self, Uninstall.self, Run.self, Log.self, PersonaCmd.self]
    )
}

extension NoiseGenerator {
    static func generateForPersona(_ persona: Persona) async {
        var config = Config.load()
        
        // Use persona-specific endpoints
        let endpoints = persona.defaultEndpoints
        
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
        
        // Make the API call from persona endpoints
        let endpoint = endpoints.randomElement()!
        Logger.log("[\(persona.rawValue)] Requesting: \(endpoint.description) (\(endpoint.category.rawValue))")
        
        guard let url = URL(string: endpoint.url) else {
            Logger.log("Invalid URL, skipping")
            scheduleNextRun()
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("DigiNoise-CLI/1.0 (Persona:\(persona.rawValue))", forHTTPHeaderField: "User-Agent")
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
        
        scheduleNextRun()
    }
}