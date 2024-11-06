
//  ViewModels/UserProfileViewModel.swift
import Foundation
import Combine

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    
    init() {
        // 저장된 프로필 불러오기
        if let savedProfile = UserDefaults.standard.data(forKey: "userProfile"),
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedProfile) {
            self.profile = decodedProfile
        } else {
            self.profile = UserProfile()
        }
    }
    
    // 학습 결과 업데이트
    func updateStats(score: Int, totalQuestions: Int, correctAnswers: Int) {
        DispatchQueue.main.async {
            self.profile.totalPoints += score
            self.profile.completedQuestions += totalQuestions
            self.profile.correctAnswers += correctAnswers
            
            // 연속 학습 스트릭 업데이트
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if let lastStudyDate = self.profile.lastStudyDate {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                if calendar.isDate(lastStudyDate, inSameDayAs: yesterday) {
                    self.profile.streak += 1
                } else if !calendar.isDate(lastStudyDate, inSameDayAs: today) {
                    self.profile.streak = 1
                }
            } else {
                self.profile.streak = 1
            }
            
            self.profile.lastStudyDate = today
            self.saveProfile()
        }
    }
    
    // 프로필 저장
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
}
