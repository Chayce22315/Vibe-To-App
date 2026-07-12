import Foundation
import Combine
import SwiftUI

public class VibeBridgeViewModel: ObservableObject {
    // Live UI binding states for the user input panel
    @Published public var userPromptText: String = ""
    @Published public var customTitle: String = ""
    @Published public var systemInstructions: String = "You are a creative design assistant matching the requested aesthetic."
    @Published public var temperature: Double = 0.7
    
    public init() {}
    
    /// The core bridging operation: captures current state parameters, constructs the blueprint, and executes
    public func triggerLiveGeneration(appState: AppState) {
        let trimmedPrompt = userPromptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            appState.errorMessage = "Please enter a prompt concept to configure your vibe layout."
            return
        }
        
        // Use a fallback title if the user left it empty
        let assignedTitle = customTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
            ? "Vibe Layout Core (\(appState.selectedModel))" 
            : customTitle
        
        // Pack everything into our formal blueprint schema data contract
        let dynamicBlueprint = VibeBlueprint(
            title: assignedTitle,
            promptRaw: trimmedPrompt,
            assignedModel: appState.selectedModel, // Grabs the exact selected model from your custom tiers
            systemInstructions: systemInstructions,
            temperature: temperature,
            maxTokens: 1500
        )
        
        // Save the blueprint into local persistence so the user never loses it
        appState.saveBlueprint(dynamicBlueprint)
        
        // Fire the blueprint through the real-time Puter token pipeline!
        appState.executeVibe(blueprint: dynamicBlueprint)
    }
}
