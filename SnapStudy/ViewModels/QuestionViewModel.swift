
//  ViewModels/QuestionViewModel.swift
import Foundation
import Combine

class QuestionViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var showFeedback: Bool = false
    @Published var isCorrect: Bool = false
    @Published var questions: [Question] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadQuestions() {
        // TODO: Load questions from local storage or API
    }
    
    func checkAnswer(answer: Any) -> Bool {
        guard let question = currentQuestion else { return false }
        
        switch question {
        case let q as MultipleChoiceQuestion:
            if let answer = answer as? Int {
                isCorrect = answer == q.correctAnswerIndex
            }
        case let q as FillInBlankQuestion:
            if let answer = answer as? String {
                isCorrect = q.correctAnswer.lowercased() == answer.lowercased() ||
                    q.similarAcceptableAnswers.contains(where: { $0.lowercased() == answer.lowercased() })
            }
        case let q as MatchingQuestion:
            if let answer = answer as? [(Int, Int)] {
                isCorrect = answer.count == q.correctPairs.count &&
                    answer.enumerated().allSatisfy { index, pair in
                        pair.0 == q.correctPairs[index].0 &&
                        pair.1 == q.correctPairs[index].1
                    }
            }
        default:
            isCorrect = false
        }
        
        updateScore(isCorrect: isCorrect)
        return isCorrect
    }
    
    private func updateScore(isCorrect: Bool) {
        if isCorrect {
            streak += 1
            score += currentQuestion?.points ?? 0
            if streak > 0 {
                score += streak * 10 // Streak bonus
            }
        } else {
            streak = 0
        }
    }
    
    func nextQuestion() {
        guard currentIndex < questions.count - 1 else {
            // End of questions
            return
        }
        currentIndex += 1
        currentQuestion = questions[currentIndex]
        showFeedback = false
    }
}
