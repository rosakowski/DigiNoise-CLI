import Foundation

// MARK: - Noise Generator (Shared between CLI and MenuBar)
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
    
    public static func scheduleNextRun(seconds: TimeInterval? = nil) {
        let interval = seconds ?? TimeInterval.random(in: 3600...21600) // 1-6 hours
        let nextRun = Date().addingTimeInterval(interval)
        
        Logger.log("Next run scheduled for: \(nextRun)")
        
        // Exit and let launchd reschedule us
        exit(0)
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

// MARK: - API Endpoint Category
public enum EndpointCategory: String, CaseIterable, Codable {
    case reference
    case weather
    case tech
    case news
    case finance
    case science
    case entertainment
    case lifestyle
    case sports
    case recipes
    case travel
}

// MARK: - API Endpoint
public struct APIEndpoint: Codable {
    public let url: String
    public let description: String
    public let category: EndpointCategory
    
    public init(url: String, description: String, category: EndpointCategory) {
        self.url = url
        self.description = description
        self.category = category
    }
    
    public static var all: [APIEndpoint] {
        [
            // Reference (Wikipedia)
            APIEndpoint(url: "https://en.wikipedia.org/api/rest_v1/page/random/summary", description: "Wikipedia EN", category: .reference),
            APIEndpoint(url: "https://wikiless.org/api.php?action=query&list=random&rnnamespace=0&rnlimit=1&format=json", description: "WikiLess Random", category: .reference),
            
            // Weather
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=40.7128&longitude=-74.0060&current=temperature_2m,weather_code,wind_speed_10m", description: "NYC Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=51.5074&longitude=-0.1278&current=temperature_2m,weather_code,wind_speed_10m", description: "London Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=35.6762&longitude=139.6503&current=temperature_2m,weather_code,wind_speed_10m", description: "Tokyo Weather", category: .weather),
            
            // Tech
            APIEndpoint(url: "https://www.reddit.com/r/technology.json?limit=1", description: "Reddit Tech", category: .tech),
            APIEndpoint(url: "https://www.reddit.com/r/programming.json?limit=1", description: "Reddit Programming", category: .tech),
            APIEndpoint(url: "https://www.reddit.com/r/ArtificialIntelligence.json?limit=1", description: "Reddit AI", category: .tech),
            APIEndpoint(url: "https://news.ycombinator.com/rss", description: "Hacker News", category: .tech),
            
            // News
            APIEndpoint(url: "https://www.reddit.com/r/worldnews.json?limit=1", description: "Reddit World News", category: .news),
            APIEndpoint(url: "https://www.reddit.com/r/news.json?limit=1", description: "Reddit News", category: .news),
            APIEndpoint(url: "https://www.bbc.com/news/rss.xml", description: "BBC News", category: .news),
            
            // Finance
            APIEndpoint(url: "https://www.reddit.com/r/investing.json?limit=1", description: "Reddit Investing", category: .finance),
            APIEndpoint(url: "https://www.reddit.com/r/wallstreetbets.json?limit=1", description: "Reddit WSB", category: .finance),
            APIEndpoint(url: "https://www.reddit.com/r/Bitcoin.json?limit=1", description: "Reddit Bitcoin", category: .finance),
            
            // Science
            APIEndpoint(url: "https://www.reddit.com/r/science.json?limit=1", description: "Reddit Science", category: .science),
            APIEndpoint(url: "https://www.reddit.com/r/space.json?limit=1", description: "Reddit Space", category: .science),
            APIEndpoint(url: "https://www.nasa.gov/rss/dyn/breaking_news.rss", description: "NASA News", category: .science),
            
            // Entertainment
            APIEndpoint(url: "https://www.reddit.com/r/movies.json?limit=1", description: "Reddit Movies", category: .entertainment),
            APIEndpoint(url: "https://www.reddit.com/r/television.json?limit=1", description: "Reddit TV", category: .entertainment),
            APIEndpoint(url: "https://www.reddit.com/r/music.json?limit=1", description: "Reddit Music", category: .entertainment),
            
            // Lifestyle
            APIEndpoint(url: "https://www.reddit.com/r/lifestyle.json?limit=1", description: "Reddit Lifestyle", category: .lifestyle),
            APIEndpoint(url: "https://www.reddit.com/r/health.json?limit=1", description: "Reddit Health", category: .lifestyle),
            APIEndpoint(url: "https://www.reddit.com/r/fitness.json?limit=1", description: "Reddit Fitness", category: .lifestyle),
            
            // Sports
            APIEndpoint(url: "https://www.reddit.com/r/sports.json?limit=1", description: "Reddit Sports", category: .sports),
            APIEndpoint(url: "https://www.reddit.com/r/nfl.json?limit=1", description: "Reddit NFL", category: .sports),
            APIEndpoint(url: "https://www.reddit.com/r/nba.json?limit=1", description: "Reddit NBA", category: .sports),
            APIEndpoint(url: "https://www.reddit.com/r/soccer.json?limit=1", description: "Reddit Soccer", category: .sports),
            
            // Recipes
            APIEndpoint(url: "https://www.reddit.com/r/recipes.json?limit=1", description: "Reddit Recipes", category: .recipes),
            APIEndpoint(url: "https://www.reddit.com/r/food.json?limit=1", description: "Reddit Food", category: .recipes),
            
            // Travel
            APIEndpoint(url: "https://www.reddit.com/r/travel.json?limit=1", description: "Reddit Travel", category: .travel),
            APIEndpoint(url: "https://www.reddit.com/r/solotravel.json?limit=1", description: "Reddit Solo Travel", category: .travel),
            APIEndpoint(url: "https://www.reddit.com/r/geography.json?limit=1", description: "Reddit Geography", category: .travel),
        ]
    }
}
