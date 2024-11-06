// Models/MultipleChoiceQuestion.swift
import Foundation

// 4지선다 문제
struct MultipleChoiceQuestion: Question, Identifiable {
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
}
