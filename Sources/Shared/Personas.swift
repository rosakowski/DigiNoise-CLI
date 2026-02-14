import Foundation

// MARK: - Persona System
public enum Persona: String, CaseIterable, Codable {
    case general = "General"
    case koreanGymnast = "Korean Gymnast"
    case travelingEuro = "The Traveling Euro"
    case techBro = "Silicon Valley Tech Bro"
    case fitnessEnthusiast = "Fitness Enthusiast"
    case foodie = "Foodie Explorer"
    case financialAnalyst = "Financial Analyst"
    case sportsFan = "Sports Fan"
    case digitalNomad = "Digital Nomad"
    case student = "University Student"
    
    public var description: String {
        switch self {
        case .general:
            return "Balanced digital footprint across multiple categories"
        case .koreanGymnast:
            return "Korean athlete interested in gymnastics, K-pop, and Korean culture"
        case .travelingEuro:
            return "European professional working remotely while traveling by train"
        case .techBro:
            return "Tech professional interested in startups, crypto, and Silicon Valley news"
        case .fitnessEnthusiast:
            return "Health-conscious individual into fitness, nutrition, and wellness"
        case .foodie:
            return "Culinary explorer interested in recipes, restaurants, and food culture"
        case .financialAnalyst:
            return "Finance professional tracking markets, crypto, and economic news"
        case .sportsFan:
            return "Sports enthusiast following multiple leagues and teams"
        case .digitalNomad:
            return "Remote worker traveling globally, interested in geography and culture"
        case .student:
            return "University student with academic interests and campus life"
        }
    }
    
    public var defaultEndpoints: [APIEndpoint] {
        switch self {
        case .general:
            return APIEndpoint.all
            
        case .koreanGymnast:
            return [
                // Korean Wikipedia
                APIEndpoint(url: "https://ko.wikipedia.org/api/rest_v1/page/random/summary", 
                           description: "Korean Wikipedia", category: .reference),
                
                // Korean weather
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=37.5665&longitude=126.9780&current=temperature_2m", 
                           description: "Seoul Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=35.1796&longitude=129.0756&current=temperature_2m", 
                           description: "Busan Weather", category: .weather),
                
                // Korean news sources
                APIEndpoint(url: "https://www.reddit.com/r/kpop.json?limit=1", 
                           description: "K-Pop News", category: .entertainment),
                APIEndpoint(url: "https://www.reddit.com/r/korea.json?limit=1", 
                           description: "Korea Subreddit", category: .news),
                
                // Sports - gymnastics focus
                APIEndpoint(url: "https://www.reddit.com/r/Gymnastics.json?limit=1", 
                           description: "Gymnastics Reddit", category: .sports),
                
                // Korean entertainment
                APIEndpoint(url: "https://api.themoviedb.org/3/discover/movie?api_key=demo&region=KR&language=ko", 
                           description: "Korean Movies", category: .entertainment),
            ]
            
        case .travelingEuro:
            return [
                // European Wikipedia languages
                APIEndpoint(url: "https://de.wikipedia.org/api/rest_v1/page/random/summary", 
                           description: "German Wikipedia", category: .reference),
                APIEndpoint(url: "https://fr.wikipedia.org/api/rest_v1/page/random/summary", 
                           description: "French Wikipedia", category: .reference),
                APIEndpoint(url: "https://it.wikipedia.org/api/rest_v1/page/random/summary", 
                           description: "Italian Wikipedia", category: .reference),
                APIEndpoint(url: "https://es.wikipedia.org/api/rest_v1/page/random/summary", 
                           description: "Spanish Wikipedia", category: .reference),
                
                // Major European cities weather
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=52.5200&longitude=13.4050&current=temperature_2m", 
                           description: "Berlin Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=48.8566&longitude=2.3522&current=temperature_2m", 
                           description: "Paris Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=41.9028&longitude=12.4964&current=temperature_2m", 
                           description: "Rome Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=40.4168&longitude=-3.7038&current=temperature_2m", 
                           description: "Madrid Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=55.7558&longitude=37.6173&current=temperature_2m", 
                           description: "Moscow Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=47.4979&longitude=19.0402&current=temperature_2m", 
                           description: "Budapest Weather", category: .weather),
                
                // European train travel APIs
                APIEndpoint(url: "https://api.deutschebahn.com/freeplan/v1/location/berlin", 
                           description: "DB Train Stations", category: .travel),
                APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/EUR", 
                           description: "EUR Exchange Rates", category: .travel),
                
