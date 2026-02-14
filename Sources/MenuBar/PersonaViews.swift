import SwiftUI
import DigiNoiseShared

// MARK: - Persona Selection View
struct PersonaSelectionView: View {
    @Binding var selectedPersona: Persona
    @State private var showingPersonaInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Digital Persona")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("ℹ️") {
                    showingPersonaInfo = true
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Picker("Persona", selection: $selectedPersona) {
                ForEach(Persona.allCases, id: \.self) { persona in
                    Text(persona.rawValue)
                        .tag(persona)
                        .help(persona.description)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedPersona) { newPersona in
                // Save the new persona
                var config = Config.load()
                config.currentPersona = newPersona
                config.save()
                
                // Update endpoints based on persona
                updateCategoriesForPersona(newPersona)
            }
            
            Text(selectedPersona.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .sheet(isPresented: $showingPersonaInfo) {
            PersonaInfoView()
        }
    }
    
    func updateCategoriesForPersona(_ persona: Persona) {
        var config = Config.load()
        let endpoints = persona.defaultEndpoints
        let categories = Set(endpoints.map { $0.category })
        
        // Reset all categories first
        config.enabledCategories = CategorySettings()
        
        // Enable only relevant categories
        for category in categories {
            switch category {
            case .reference:
                config.enabledCategories.reference = true
            case .weather:
                config.enabledCategories.weather = true
            case .tech:
                config.enabledCategories.tech = true
            case .news:
                config.enabledCategories.news = true
            case .finance:
                config.enabledCategories.finance = true
            case .science:
                config.enabledCategories.science = true
            case .entertainment:
                config.enabledCategories.entertainment = true
            case .lifestyle:
                config.enabledCategories.lifestyle = true
            case .sports:
                config.enabledCategories.sports = true
            case .recipes:
                config.enabledCategories.recipes = true
            case .travel:
                config.enabledCategories.travel = true
            }
        }
        
        config.save()
    }
}

// MARK: - Persona Info View
struct PersonaInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Digital Personas")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Persona.allCases, id: \.self) { persona in
                        PersonaCard(persona: persona)
                    }
                }
            }
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

struct PersonaCard: View {
    let persona: Persona
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(persona.rawValue)
                    .font(.headline)
                Spacer()
                Button("Details") {
                    showingDetails = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            Text(persona.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            let endpointCount = persona.defaultEndpoints.count
            Text("\(endpointCount) endpoints")
                .font(.caption)
                .foregroundColor(.accentColor)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .sheet(isPresented: $showingDetails) {
            PersonaDetailsView(persona: persona)
        }
    }
}

struct PersonaDetailsView: View {
    let persona: Persona
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text(persona.rawValue)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(persona.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider()
            
            let endpoints = persona.defaultEndpoints
            let grouped = Dictionary(grouping: endpoints) { $0.category }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(APIEndpoint.EndpointCategory.allCases, id: \.self) { category in
                        if let categoryEndpoints = grouped[category] {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                
                                ForEach(categoryEndpoints, id: \.description) { endpoint in
                                    Text("• \(endpoint.description)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 450, height: 400)
    }
}

// MARK: - Modified MenuBarView with Persona Selection
extension MenuBarView {
    var body: some View {
        VStack(spacing: 16) {
            headerView
            
            // Add persona selection
            PersonaSelectionView(selectedPersona: .constant(appState.config.currentPersona))
            
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
}