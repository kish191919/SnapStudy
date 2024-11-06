
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
                // 수정된 비교 로직 사용
                isCorrect = comparePairs(answer, q.correctPairs)
                updateScore(isCorrect: isCorrect)
            }
        default:
            break
        }
        
        showFeedback = true
    }
    
    private func updateScore(isCorrect: Bool) {
        if isCorrect {
            score += currentQuestion?.points ?? 0
        }
    }
    
    func nextQuestion() {
        guard currentIndex < questions.count - 1 else {
            return
        }
        
        currentIndex += 1
        currentQuestion = questions[currentIndex]
        showFeedback = false
        isCorrect = false
    }
}