                // European business news
                APIEndpoint(url: "https://www.reddit.com/r/europe.json?limit=1", 
                           description: "Europe News", category: .news),
                APIEndpoint(url: "https://www.reddit.com/r/AskEurope.json?limit=1", 
                           description: "Ask Europe", category: .news),
                
                // European time zones
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/Europe/Berlin", 
                           description: "Berlin Time", category: .travel),
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/Europe/Paris", 
                           description: "Paris Time", category: .travel),
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/Europe/Rome", 
                           description: "Rome Time", category: .travel),
            ]
            
        case .techBro:
            return [
                // Tech news
                APIEndpoint(url: "https://hacker-news.firebaseio.com/v0/topstories.json?limitToFirst=1", 
                           description: "Hacker News", category: .tech),
                APIEndpoint(url: "https://api.github.com/events?per_page=1", 
                           description: "GitHub Activity", category: .tech),
                
                // Crypto/finance focus
                APIEndpoint(url: "https://api.coindesk.com/v1/bpi/currentprice.json", 
                           description: "Bitcoin Price", category: .finance),
                APIEndpoint(url: "https://api.coinbase.com/v2/exchange-rates?currency=BTC", 
                           description: "Crypto Rates", category: .finance),
                APIEndpoint(url: "https://api.coinbase.com/v2/exchange-rates?currency=ETH", 
                           description: "Ethereum Rates", category: .finance),
                
                // Silicon Valley weather
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=37.4419&longitude=-122.1430&current=temperature_2m", 
                           description: "Palo Alto Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=37.7749&longitude=-122.4194&current=temperature_2m", 
                           description: "San Francisco Weather", category: .weather),
                
                // Tech subreddits
                APIEndpoint(url: "https://www.reddit.com/r/technology.json?limit=1", 
                           description: "Technology News", category: .tech),
                APIEndpoint(url: "https://www.reddit.com/r/programming.json?limit=1", 
                           description: "Programming News", category: .tech),
                APIEndpoint(url: "https://www.reddit.com/r/startups.json?limit=1", 
                           description: "Startup News", category: .tech),
            ]
            
        case .fitnessEnthusiast:
            return [
                // Fitness subreddits
                APIEndpoint(url: "https://www.reddit.com/r/fitness.json?limit=1", 
                           description: "Fitness Community", category: .lifestyle),
                APIEndpoint(url: "https://www.reddit.com/r/running.json?limit=1", 
                           description: "Running Community", category: .sports),
                APIEndpoint(url: "https://www.reddit.com/r/yoga.json?limit=1", 
                           description: "Yoga Community", category: .lifestyle),
                
                // Health/nutrition
                APIEndpoint(url: "https://www.reddit.com/r/nutrition.json?limit=1", 
                           description: "Nutrition News", category: .lifestyle),
                APIEndpoint(url: "https://www.reddit.com/r/HealthyFood.json?limit=1", 
                           description: "Healthy Food", category: .recipes),
                
                // Sports activities
                APIEndpoint(url: "https://www.thesportsdb.com/api/v1/json/3/all_sports.php", 
                           description: "Sports Activities", category: .sports),
                
                // Healthy recipes
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood", 
                           description: "Healthy Seafood", category: .recipes),
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegetarian", 
                           description: "Vegetarian Meals", category: .recipes),
                
                // Motivational quotes
                APIEndpoint(url: "https://api.quotable.io/random?tags=fitness", 
                           description: "Fitness Quotes", category: .lifestyle),
            ]
            
        case .foodie:
            return [
                // Recipe APIs
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/random.php", 
                           description: "Random Meal", category: .recipes),
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/randomselection.php", 
                           description: "Meal Selection", category: .recipes),
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/list.php?c=list", 
                           description: "Meal Categories", category: .recipes),
                
                // Food subreddits
                APIEndpoint(url: "https://www.reddit.com/r/food.json?limit=1", 
                           description: "Food Community", category: .recipes),
                APIEndpoint(url: "https://www.reddit.com/r/recipes.json?limit=1", 
                           description: "Recipes", category: .recipes),
                APIEndpoint(url: "https://www.reddit.com/r/Cooking.json?limit=1", 
                           description: "Cooking Tips", category: .recipes),
                
                // Cocktail recipes
                APIEndpoint(url: "https://www.thecocktaildb.com/api/json/v1/1/random.php", 
                           description: "Random Cocktail", category: .lifestyle),
                APIEndpoint(url: "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list", 
                           description: "Cocktail Categories", category: .lifestyle),
                
                // Food entertainment
                APIEndpoint(url: "https://api.artic.edu/api/v1/artworks?limit=1", 
                           description: "Food Art", category: .entertainment),
            ]
            
        case .financialAnalyst:
            return [
                // Major stock indices
                APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^GSPC?interval=1d&range=1d", 
                           description: "S&P 500", category: .finance),
                APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^DJI?interval=1d&range=1d", 
                           description: "Dow Jones", category: .finance),
                APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^IXIC?interval=1d&range=1d", 
                           description: "NASDAQ", category: .finance),
                APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^FTSE?interval=1d&range=1d", 
                           description: "FTSE 100", category: .finance),
                APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^N225?interval=1d&range=1d", 
                           description: "Nikkei 225", category: .finance),
                
                // Cryptocurrency
                APIEndpoint(url: "https://api.coindesk.com/v1/bpi/currentprice.json", 
                           description: "Bitcoin Price", category: .finance),
                APIEndpoint(url: "https://api.coinbase.com/v2/exchange-rates?currency=BTC", 
                           description: "BTC Exchange Rates", category: .finance),
                APIEndpoint(url: "https://api.coinbase.com/v2/exchange-rates?currency=ETH", 
                           description: "ETH Exchange Rates", category: .finance),
                
                // Currency exchange
                APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/USD", 
                           description: "USD Exchange Rates", category: .finance),
                APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/EUR", 
                           description: "EUR Exchange Rates", category: .finance),
                
                // Financial news
                APIEndpoint(url: "https://www.reddit.com/r/finance.json?limit=1", 
                           description: "Finance News", category: .news),
                APIEndpoint(url: "https://www.reddit.com/r/investing.json?limit=1", 
                           description: "Investing News", category: .news),
            ]
            
        case .sportsFan:
            return [
                // Major sports leagues
                APIEndpoint(url: "https://www.thesportsdb.com/api/v1/json/3/all_sports.php", 
                           description: "All Sports", category: .sports),
                APIEndpoint(url: "https://www.thesportsdb.com/api/v1/json/3/all_leagues.php", 
                           description: "All Leagues", category: .sports),
                
                // Soccer/Football
                APIEndpoint(url: "https://api.football-data.org/v4/competitions/PL/matches?status=SCHEDULED&limit=1", 
                           description: "Premier League", category: .sports),
                APIEndpoint(url: "https://api.football-data.org/v4/competitions/CL/matches?status=SCHEDULED&limit=1", 
                           description: "Champions League", category: .sports),
                
                // NBA
                APIEndpoint(url: "https://www.balldontlie.io/api/v1/players?per_page=1", 
                           description: "NBA Players", category: .sports),
                
                // Olympics
                APIEndpoint(url: "https://www.reddit.com/r/olympics.json?limit=1", 
                           description: "Olympics News", category: .sports),
                
                // Sports news
                APIEndpoint(url: "https://www.reddit.com/r/sports.json?limit=1", 
                           description: "Sports News", category: .sports),
                APIEndpoint(url: "https://www.reddit.com/r/nba.json?limit=1", 
                           description: "NBA News", category: .sports),
                APIEndpoint(url: "https://www.reddit.com/r/soccer.json?limit=1", 
                           description: "Soccer News", category: .sports),
            ]
            
        case .digitalNomad:
            return [
                // Time zones worldwide
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/Asia/Tokyo", 
                           description: "Tokyo Time", category: .travel),
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/Europe/London", 
                           description: "London Time", category: .travel),
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/America/New_York", 
                           description: "New York Time", category: .travel),
                APIEndpoint(url: "https://worldtimeapi.org/api/timezone/Australia/Sydney", 
                           description: "Sydney Time", category: .travel),
                
                // Currency exchange
                APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/USD", 
                           description: "USD Exchange Rates", category: .travel),
                APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/EUR", 
                           description: "EUR Exchange Rates", category: .travel),
                APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/GBP", 
                           description: "GBP Exchange Rates", category: .travel),
                
                // Country information
                APIEndpoint(url: "https://restcountries.com/v3.1/all?fields=name,capital,currencies", 
                           description: "Country Currencies", category: .travel),
                APIEndpoint(url: "https://restcountries.com/v3.1/all?fields=name,capital,timezones", 
                           description: "Country Timezones", category: .travel),
                
                // Weather in major nomad hubs
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=13.7563&longitude=100.5018&current=temperature_2m", 
                           description: "Bangkok Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=-8.4095&longitude=115.1889&current=temperature_2m", 
                           description: "Bali Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=25.0330&longitude=121.5654&current=temperature_2m", 
                           description: "Taipei Weather", category: .weather),
                
                // Language/translation
                APIEndpoint(url: "https://www.reddit.com/r/digitalnomad.json?limit=1", 
                           description: "Digital Nomad Community", category: .news),
            ]
            
        case .student:
            return [
                // Academic references
                APIEndpoint(url: "https://en.wikipedia.org/api/rest_v1/page/random/summary", 
                           description: "Wikipedia Learning", category: .reference),
                
                // Educational resources
                APIEndpoint(url: "https://openlibrary.org/search.json?q=computer+science&limit=1", 
                           description: "Computer Science Books", category: .entertainment),
                APIEndpoint(url: "https://openlibrary.org/search.json?q=mathematics&limit=1", 
                           description: "Mathematics Books", category: .entertainment),
                
                // Student life
                APIEndpoint(url: "https://www.reddit.com/r/college.json?limit=1", 
                           description: "College Life", category: .news),
                APIEndpoint(url: "https://www.reddit.com/r/studentsofcolor.json?limit=1", 
                           description: "Student Community", category: .news),
                
                // Campus weather (college towns)
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=42.3601&longitude=-71.0589&current=temperature_2m", 
                           description: "Boston Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=34.0522&longitude=-118.2437&current=temperature_2m", 
                           description: "LA Weather", category: .weather),
                APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=40.7128&longitude=-74.0060&current=temperature_2m", 
                           description: "NYC Weather", category: .weather),
                
                // Study motivation
                APIEndpoint(url: "https://api.quotable.io/random?tags=motivation", 
                           description: "Study Motivation", category: .lifestyle),
                
                // Cheap recipes (student budget)
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Side", 
                           description: "Side Dishes", category: .recipes),
                APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Starter", 
                           description: "Starters", category: .recipes),
            ]
        }
    }
}

