
//  Models/UserProfile.swift
import Foundation

// 사용자 프로필
struct UserProfile {
    var id: UUID = UUID()
    var streak: Int = 0
    var totalPoints: Int = 0
    var completedQuestions: Int = 0
    var correctAnswers: Int = 0
    var achievementBadges: [String] = []
}
