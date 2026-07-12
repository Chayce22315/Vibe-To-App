import SwiftUI

public struct MainLayoutView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var bridgeVM = VibeBridgeViewModel()
    @State private var currentTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $currentTab) {
            // TAB 1: Real-time Vibe Configuration Studio
            NavigationView {
                VStack(spacing: 0) {
                    // Global Credit Status Banner Card
                    HeaderCreditBanner()
                    
                    Form {
                        Section(header: Text("Model Performance Matrix (2026 Taxonomy)")) {
                            Picker("Target Engine", selection: $appState.selectedModel) {
                                Text("--- Elite & Reasoning (Smarter/Deep) ---").tag("disabled_header_1")
                                ForEach(appState.eliteModels) { model in
                                    VStack(alignment: .leading) {
                                        Text(model.displayName).bold()
                                        Text(model.characteristics).font(.caption).foregroundColor(.secondary)
                                    }.tag(model.name)
                                }
                                
                                Text("--- Balanced Performance (Everyday) ---").tag("disabled_header_2")
                                ForEach(appState.balancedModels) { model in
                                    VStack(alignment: .leading) {
                                        Text(model.displayName).bold()
                                        Text(model.characteristics).font(.caption).foregroundColor(.secondary)
                                    }.tag(model.name)
                                }
                                
                                Text("--- High-Speed Utility (Fast/Agile) ---").tag("disabled_header_3")
                                ForEach(appState.highSpeedModels) { model in
                                    VStack(alignment: .leading) {
                                        Text(model.displayName).bold()
                                        Text(model.characteristics).font(.caption).foregroundColor(.secondary)
                                    }.tag(model.name)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        
                        Section(header: Text("Vibe Parameters")) {
                            TextField("Custom Project Title", text: $bridgeVM.customTitle)
                            TextEditor(text: $bridgeVM.userPromptText)
                                .frame(height: 100)
                                .foregroundColor(.primary)
                        }
                        
                        Section {
                            Button(action: {
                                bridgeVM.triggerLiveGeneration(appState: appState)
                            }) {
                                HStack {
                                    Spacer()
                                    if appState.isGenerating {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                                        Text(" Orchestrating Pipeline...")
                                    } else {
                                        Image(systemName: "bolt.fill")
                                        Text(" Execute Custom Vibe Layout")
                                    }
                                    Spacer()
                                }
                            }
                            .disabled(appState.isGenerating)
                            .foregroundColor(.white)
                            .listRowBackground(appState.isGenerating ? Color.gray : Color.blue)
                        }
                        
                        if !appState.generationOutput.isEmpty {
                            Section(header: Text("Live System Engine Output")) {
                                Text(appState.generationOutput)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .navigationTitle("Vibe Studio")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Studio", systemImage: "slider.horizontal.3")
            }
            .tag(0)
            
            // TAB 2: Historical Blueprint Ledger Vault
            NavigationView {
                List {
                    if appState.savedBlueprints.isEmpty {
                        Text("No saved configurations recorded yet.")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(appState.savedBlueprints) { blueprint in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(blueprint.title).font(.headline)
                                Text("Model: \(blueprint.assignedModel)").font(.caption).foregroundColor(.blue)
                                Text(blueprint.promptRaw).font(.subheadline).lineLimit(2).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Saved Blueprints")
            }
            .tabItem {
                Label("Vault", systemImage: "folder.fill")
            }
            .tag(1)
        }
    }
}

// Visual Sub-Component for Credit Display Ledger
struct HeaderCreditBanner: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("DAILY SYSTEM ENERGY")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.blue)
                Text("\(appState.availableCredits) Credits")
                    .font(.title2)
                    .bold()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("RESET HORIZON")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("12:00 AM Midnight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
