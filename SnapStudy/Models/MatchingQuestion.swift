

// Models/MatchingQuestion.swift
import Foundation

// 매칭 문제
struct MatchingQuestion: Question, Identifiable {
    let id: UUID = UUID()
    let type: QuestionType = .matching
    let difficulty: Difficulty
    let category: String
    let imageData: Data?
    let questionText: String  // 추가된 부분
    let leftItems: [String]
    let rightItems: [String]
    let correctPairs: [(Int, Int)]
    let points: Int
    
    var userPairs: [(Int, Int)]?
}
