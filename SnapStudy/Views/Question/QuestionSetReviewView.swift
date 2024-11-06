//
//  Views/Question/QuestionSetReviewView.swift
import SwiftUI

struct QuestionSetReviewView: View {
    let questionSet: QuestionSet
    @StateObject private var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    init(questionSet: QuestionSet) {
        self.questionSet = questionSet
        self._viewModel = StateObject(wrappedValue: QuestionViewModel())
    }
    
    var body: some View {
        VStack {
            if viewModel.isCompleted {
                VStack(spacing: 20) {
                    Text("복습 완료!")
                        .font(.title)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("이전 점수: \(questionSet.score)")
                        Text("이번 점수: \(viewModel.score)")
                        Text("정답 개수: \(viewModel.correctAnswersCount)/\(questionSet.questions.count)")
                    }
                    
                    Button("닫기") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            } else {
                // 현재 문제 표시
                if let currentQuestion = viewModel.currentQuestion {
                    QuestionView(question: currentQuestion)
                }
            }
        }
        .navigationTitle("문제 복습")
        .onAppear {
            viewModel.questions = questionSet.questions
            viewModel.currentQuestion = questionSet.questions.first
        }
    }
}


