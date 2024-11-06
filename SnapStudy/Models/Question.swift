
//  Models/Question.swift
import Foundation

// 문제 유형 열거형
enum QuestionType {
    case multipleChoice
    case fillInBlank
    case matching
    case ordering
}

// 문제 난이도
enum Difficulty {
    case easy
    case medium
    case hard
}

// 기본 문제 프로토콜
protocol Question {
    var id: UUID { get }
    var type: QuestionType { get }
    var difficulty: Difficulty { get }
    var category: String { get }
    var imageData: Data? { get }
    var points: Int { get }
}


