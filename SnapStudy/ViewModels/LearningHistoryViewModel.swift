//
//  ViewModels/LearningHistoryViewModel.swift

import Foundation
import Combine
import SwiftUI

class LearningHistoryViewModel: ObservableObject {
    @Published var questionSets: [QuestionSet] = []
    
    func loadQuestionSets() {
        questionSets = StorageManager.shared.loadQuestionSets()
    }
}

