
//  Views/Question/FillInBlankQuestionView.swift

import SwiftUI

struct FillInBlankQuestionView: View {
    let question: FillInBlankQuestion
    @State private var answer: String = ""
    @State private var showHint: Bool = false
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
            
            HStack {
                Button(action: {
                    viewModel.checkAnswer(answer: answer)
                }) {
                    Text("확인")
                        .frame(minWidth: 80)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.showFeedback || answer.isEmpty)
                
                Button(action: {
                    showHint = true
                }) {
                    Text("힌트")
                        .frame(minWidth: 80)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.showFeedback || showHint)
            }
            
            if showHint {
                Text("힌트: \(String(question.correctAnswer.prefix(1)))...")
                    .foregroundColor(.gray)
            }
            
            if viewModel.showFeedback {
                VStack(alignment: .leading, spacing: 10) {
                    Text("정답: \(question.correctAnswer)")
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                        .font(.headline)
                    
                    if !viewModel.isCorrect {
                        Text("입력한 답: \(answer)")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
            }
        }
    }
}
