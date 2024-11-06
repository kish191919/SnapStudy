//
//  Views/Question/QuestionReviewView.swift
import SwiftUI

struct QuestionReviewView: View {
    let questionSet: QuestionSet
    @StateObject private var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    
    init(questionSet: QuestionSet) {
        self.questionSet = questionSet
        _viewModel = StateObject(wrappedValue: QuestionViewModel())
    }
    
    var body: some View {
        VStack {
            if viewModel.isCompleted {
                VStack {
                    Text("학습 완료!")
                        .font(.title)
                    Text("점수: \(viewModel.score)/\(questionSet.questions.count)")
                    
                    Button("닫기") {
                        dismiss()
                    }
                    .padding()
                }
            } else {
                // 기존 QuestionView와 동일한 내용
            }
        }
        .onAppear {
            viewModel.questions = questionSet.questions
            viewModel.currentQuestion = questionSet.questions.first
        }
    }
}
