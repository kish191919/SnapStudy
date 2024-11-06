//
//  Views/Question/AnimatedView.swift


import SwiftUI

struct QuestionTransition: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isPresented ? 1 : 0)
            .offset(x: isPresented ? 0 : UIScreen.main.bounds.width)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
    }
}

struct FeedbackAnimation: ViewModifier {
    let isCorrect: Bool
    let isShowing: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isShowing ? 1 : 0.5)
            .opacity(isShowing ? 1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isShowing)
            .overlay(
                Circle()
                    .stroke(isCorrect ? Color.green : Color.red, lineWidth: 3)
                    .scaleEffect(isShowing ? 2 : 0)
                    .opacity(isShowing ? 0 : 1)
                    .animation(.easeOut(duration: 0.6), value: isShowing)
            )
    }
}