// MARK: - API Endpoints
public struct APIEndpoint: Codable {
    public let url: String
    public let description: String
    public let category: EndpointCategory
    
    public enum EndpointCategory: String, CaseIterable, Codable {
        case reference = "Reference"
        case weather = "Weather"
        case tech = "Tech"
        case news = "News"
        case finance = "Finance"
        case science = "Science"
        case entertainment = "Entertainment"
        case lifestyle = "Lifestyle"
        case sports = "Sports"
        case recipes = "Recipes"
        case travel = "Travel"
    }
    
    // Default endpoints for general persona
    public static let `default`: [APIEndpoint] = [
        // === REFERENCE (Wikipedia in 6 languages) ===
        APIEndpoint(url: "https://en.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "English Wikipedia", category: .reference),
        APIEndpoint(url: "https://es.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "Spanish Wikipedia", category: .reference),
        APIEndpoint(url: "https://fr.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "French Wikipedia", category: .reference),
        APIEndpoint(url: "https://de.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "German Wikipedia", category: .reference),
        APIEndpoint(url: "https://it.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "Italian Wikipedia", category: .reference),
        APIEndpoint(url: "https://pt.wikipedia.org/api/rest_v1/page/random/summary", 
                   description: "Portuguese Wikipedia", category: .reference),
        
        // === WEATHER (Global cities) ===
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=51.5074&longitude=-0.1278&current=temperature_2m", 
                   description: "London Weather", category: .weather),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=48.8566&longitude=2.3522&current=temperature_2m", 
                   description: "Paris Weather", category: .weather),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=40.7128&longitude=-74.0060&current=temperature_2m", 
                   description: "New York Weather", category: .weather),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=35.6762&longitude=139.6503&current=temperature_2m", 
                   description: "Tokyo Weather", category: .weather),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=1.3521&longitude=103.8198&current=temperature_2m", 
                   description: "Singapore Weather", category: .weather),
        APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=-33.8688&longitude=151.2093&current=temperature_2m", 
                   description: "Sydney Weather", category: .weather),
        
