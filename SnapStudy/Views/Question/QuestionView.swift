
//  Views/Question/QuestionView.swift

import SwiftUI

struct QuestionView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack {
            // 상단 점수 및 스트릭 표시
            HStack {
                Text("점수: \(viewModel.score)")
                Spacer()
                Text("스트릭: \(viewModel.streak)")
            }
            .padding()
            
            // 문제 영역
            if let question = viewModel.currentQuestion {
                switch question {
                case let q as MultipleChoiceQuestion:
                    MultipleChoiceQuestionView(question: q)
                case let q as FillInBlankQuestion:
                    FillInBlankQuestionView(question: q)
                case let q as MatchingQuestion:
                    MatchingQuestionView(question: q)
                default:
                    Text("지원하지 않는 문제 유형입니다.")
                }
            }
            
            // 피드백 영역
            if viewModel.showFeedback {
                FeedbackView(isCorrect: viewModel.isCorrect)
            }
        }
        .padding()
    }
}

