
// Models/UserProfile.swift
import Foundation

struct UserProfile: Codable {
    var id: UUID = UUID()
    var streak: Int = 0
    var totalPoints: Int = 0
    var completedQuestions: Int = 0
    var correctAnswers: Int = 0
    var lastStudyDate: Date?
    var achievementBadges: [String] = []
    
    // 계산 프로퍼티로 정답률 추가
    var accuracyRate: Double {
        guard completedQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(completedQuestions) * 100
    }
    
    // Codable 구현을 위한 CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, streak, totalPoints, completedQuestions, correctAnswers, lastStudyDate, achievementBadges
    }
    
    // 기본 생성자
    init() {
        self.id = UUID()
        self.streak = 0
        self.totalPoints = 0
        self.completedQuestions = 0
        self.correctAnswers = 0
        self.lastStudyDate = nil
        self.achievementBadges = []
    }
    
    // Decodable 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        streak = try container.decode(Int.self, forKey: .streak)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        completedQuestions = try container.decode(Int.self, forKey: .completedQuestions)
        correctAnswers = try container.decode(Int.self, forKey: .correctAnswers)
        lastStudyDate = try container.decodeIfPresent(Date.self, forKey: .lastStudyDate)
        achievementBadges = try container.decode([String].self, forKey: .achievementBadges)
    }
    
    // Encodable 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(streak, forKey: .streak)
        try container.encode(totalPoints, forKey: .totalPoints)
        try container.encode(completedQuestions, forKey: .completedQuestions)
        try container.encode(correctAnswers, forKey: .correctAnswers)
        try container.encodeIfPresent(lastStudyDate, forKey: .lastStudyDate)
        try container.encode(achievementBadges, forKey: .achievementBadges)
    }
}
