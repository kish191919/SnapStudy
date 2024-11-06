
//  Views/Stats/StatsView.swift

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("학습 통계")
                    .font(.title)
                    .padding(.top)
                
                // 스트릭
                HStack {
                    VStack(alignment: .leading) {
                        Text("현재 스트릭")
                            .font(.headline)
                        Text("\(userProfileViewModel.profile.streak)일")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 통계 그리드
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    StatCard(title: "총 점수",
                            value: "\(userProfileViewModel.profile.totalPoints)점",
                            icon: "star.fill",
                            color: .yellow)
                    
                    StatCard(title: "완료한 문제",
                            value: "\(userProfileViewModel.profile.completedQuestions)개",
                            icon: "checkmark.circle.fill",
                            color: .green)
                    
                    StatCard(title: "정답률",
                            value: String(format: "%.1f%%", userProfileViewModel.profile.accuracyRate),
                            icon: "percent",
                            color: .blue)
                    
                    StatCard(title: "정답 수",
                            value: "\(userProfileViewModel.profile.correctAnswers)개",
                            icon: "target",
                            color: .red)
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
