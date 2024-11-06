
//  Views/Stats/StatsView.swift

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("학습 통계")
                .font(.title)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("현재 스트릭: \(userProfileViewModel.profile.streak)일")
                Text("총 점수: \(userProfileViewModel.profile.totalPoints)점")
                Text("완료한 문제: \(userProfileViewModel.profile.completedQuestions)개")
                Text("정답률: \(String(format: "%.1f", Double(userProfileViewModel.profile.correctAnswers) / Double(userProfileViewModel.profile.completedQuestions) * 100))%")
            }
            .padding()
        }
    }
}

