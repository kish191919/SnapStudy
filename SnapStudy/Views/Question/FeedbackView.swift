
//  Views/Question/FeedbackView.swift

import SwiftUI

struct FeedbackView: View {
    let isCorrect: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text(isCorrect ? "정답입니다!" : "틀렸습니다.")
                .font(.title2)
                .bold()
            
            Button("다음 문제", action: action)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
