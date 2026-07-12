import Foundation
import Combine

public class PuterAIService {
    private let session: URLSession
    private let endpointURL = URL(string: "https://api.puter.com/v1/chat/completion")!
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func generateResponse(
        blueprint: VibeBlueprint,
        onDeductCredits: @escaping (Int) -> Void
    ) -> AnyPublisher<String, Error> {
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": blueprint.assignedModel,
            "messages": [
                ["role": "system", "content": blueprint.systemInstructions],
                ["role": "user", "content": blueprint.promptRaw]
            ],
            "temperature": blueprint.temperature,
            "max_tokens": blueprint.maxTokens
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        request.httpBody = jsonData
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    var actualTokenCost = 0
                    if let usage = json["usage"] as? [String: Any],
                       let totalTokens = usage["total_tokens"] as? Int {
                        actualTokenCost = totalTokens
                    }
                    
                    if let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let textResult = message["content"] as? String {
                        
                        onDeductCredits(actualTokenCost)
                        return textResult
                    }
                }
                
                throw URLError(.cannotParseResponse)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
