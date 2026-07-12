import Foundation

public struct VibeBlueprint: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var promptRaw: String
    public var assignedModel: String
    public var systemInstructions: String
    public var styleTags: [String]
    public var temperature: Double
    public var maxTokens: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        promptRaw: String,
        assignedModel: String,
        systemInstructions: String = "You are a creative assistant matching the requested aesthetic.",
        styleTags: [String] = [],
        temperature: Double = 0.7,
        maxTokens: Int = 1000,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.promptRaw = promptRaw
        self.assignedModel = assignedModel
        self.systemInstructions = systemInstructions
        self.styleTags = styleTags
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.createdAt = createdAt
    }
}
