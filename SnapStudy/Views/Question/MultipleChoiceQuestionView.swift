
//  Views/Question/MultipleChoiceQuestionView.swift

import SwiftUI

struct MultipleChoiceQuestionView: View {
    let question: MultipleChoiceQuestion
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let imageData = question.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            
            Text(question.questionText)
                .font(.title2)
                .padding(.bottom)
            
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    let isCorrect = viewModel.checkAnswer(answer: index)
                    viewModel.showFeedback = true
                }) {
                    Text(question.options[index])
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .disabled(viewModel.showFeedback)
            }
        }
    }
}
