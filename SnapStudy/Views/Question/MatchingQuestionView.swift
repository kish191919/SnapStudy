
//  Views/Question/MatchingQuestionView.swift

import SwiftUI

struct MatchingQuestionView: View {
    let question: MatchingQuestion
    @State private var selectedLeft: Int?
    @State private var pairs: [(Int, Int)] = []
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // 매칭 지시문 표시
            Text(question.questionText)
                .font(.headline)
                .padding(.bottom)
            
            HStack(spacing: 40) {
                // 왼쪽 항목들
                VStack(alignment: .leading, spacing: 15) {
                    Text("항목")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(Array(question.leftItems.enumerated()), id: \.offset) { index, item in
                        Text(item)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedLeft == index ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                if !viewModel.showFeedback {
                                    selectedLeft = index
                                }
                            }
                    }
                }
                
                // 오른쪽 항목들
                VStack(alignment: .leading, spacing: 15) {
                    Text("매칭")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(Array(question.rightItems.enumerated()), id: \.offset) { index, item in
                        Text(item)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                pairs.contains(where: { $0.1 == index })
                                ? Color.green.opacity(0.3)
                                : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(8)
                            .onTapGesture {
                                if !viewModel.showFeedback, let left = selectedLeft {
                                    // 이미 매칭된 왼쪽 항목이 있는지 확인
                                    if let existingPairIndex = pairs.firstIndex(where: { $0.0 == left }) {
                                        pairs.remove(at: existingPairIndex)
                                    }
                                    // 이미 매칭된 오른쪽 항목이 있는지 확인
                                    if let existingPairIndex = pairs.firstIndex(where: { $0.1 == index }) {
                                        pairs.remove(at: existingPairIndex)
                                    }
                                    
                                    pairs.append((left, index))
                                    selectedLeft = nil
                                    
                                    if pairs.count == question.leftItems.count {
                                        viewModel.checkAnswer(answer: pairs)
                                    }
                                }
                            }
                    }
                }
            }
            .padding()
            
            if !pairs.isEmpty && pairs.count < question.leftItems.count {
                Button("초기화") {
                    pairs.removeAll()
                    selectedLeft = nil
                }
                .padding()
                .foregroundColor(.red)
            }
        }
        .padding()
    }
}