        // === TECH ===
        APIEndpoint(url: "https://hacker-news.firebaseio.com/v0/topstories.json?limitToFirst=1", 
                   description: "Hacker News", category: .tech),
        APIEndpoint(url: "https://api.github.com/events?per_page=1", 
                   description: "GitHub Activity", category: .tech),
        
        // === NEWS ===
        APIEndpoint(url: "https://www.reddit.com/r/worldnews.json?limit=1", 
                   description: "World News", category: .news),
        APIEndpoint(url: "https://www.reddit.com/r/science.json?limit=1", 
                   description: "Science News", category: .science),
        APIEndpoint(url: "https://www.reddit.com/r/space.json?limit=1", 
                   description: "Space News", category: .science),
        
        // === LIFESTYLE / ENTERTAINMENT ===
        APIEndpoint(url: "https://api.quotable.io/random", 
                   description: "Random Quote", category: .lifestyle),
        APIEndpoint(url: "https://api.artic.edu/api/v1/artworks?limit=1", 
                   description: "Art Institute", category: .entertainment),
        APIEndpoint(url: "https://openlibrary.org/search.json?q=fiction&limit=1", 
                   description: "Book Search", category: .entertainment),
        APIEndpoint(url: "https://www.thecocktaildb.com/api/json/v1/1/random.php", 
                   description: "Cocktail Recipe", category: .lifestyle),
        APIEndpoint(url: "https://dog.ceo/api/breeds/image/random", 
                   description: "Dog Photo", category: .entertainment),
        APIEndpoint(url: "https://www.boredapi.com/api/activity", 
                   description: "Activity Suggestion", category: .lifestyle),
        
