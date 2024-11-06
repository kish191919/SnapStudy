
//  ViewModels/QuestionViewModel.swift
import Foundation
import Combine
import SwiftUI

class QuestionViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var questions: [Question] = []
    @Published var showFeedback: Bool = false
    @Published var isCorrect: Bool = false
    @Published var loadingState: LoadingState = .idle
    @Published var loadedQuestionsCount: Int = 0
    @Published var isCompleted: Bool = false
    @Published var correctAnswersCount: Int = 0
    
    var userProfileViewModel: UserProfileViewModel?
    
    func nextQuestion() {
            guard currentIndex < questions.count - 1 else {
                // 마지막 문제가 끝났을 때
                isCompleted = true
                // 학습 통계 업데이트
                userProfileViewModel?.updateStats(
                    score: score,
                    totalQuestions: questions.count,
                    correctAnswers: correctAnswersCount
                )
                // 문제 세트 저장
                saveCurrentQuestionSet()
                return
            }
            
            currentIndex += 1
            currentQuestion = questions[currentIndex]
            showFeedback = false
            isCorrect = false
        }
    
    private func saveCurrentQuestionSet() {
        let questionSet = QuestionSet(
            id: UUID(),
            date: Date(),
            questions: questions,
            score: score,
            totalQuestions: questions.count
        )
        StorageManager.shared.saveQuestionSet(questionSet)
    }
    
    enum LoadingState {
        case idle
        case loading
        case error(String)
    }
    
    func loadQuestions(from image: UIImage) {
        loadingState = .loading
        questions = []
        loadedQuestionsCount = 0
        
        Task {
            do {
                for try await question in ClaudeAPIService.shared.generateQuestionsProgressively(from: image) {
                    await MainActor.run {
                        self.questions.append(question)
                        self.loadedQuestionsCount += 1
                        if self.currentQuestion == nil {
                            self.currentQuestion = question
                        }
                    }
                }
                await MainActor.run {
                    self.loadingState = .idle
                }
            } catch {
                await MainActor.run {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    // 튜플 배열 비교 함수 추가
    private func comparePairs(_ pairs1: [(Int, Int)], _ pairs2: [(Int, Int)]) -> Bool {
        guard pairs1.count == pairs2.count else { return false }
        
        // 두 배열을 정렬하여 비교
        let sortedPairs1 = pairs1.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
        let sortedPairs2 = pairs2.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
        
        // 각 요소 비교
        for i in 0..<sortedPairs1.count {
            if sortedPairs1[i].0 != sortedPairs2[i].0 || sortedPairs1[i].1 != sortedPairs2[i].1 {
                return false
            }
        }
        return true
    }
    
    func checkAnswer(answer: Any) {
            guard let question = currentQuestion else { return }
            
            switch question {
            case let q as MultipleChoiceQuestion:
                if let answer = answer as? Int {
                    isCorrect = answer == q.correctAnswerIndex
                    updateScore(isCorrect: isCorrect)
                }
            case let q as FillInBlankQuestion:
                if let answer = answer as? String {
                    isCorrect = q.correctAnswer.lowercased() == answer.lowercased() ||
                        q.similarAcceptableAnswers.contains(where: { $0.lowercased() == answer.lowercased() })
                    updateScore(isCorrect: isCorrect)
                }
            case let q as MatchingQuestion:
                if let answer = answer as? [(Int, Int)] {
                    isCorrect = comparePairs(answer, q.correctPairs)
                    updateScore(isCorrect: isCorrect)
                }
            default:
                break
            }
            
            if isCorrect {
                correctAnswersCount += 1
            }
            
            showFeedback = true
        }
    
    private func updateScore(isCorrect: Bool) {
            if isCorrect {
                score += currentQuestion?.points ?? 0
            }
        }
    
  
}


struct QuestionSet: Codable, Identifiable {
    let id: UUID
    let date: Date
    let questions: [any Question]
    let score: Int
    let totalQuestions: Int
    
    var completionRate: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    init(id: UUID, date: Date, questions: [any Question], score: Int, totalQuestions: Int) {
        self.id = id
        self.date = date
        self.questions = questions
        self.score = score
        self.totalQuestions = totalQuestions
    }
    
    // Codable 구현을 위한 CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, date, questions, score, totalQuestions
    }
    
    // 디코딩 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        let anyQuestions = try container.decode([AnyQuestion].self, forKey: .questions)
        questions = anyQuestions.map { $0.base }
        score = try container.decode(Int.self, forKey: .score)
        totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
    }
    
    // 인코딩 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        let anyQuestions = questions.map { AnyQuestion($0) }
        try container.encode(anyQuestions, forKey: .questions)
        try container.encode(score, forKey: .score)
        try container.encode(totalQuestions, forKey: .totalQuestions)
    }
}

// Question 타입을 래핑하는 타입
struct AnyQuestion: Codable {
    var base: Question
    
    init(_ base: Question) {
        self.base = base
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, data
    }
    
    enum QuestionType: String, Codable {
        case multipleChoice, fillInBlank, matching
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(QuestionType.self, forKey: .type)
        switch type {
        case .multipleChoice:
            base = try container.decode(MultipleChoiceQuestion.self, forKey: .data)
        case .fillInBlank:
            base = try container.decode(FillInBlankQuestion.self, forKey: .data)
        case .matching:
            base = try container.decode(MatchingQuestion.self, forKey: .data)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch base {
        case let q as MultipleChoiceQuestion:
            try container.encode(QuestionType.multipleChoice, forKey: .type)
            try container.encode(q, forKey: .data)
        case let q as FillInBlankQuestion:
            try container.encode(QuestionType.fillInBlank, forKey: .type)
            try container.encode(q, forKey: .data)
        case let q as MatchingQuestion:
            try container.encode(QuestionType.matching, forKey: .type)
            try container.encode(q, forKey: .data)
        default:
            break
        }
    }
}
