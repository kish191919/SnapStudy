
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
    
    func loadQuestionSets() -> [QuestionSet] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<QuestionSetEntity> = QuestionSetEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let date = entity.date,
                      let questionsData = entity.questionsData,
                      let anyQuestions = try? JSONDecoder().decode([AnyQuestion].self, from: questionsData) else {
                    return nil
                }
                
                // AnyQuestion 배열을 Question 배열로 변환
                let questions = anyQuestions.map { $0.base }
                
                return QuestionSet(
                    id: id,
                    date: date,
                    questions: questions,
                    score: Int(entity.score),
                    totalQuestions: Int(entity.totalQuestions)
                )
            }
        } catch {
            print("Error loading question sets: \(error)")
            return []
        }
    }

    // QuestionSet을 저장할 때도 AnyQuestion을 사용하도록 수정
    func saveQuestionSet(_ questionSet: QuestionSet) {
        let context = container.viewContext
        let entity = QuestionSetEntity(context: context)
        entity.id = questionSet.id
        entity.date = questionSet.date
        entity.score = Int16(questionSet.score)
        entity.totalQuestions = Int16(questionSet.totalQuestions)
        
        // Question을 AnyQuestion으로 래핑하여 인코딩
        let anyQuestions = questionSet.questions.map { AnyQuestion($0) }
        if let questionsData = try? JSONEncoder().encode(anyQuestions) {
            entity.questionsData = questionsData
        }
        
        try? context.save()
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
