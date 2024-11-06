//  Views/Main/ContentView.swift
import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var questionViewModel = QuestionViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    
    var body: some View {
        TabView {
            ImageSelectionView()  // 추가
               .tabItem {
                   Label("촬영", systemImage: "camera.fill")
               }
            
            QuestionView()
                .tabItem {
                    Label("학습", systemImage: "book.fill")
                }
            
            StatsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
        }
        .environmentObject(questionViewModel)
        .environmentObject(userProfileViewModel)
    }
}