        // === FINANCE ===
        APIEndpoint(url: "https://api.coindesk.com/v1/bpi/currentprice.json", 
                   description: "Bitcoin Price", category: .finance),
        APIEndpoint(url: "https://api.coinbase.com/v2/exchange-rates?currency=BTC", 
                   description: "Crypto Rates", category: .finance),
        APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^GSPC?interval=1d&range=1d", 
                   description: "S&P 500", category: .finance),
        APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^DJI?interval=1d&range=1d", 
                   description: "Dow Jones", category: .finance),
        APIEndpoint(url: "https://query1.finance.yahoo.com/v8/finance/chart/^IXIC?interval=1d&range=1d", 
                   description: "NASDAQ", category: .finance),
        
        // === SPORTS ===
        APIEndpoint(url: "https://www.thesportsdb.com/api/v1/json/3/all_sports.php", 
                   description: "Sports List", category: .sports),
        APIEndpoint(url: "https://www.thesportsdb.com/api/v1/json/3/all_countries.php", 
                   description: "Sports Countries", category: .sports),
        APIEndpoint(url: "https://api.football-data.org/v4/competitions/PL/matches?status=SCHEDULED&limit=1", 
                   description: "Premier League", category: .sports),
        
        // === RECIPES ===
        APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/random.php", 
                   description: "Random Meal", category: .recipes),
        APIEndpoint(url: "https://www.themealdb.com/api/json/v1/1/randomselection.php", 
                   description: "Meal Selection", category: .recipes),
        
        // === TRAVEL ===
        APIEndpoint(url: "https://restcountries.com/v3.1/all?fields=name,capital,population", 
                   description: "Country Facts", category: .travel),
        APIEndpoint(url: "https://api.exchangerate-api.com/v4/latest/USD", 
                   description: "Exchange Rates", category: .travel),
        APIEndpoint(url: "https://worldtimeapi.org/api/ip", 
                   description: "World Time", category: .travel),
    ]
    
    // Expanded endpoints with more global coverage (for general persona)
    public static var all: [APIEndpoint] {
        var endpoints = `default`
        
        // Add extra weather cities
        let extraWeather: [APIEndpoint] = [
            // Europe
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=52.5200&longitude=13.4050&current=temperature_2m", 
                       description: "Berlin Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=41.9028&longitude=12.4964&current=temperature_2m", 
                       description: "Rome Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=55.7558&longitude=37.6173&current=temperature_2m", 
                       description: "Moscow Weather", category: .weather),
            // Asia
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=39.9042&longitude=116.4074&current=temperature_2m", 
                       description: "Beijing Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=25.2048&longitude=55.2708&current=temperature_2m", 
                       description: "Dubai Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=28.6139&longitude=77.2090&current=temperature_2m", 
                       description: "New Delhi Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=-6.2088&longitude=106.8456&current=temperature_2m", 
                       description: "Jakarta Weather", category: .weather),
            // Americas
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=19.4326&longitude=-99.1332&current=temperature_2m", 
                       description: "Mexico City Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=-23.5505&longitude=-46.6333&current=temperature_2m", 
                       description: "São Paulo Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=43.6532&longitude=-79.3832&current=temperature_2m", 
                       description: "Toronto Weather", category: .weather),
            // Africa
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=-33.9249&longitude=18.4241&current=temperature_2m", 
                       description: "Cape Town Weather", category: .weather),
            APIEndpoint(url: "https://api.open-meteo.com/v1/forecast?latitude=-1.2921&longitude=36.8219&current=temperature_2m", 
                       description: "Nairobi Weather", category: .weather),
        ]
        
        endpoints.append(contentsOf: extraWeather)
        return endpoints
    }
}

