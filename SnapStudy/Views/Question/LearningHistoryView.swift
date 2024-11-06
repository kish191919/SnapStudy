//
//  Views/Question/LearningHistoryView.swift

import SwiftUI

struct LearningHistoryView: View {
    @StateObject private var viewModel = LearningHistoryViewModel()
    @State private var showingQuestionSet = false
    @State private var selectedQuestionSet: QuestionSet?
    
    var body: some View {
        List {
            ForEach(viewModel.questionSets) { questionSet in
                QuestionSetRow(questionSet: questionSet)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedQuestionSet = questionSet
                        showingQuestionSet = true
                    }
            }
        }
        .navigationTitle("학습 기록")
        .sheet(isPresented: $showingQuestionSet) {
            if let questionSet = selectedQuestionSet {
                QuestionSetReviewView(questionSet: questionSet)
            }
        }
        .onAppear {
            viewModel.loadQuestionSets()
        }
    }
}

struct QuestionSetRow: View {
    let questionSet: QuestionSet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(questionSet.date.formatted())
                .font(.headline)
            
            HStack {
                Text("점수: \(questionSet.score)/\(questionSet.totalQuestions * 10)")
                Spacer()
                Text("정답률: \(String(format: "%.1f%%", questionSet.completionRate))")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
