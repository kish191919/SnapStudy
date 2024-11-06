
//  Views/Question/FillInBlankQuestionView.swift

import SwiftUI

struct FillInBlankQuestionView: View {
    let question: FillInBlankQuestion
    @State private var answer: String = ""
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
            
            TextField("답을 입력하세요", text: $answer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(viewModel.showFeedback)
            
            Button("확인") {
                let isCorrect = viewModel.checkAnswer(answer: answer)
                viewModel.showFeedback = true
            }
            .disabled(viewModel.showFeedback || answer.isEmpty)
        }
    }
}
