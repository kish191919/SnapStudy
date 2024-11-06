
// Models/StorageManager.swift
import CoreData
import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "SnapStudy")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
    }
    
    // 문제 저장
    func saveQuestion(_ question: Question) {
        let context = container.viewContext
        
        let questionEntity = QuestionEntity(context: context)
        questionEntity.id = question.id
        questionEntity.type = question.type.rawValue
        questionEntity.difficulty = question.difficulty.rawValue
        questionEntity.category = question.category
        questionEntity.imageData = question.imageData
        questionEntity.points = Int16(question.points)
        
        switch question {
        case let q as MultipleChoiceQuestion:
            questionEntity.questionText = q.questionText
            questionEntity.options = q.options as NSArray
            questionEntity.correctAnswerIndex = Int16(q.correctAnswerIndex)
            
        case let q as FillInBlankQuestion:
            questionEntity.questionText = q.questionText
            questionEntity.correctAnswer = q.correctAnswer
            questionEntity.acceptableAnswers = q.similarAcceptableAnswers as NSArray
            
        case let q as MatchingQuestion:
            questionEntity.leftItems = q.leftItems as NSArray
            questionEntity.rightItems = q.rightItems as NSArray
            // 튜플 배열을 CodablePair로 변환하여 저장
            let codablePairs = q.correctPairs.map(CodablePair.init)
            questionEntity.correctPairsData = try? JSONEncoder().encode(codablePairs)
            
        default:
            break
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving question: \(error)")
        }
    }
    
    // 저장된 문제 불러오기
    func loadQuestions() -> [Question] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { entity -> Question? in
                guard let typeString = entity.type,
                      let type = QuestionType(rawValue: typeString),
                      let difficultyString = entity.difficulty,
                      let difficulty = Difficulty(rawValue: difficultyString) else {
                    return nil
                }
                
                switch type {
                case .multipleChoice:
                    return MultipleChoiceQuestion(
                        difficulty: difficulty,
                        category: entity.category ?? "",
                        imageData: entity.imageData,
                        questionText: entity.questionText ?? "",
                        options: (entity.options as? [String]) ?? [],
                        correctAnswerIndex: Int(entity.correctAnswerIndex),
                        points: Int(entity.points)
                    )
                    
                case .fillInBlank:
                    return FillInBlankQuestion(
                        difficulty: difficulty,
                        category: entity.category ?? "",
                        imageData: entity.imageData,
                        questionText: entity.questionText ?? "",
                        correctAnswer: entity.correctAnswer ?? "",
                        similarAcceptableAnswers: (entity.acceptableAnswers as? [String]) ?? [],
                        points: Int(entity.points)
                    )
                    
                    // StorageManager.swift의 loadQuestions() 메서드 내부
                case .matching:
                    guard let correctPairsData = entity.correctPairsData,
                          let codablePairs = try? JSONDecoder().decode([CodablePair].self, from: correctPairsData) else {
                        return nil
                    }
                    
                    return MatchingQuestion(
                        difficulty: difficulty,
                        category: entity.category ?? "",
                        imageData: entity.imageData,
                        questionText: entity.questionText ?? "다음 항목들을 올바르게 매칭하세요:",
                        leftItems: (entity.leftItems as? [String]) ?? [],
                        rightItems: (entity.rightItems as? [String]) ?? [],
                        points: Int(entity.points)
                    )
                }
            }
        } catch {
            print("Error loading questions: \(error)")
            return []
        }
    }
}
