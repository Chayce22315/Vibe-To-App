import Foundation
import Combine

public struct AIModelDescriptor: Identifiable, Hashable {
    public var id: String { name }
    public let name: String
    public let displayName: String
    public let characteristics: String
}

public class AppState: ObservableObject {
    @Published public var availableCredits: Int = 5000
    @Published public var lastRefreshDate: Date = Date()
    
    @Published public var savedBlueprints: [VibeBlueprint] = []
    @Published public var selectedModel: String = "sonnet-5"
    @Published public var isGenerating: Bool = false
    @Published public var generationOutput: String = ""
    @Published public var errorMessage: String? = nil
    
    // Ordered Taxonomy: Newest/Smarter/Slow -> Oldest/Smart/Fast
    public let eliteModels: [AIModelDescriptor] = [
        AIModelDescriptor(name: "fable-5", displayName: "Fable 5 (Pro)", characteristics: "Ultimate Reasoning Core"),
        AIModelDescriptor(name: "gpt-5", displayName: "GPT-5 Omniverse", characteristics: "Next-Gen Frontier Intelligence"),
        AIModelDescriptor(name: "opus-4.8", displayName: "Opus 4.8 (Pro)", characteristics: "For complex tasks / Deep Thinker"),
        AIModelDescriptor(name: "opus-4.7", displayName: "Opus 4.7 (Pro)", characteristics: "High-Tier Code & Architecture Synthesis"),
        AIModelDescriptor(name: "opus-4.6", displayName: "Opus 4.6 (Pro)", characteristics: "Stable Pro Analytical Engine")
    ]
    
    public let balancedModels: [AIModelDescriptor] = [
        AIModelDescriptor(name: "sonnet-5", displayName: "Sonnet 5", characteristics: "Most efficient for everyday tasks"),
        AIModelDescriptor(name: "sonnet-4.6", displayName: "Sonnet 4.6", characteristics: "Fluid UI Layout Specialist"),
        AIModelDescriptor(name: "gpt-4o", displayName: "GPT-4o", characteristics: "High Context Logic Core"),
        AIModelDescriptor(name: "opus-3", displayName: "Opus 3 (Pro)", characteristics: "Classic Claude 3 Deep Reasoning"),
        AIModelDescriptor(name: "gemini-2-pro", displayName: "Gemini 2.0 Pro", characteristics: "Multimodal Layout Transformer")
    ]
    
    public let highSpeedModels: [AIModelDescriptor] = [
        AIModelDescriptor(name: "haiku-4.5", displayName: "Haiku 4.5", characteristics: "Fastest for quick answers / Agile Snippets"),
        AIModelDescriptor(name: "gpt-4o-mini", displayName: "GPT-4o Mini", characteristics: "Ultra-Lightweight Sub-Second Responses"),
        AIModelDescriptor(name: "gemini-1.5-flash", displayName: "Gemini 1.5 Flash", characteristics: "High-Speed Efficiency Streamer"),
        AIModelDescriptor(name: "llama-3-8b", displayName: "Llama 3 (8B)", characteristics: "Lightweight Open Source Utility")
    ]
    
    private let aiService = PuterAIService()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadState()
        checkDailyCreditRefresh()
    }
    
    public func executeVibe(blueprint: VibeBlueprint) {
        guard availableCredits > 0 else {
            self.errorMessage = "Insufficient credits. Tank reloads at 12:00 AM midnight."
            return
        }
        
        self.isGenerating = true
        self.errorMessage = nil
        self.generationOutput = "Connecting to Puter AI Mesh..."
        
        aiService.generateResponse(blueprint: blueprint) { [weak self] serverTokenCost in
            guard let self = self else { return }
            self.deductCredits(amount: serverTokenCost)
        }
        .sink(receiveCompletion: { [weak self] completion in
            self?.isGenerating = false
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
                self?.generationOutput = "Pipeline execution halted."
            }
        }, receiveValue: { [weak self] rawText in
            self?.generationOutput = rawText
        })
        .store(in: &cancellables)
    }
    
    public func deductCredits(amount: Int) {
        let actualDeduction = max(1, amount)
        availableCredits = max(0, availableCredits - actualDeduction)
        saveState()
    }
    
    public func checkDailyCreditRefresh() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastRefreshDate) {
            availableCredits = 5000
            lastRefreshDate = Date()
            saveState()
        }
    }
    
    public func saveBlueprint(_ blueprint: VibeBlueprint) {
        if let index = savedBlueprints.firstIndex(where: { $0.id == blueprint.id }) {
            savedBlueprints[index] = blueprint
        } else {
            savedBlueprints.append(blueprint)
        }
        saveState()
    }
    
    private func saveState() {
        UserDefaults.standard.set(availableCredits, forKey: "availableCredits")
        UserDefaults.standard.set(lastRefreshDate, forKey: "lastRefreshDate")
        if let encoded = try? JSONEncoder().encode(savedBlueprints) {
            UserDefaults.standard.set(encoded, forKey: "savedBlueprints")
        }
    }
    
    private func loadState() {
        if let savedDate = UserDefaults.standard.object(forKey: "lastRefreshDate") as? Date {
            self.lastRefreshDate = savedDate
            self.availableCredits = UserDefaults.standard.integer(forKey: "availableCredits")
        } else {
            self.availableCredits = 5000
            self.lastRefreshDate = Date()
        }
        if let rawData = UserDefaults.standard.data(forKey: "savedBlueprints"),
           let decoded = try? JSONDecoder().decode([VibeBlueprint].self, from: rawData) {
            self.savedBlueprints = decoded
        }
    }
}
