import Foundation
import ArgumentParser
import DigiNoiseShared

// MARK: - Persona Commands
struct PersonaCmd: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "persona",
        abstract: "Manage digital personas for different browsing patterns",
        subcommands: [List.self, Set.self, Info.self]
    )
}

struct List: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "List available personas")
    
    func run() async throws {
        print("Available personas:\n")
        
        for persona in Persona.allCases {
            print("• \(persona.rawValue)")
            print("  \(persona.description)")
            print("")
        }
        
        let config = Config.load()
        print("Current persona: \(config.currentPersona.rawValue)")
    }
}

struct Set: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Set active persona")
    
    @Argument(help: "Persona name (use 'list' command to see options)")
    var personaName: String
    
    func validate() throws {
        let validNames = Persona.allCases.map { $0.rawValue.lowercased() }
        if !validNames.contains(personaName.lowercased()) {
            throw ValidationError("Invalid persona. Run 'diginoise persona list' to see available options.")
        }
    }
    
    func run() async throws {
        // Find the matching persona (case-insensitive)
        guard let persona = Persona.allCases.first(where: { 
            $0.rawValue.lowercased() == personaName.lowercased() 
        }) else {
            throw ValidationError("Persona not found: \(personaName)")
        }
        
        var config = Config.load()
        let oldPersona = config.currentPersona
        config.currentPersona = persona
        config.save()
        
        print("✅ Persona changed from '\(oldPersona.rawValue)' to '\(persona.rawValue)'")
        print("")
        print("Description: \(persona.description)")
        print("")
        
        // Show what endpoints will be used
        let endpoints = persona.defaultEndpoints
        let categories = Set(endpoints.map { $0.category.rawValue })
        print("This persona will make requests to \(endpoints.count) endpoints across \(categories.count) categories:")
        for category in categories.sorted() {
            let count = endpoints.filter { $0.category.rawValue == category }.count
            print("  • \(category): \(count) endpoints")
        }
        
        // Auto-enable relevant categories
        var categoriesToEnable = Set<APIEndpoint.EndpointCategory>()
        for endpoint in endpoints {
            categoriesToEnable.insert(endpoint.category)
        }
        
        var categoriesEnabled = [String]()
        
        // Enable categories based on endpoints
        if categoriesToEnable.contains(.reference) {
            config.enabledCategories.reference = true
            categoriesEnabled.append("Reference")
        }
        if categoriesToEnable.contains(.weather) {
            config.enabledCategories.weather = true
            categoriesEnabled.append("Weather")
        }
        if categoriesToEnable.contains(.tech) {
            config.enabledCategories.tech = true
            categoriesEnabled.append("Tech")
        }
        if categoriesToEnable.contains(.news) {
            config.enabledCategories.news = true
            categoriesEnabled.append("News")
        }
        if categoriesToEnable.contains(.finance) {
            config.enabledCategories.finance = true
            categoriesEnabled.append("Finance")
        }
        if categoriesToEnable.contains(.science) {
            config.enabledCategories.science = true
            categoriesEnabled.append("Science")
        }
        if categoriesToEnable.contains(.entertainment) {
            config.enabledCategories.entertainment = true
            categoriesEnabled.append("Entertainment")
        }
        if categoriesToEnable.contains(.lifestyle) {
            config.enabledCategories.lifestyle = true
            categoriesEnabled.append("Lifestyle")
        }
        if categoriesToEnable.contains(.sports) {
            config.enabledCategories.sports = true
            categoriesEnabled.append("Sports")
        }
        if categoriesToEnable.contains(.recipes) {
            config.enabledCategories.recipes = true
            categoriesEnabled.append("Recipes")
        }
        if categoriesToEnable.contains(.travel) {
            config.enabledCategories.travel = true
            categoriesEnabled.append("Travel")
        }
        
        if !categoriesEnabled.isEmpty {
            config.save()
            print("")
            print("Automatically enabled categories: \(categoriesEnabled.joined(separator: ", "))")
        }
        
        print("")
        print("Note: You can still manually adjust categories with 'diginoise config categories'")
    }
}

struct Info: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Show detailed info about a persona")
    
    @Argument(help: "Persona name")
    var personaName: String
    
    func validate() throws {
        let validNames = Persona.allCases.map { $0.rawValue.lowercased() }
        if !validNames.contains(personaName.lowercased()) {
            throw ValidationError("Invalid persona. Run 'diginoise persona list' to see available options.")
        }
    }
    
    func run() async throws {
        guard let persona = Persona.allCases.first(where: { 
            $0.rawValue.lowercased() == personaName.lowercased() 
        }) else {
            throw ValidationError("Persona not found: \(personaName)")
        }
        
        print("Persona: \(persona.rawValue)")
        print("Description: \(persona.description)")
        print("")
        
        let endpoints = persona.defaultEndpoints
        print("API Endpoints (\(endpoints.count) total):")
        print("")
        
        // Group by category
        let grouped = Dictionary(grouping: endpoints) { $0.category }
        
        for category in APIEndpoint.EndpointCategory.allCases {
            if let categoryEndpoints = grouped[category] {
                print("\(category.rawValue) (\(categoryEndpoints.count)):")
                for endpoint in categoryEndpoints {
                    print("  • \(endpoint.description)")
                }
                print("")
            }
        }
        
        // Show current config
        let config = Config.load()
        if config.currentPersona == persona {
            print("✅ This is your currently active persona")
        } else {
            print("To activate this persona, run: diginoise persona set \(persona.rawValue)")
        }
    }
}

// MARK: - Modified Config with persona support
extension Config {
    public var currentEndpoints: [APIEndpoint] {
        currentPersona.defaultEndpoints
    }
}