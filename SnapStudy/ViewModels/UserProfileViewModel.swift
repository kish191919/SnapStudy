
//  ViewModels/UserProfileViewModel.swift
import Foundation
import Combine

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    
    init(profile: UserProfile = UserProfile()) {
        self.profile = profile
    }
    
    func updateStreak(completed: Bool) {
        if completed {
            profile.streak += 1
        } else {
            profile.streak = 0
        }
    }
    
    func addPoints(_ points: Int) {
        profile.totalPoints += points
    }
}

