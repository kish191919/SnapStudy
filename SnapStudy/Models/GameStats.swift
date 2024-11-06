
// Models/GameStats.swift
import Foundation

// 게임 통계
struct GameStats {
    var currentStreak: Int
    var highestStreak: Int
    var totalPoints: Int
    var questionsAnswered: Int
    var correctAnswers: Int
    var accuracyRate: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered) * 100
    }
}
