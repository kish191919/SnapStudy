
// Models/FillInBlankQuestion.swift
import Foundation

// 빈칸 채우기 문제
struct FillInBlankQuestion: Question, Identifiable, Codable {
    let id: UUID = UUID()
    let type: QuestionType = .fillInBlank
    let difficulty: Difficulty
    let category: String
    let imageData: Data?
    let questionText: String
    let correctAnswer: String
    let similarAcceptableAnswers: [String]
    let points: Int
    
    var userAnswer: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, difficulty, category, imageData, questionText, correctAnswer, similarAcceptableAnswers, points
    }
}
