

// Models/MatchingQuestion.swift
import Foundation

// 매칭 문제
struct MatchingQuestion: Question, Identifiable {
    let id: UUID = UUID()
    let type: QuestionType = .matching
    let difficulty: Difficulty
    let category: String
    let imageData: Data?
    let questionText: String
    let leftItems: [String]
    let rightItems: [String]
    let correctPairs: [(Int, Int)]
    let points: Int
    
    init(difficulty: Difficulty,
         category: String,
         imageData: Data?,
         questionText: String,
         leftItems: [String],
         rightItems: [String],
         points: Int) {
        self.difficulty = difficulty
        self.category = category
        self.imageData = imageData
        self.questionText = questionText
        self.leftItems = leftItems
        self.rightItems = rightItems
        self.points = points
        // correctPairs는 자동으로 생성
        self.correctPairs = zip(0..<leftItems.count, 0..<rightItems.count).map { ($0, $1) }
    }
}
