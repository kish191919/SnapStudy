// Models/MultipleChoiceQuestion.swift
import Foundation

// 4지선다 문제
struct MultipleChoiceQuestion: Question, Identifiable, Codable {
    let id: UUID = UUID()
    let type: QuestionType = .multipleChoice
    let difficulty: Difficulty
    let category: String
    let imageData: Data?
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
    let points: Int
    
    var isAnsweredCorrectly: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, type, difficulty, category, imageData, questionText, options, correctAnswerIndex, points
    }
}
