
//  Views/Profile/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("프로필")
                .font(.title)
            
            // 업적 뱃지들
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(userProfileViewModel.profile.achievementBadges, id: \.self) { badge in
                        VStack {
                            Image(systemName: "star.fill")
                                .font(.largeTitle)
                            Text(badge)
                                .font(.caption)
                        }
                        .padding()
                    }
                }
            }
            
            // 통계 요약
            VStack(alignment: .leading, spacing: 10) {
                Text("현재 스트릭: \(userProfileViewModel.profile.streak)일")
                Text("총 획득 포인트: \(userProfileViewModel.profile.totalPoints)")
            }
            .padding()
        }
    }
}
