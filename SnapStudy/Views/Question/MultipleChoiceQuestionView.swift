
//  Views/Question/MultipleChoiceQuestionView.swift

import SwiftUI

struct MultipleChoiceQuestionView: View {
    let question: MultipleChoiceQuestion
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.questionText)
                .font(.title2)
                .padding(.bottom)
            
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    viewModel.checkAnswer(answer: index)
                }) {
                    HStack {
                        Text(question.options[index])
                        Spacer()
                        if viewModel.showFeedback {
                            Image(systemName: index == question.correctAnswerIndex ? "checkmark.circle.fill" : "x.circle.fill")
                                .foregroundColor(index == question.correctAnswerIndex ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .disabled(viewModel.showFeedback)
            }
        }
    }
}
