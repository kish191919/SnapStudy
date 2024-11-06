

// Models/MatchingQuestion.swift
import Foundation

// 매칭 문제
struct MatchingQuestion: Question, Identifiable, Codable {
    let id: UUID = UUID()
    let type: QuestionType = .matching
    let difficulty: Difficulty
    let category: String
    let imageData: Data?
    let questionText: String
    let leftItems: [String]
    let rightItems: [String]
    let points: Int
    
    var correctPairs: [(Int, Int)] {
        zip(0..<leftItems.count, 0..<rightItems.count).map { ($0, $1) }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, type, difficulty, category, imageData, questionText, leftItems, rightItems, points
    }
}
