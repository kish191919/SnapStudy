
//  App/APIKeyManager.swift
import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()
    
    private init() {}
    
    func getClaudeAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let keys = NSDictionary(contentsOfFile: path),
              let apiKey = keys["CLAUDE_API_KEY"] as? String else {
            print("Error: Cannot find APIKeys.plist or CLAUDE_API_KEY")
            return nil
        }
        return apiKey
    }
}
