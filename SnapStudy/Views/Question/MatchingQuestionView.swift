
//  Views/Question/MatchingQuestionView.swift

import SwiftUI

struct MatchingQuestionView: View {
    let question: MatchingQuestion
    @State private var remainingLeftItems: [(String, Int)]
    @State private var remainingRightItems: [(String, Int)]
    @State private var userPairs: [MatchingPair] = []
    @EnvironmentObject var viewModel: QuestionViewModel
    
    init(question: MatchingQuestion) {
        self.question = question
        // 인덱스 정보를 포함하여 초기화
        _remainingLeftItems = State(initialValue: question.leftItems.enumerated().map { ($0.element, $0.offset) })
        // 오른쪽 항목은 랜덤하게 섞되 원래 인덱스 유지
        _remainingRightItems = State(initialValue: question.rightItems.enumerated().map { ($0.element, $0.offset) }.shuffled())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 진행 상황 표시
            ProgressView(value: Double(userPairs.count), total: Double(question.leftItems.count))
                .padding(.horizontal)
            HStack {
                Text("진행률: \(userPairs.count)/\(question.leftItems.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom)
            
            Text(question.questionText)
                .font(.headline)
                .padding(.bottom)
            
            HStack(spacing: 40) {
                // 왼쪽 항목들
                VStack(alignment: .leading, spacing: 15) {
                    Text("항목")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(remainingLeftItems, id: \.0) { item, index in
                        Text(item)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            .draggable(DraggableItem(text: item, index: index))
                    }
                }
                .frame(maxWidth: .infinity)
                
                // 오른쪽 항목들
                VStack(alignment: .leading, spacing: 15) {
                    Text("매칭")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(remainingRightItems, id: \.0) { item, index in
                        Text(item)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .dropDestination(for: DraggableItem.self) { droppedItems, _ in
                                guard let droppedItem = droppedItems.first else { return false }
                                handleDrop(leftItem: droppedItem.text,
                                         leftIndex: droppedItem.index,
                                         rightItem: item,
                                         rightIndex: index)
                                return true
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // 완료된 매칭 표시
            if !userPairs.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("완료된 매칭:")
                        .font(.headline)
                    
                    ForEach(userPairs) { pair in
                        HStack {
                            Text(pair.leftItem)
                            Image(systemName: "arrow.right")
                            Text(pair.rightItem)
                            Spacer()
                            Button(action: {
                                cancelMatch(pair: pair)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            if remainingLeftItems.isEmpty && !viewModel.showFeedback {
                Button("확인") {
                    checkAnswer()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private func handleDrop(leftItem: String, leftIndex: Int, rightItem: String, rightIndex: Int) {
        withAnimation {
            // 항목들을 남은 목록에서 제거
            remainingLeftItems.removeAll { $0.0 == leftItem }
            remainingRightItems.removeAll { $0.0 == rightItem }
            
            // 매칭 쌍 추가
            let newPair = MatchingPair(
                leftItem: leftItem,
                leftIndex: leftIndex,
                rightItem: rightItem,
                rightIndex: rightIndex
            )
            userPairs.append(newPair)
        }
    }
    
    private func cancelMatch(pair: MatchingPair) {
        withAnimation {
            // 매칭 쌍 제거
            userPairs.removeAll { $0.id == pair.id }
            
            // 항목들을 다시 목록에 추가
            remainingLeftItems.append((pair.leftItem, pair.leftIndex))
            remainingRightItems.append((pair.rightItem, pair.rightIndex))
        }
    }
    
    private func checkAnswer() {
        let userPairsIndices = userPairs.map { ($0.leftIndex, $0.rightIndex) }
        viewModel.checkAnswer(answer: userPairsIndices)
    }
}

// 매칭 진행 상황을 표시하는 보조 뷰
struct MatchingProgressBar: View {
   let current: Int
   let total: Int
   
   var body: some View {
       VStack(spacing: 5) {
           GeometryReader { geometry in
               ZStack(alignment: .leading) {
                   Rectangle()
                       .fill(Color.gray.opacity(0.3))
                       .frame(width: geometry.size.width, height: 8)
                       .cornerRadius(4)
                   
                   Rectangle()
                       .fill(Color.blue)
                       .frame(width: geometry.size.width * CGFloat(current) / CGFloat(total), height: 8)
                       .cornerRadius(4)
               }
           }
           .frame(height: 8)
           
           HStack {
               Text("\(current)/\(total) 매칭 완료")
                   .font(.caption)
                   .foregroundColor(.gray)
               Spacer()
           }
       }
   }
}

// 먼저 드래그할 아이템을 위한 구조체 정의

struct DraggableItem: Transferable, Codable {
    let text: String
    let index: Int
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: DraggableItem.self, contentType: .text)
    }
}
