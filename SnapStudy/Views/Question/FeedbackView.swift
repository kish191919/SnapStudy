
//  Views/Question/FeedbackView.swift

import SwiftUI

struct FeedbackView: View {
    let isCorrect: Bool
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack {
            Text(isCorrect ? "정답입니다!" : "틀렸습니다.")
                .font(.title)
                .foregroundColor(isCorrect ? .green : .red)
            
            Button("다음 문제") {
                viewModel.nextQuestion()
            }
            .padding()
        }
    }
}