// MARK: - Configuration
public struct Config: Codable {
    public var isRunning: Bool = false
    public var dailyLimit: Int = 5
    public var startHour: Int = 7
    public var endHour: Int = 23
    public var requestCount: Int = 0
    public var lastResetDate: Date = Date()
    public var enabledCategories: CategorySettings = CategorySettings()
    public var currentPersona: Persona = .general
    
    public static let defaultConfigPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/diginoise/config.json")
    
    public static func load() -> Config {
        guard let data = try? Data(contentsOf: defaultConfigPath),
              let config = try? JSONDecoder().decode(Config.self, from: data) else {
            return Config()
        }
        return config
    }
    
    public func save() {
        try? FileManager.default.createDirectory(
            at: defaultConfigPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: defaultConfigPath)
        }
    }
    
    public mutating func checkAndResetDaily() {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            requestCount = 0
            lastResetDate = Date()
            save()
        }
    }
    
    public var canRunToday: Bool {
        checkAndResetDaily()
        return requestCount < dailyLimit
    }
}

// MARK: - Category Settings
public struct CategorySettings: Codable {
    public var reference: Bool = true      // Wikipedia
    public var weather: Bool = true        // Weather APIs
    public var tech: Bool = true           // Hacker News, GitHub
    public var news: Bool = true           // Reddit news
    public var finance: Bool = true        // Stocks, crypto
    public var science: Bool = true        // Space, science
    public var entertainment: Bool = true  // Art, books, dogs
    public var lifestyle: Bool = true      // Quotes, cocktails
    public var sports: Bool = true         // Sports scores
    public var recipes: Bool = true        // Food recipes
    public var travel: Bool = true         // Translation, geography
}

// MARK: - Logger
public enum Logger {
    public static let logFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".local/share/diginoise/diginoise.log")
    
    public static func setup() {
        try? FileManager.default.createDirectory(
            at: logFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    public static func log(_ message: String) {
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