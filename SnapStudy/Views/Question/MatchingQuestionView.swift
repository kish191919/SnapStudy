
//  Views/Question/MatchingQuestionView.swift

import SwiftUI

struct MatchingQuestionView: View {
    let question: MatchingQuestion
    @State private var selectedLeft: Int?
    @State private var pairs: [(Int, Int)] = []
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack {
            HStack {
                // 왼쪽 항목들
                VStack {
                    ForEach(0..<question.leftItems.count, id: \.self) { index in
                        Text(question.leftItems[index])
                            .padding()
                            .background(selectedLeft == index ? Color.blue.opacity(0.3) : Color.clear)
                            .onTapGesture {
                                selectedLeft = index
                            }
                    }
                }
                
                // 오른쪽 항목들
                VStack {
                    ForEach(0..<question.rightItems.count, id: \.self) { index in
                        Text(question.rightItems[index])
                            .padding()
                            .onTapGesture {
                                if let left = selectedLeft {
                                    pairs.append((left, index))
                                    selectedLeft = nil
                                    
                                    if pairs.count == question.leftItems.count {
                                        let isCorrect = viewModel.checkAnswer(answer: pairs)
                                        viewModel.showFeedback = true
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}
