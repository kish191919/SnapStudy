
// Models/QuestionTypes.swift
import Foundation

enum QuestionType: String, Codable {
    case multipleChoice = "multipleChoice"
    case fillInBlank = "fillInBlank"
    case matching = "matching"
}

enum Difficulty: String, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
}

protocol Question: Codable {
    var id: UUID { get }
    var type: QuestionType { get }
    var difficulty: Difficulty { get }
    var category: String { get }
    var imageData: Data? { get }
    var points: Int { get }
}


