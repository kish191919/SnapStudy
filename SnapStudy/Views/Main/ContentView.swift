//  Views/Main/ContentView.swift
import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var questionViewModel = QuestionViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                QuestionView()
            }
            .tabItem {
                Label("학습", systemImage: "book.fill")
            }
            .tag(0)
            
            NavigationView {
                StatsView()
            }
            .tabItem {
                Label("통계", systemImage: "chart.bar.fill")
            }
            .tag(1)
            
            NavigationView {
                LearningHistoryView()
            }
            .tabItem {
                Label("학습 기록", systemImage: "clock.fill")
            }
            .tag(2)
        }
        .onChange(of: questionViewModel.isCompleted) { completed in
            if completed {
                selectedTab = 1 // 통계 탭으로 자동 이동
                userProfileViewModel.updateStats(
                    score: questionViewModel.score,
                    totalQuestions: questionViewModel.questions.count,
                    correctAnswers: questionViewModel.correctAnswersCount
                )
            }
        }
        .environmentObject(questionViewModel)
        .environmentObject(userProfileViewModel)
    }
}
