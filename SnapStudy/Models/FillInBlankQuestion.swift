
//  Models/FillInBlankQuestion.swift
import Foundation

// 빈칸 채우기 문제
struct FillInBlankQuestion: Question, Identifiable {
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
}
