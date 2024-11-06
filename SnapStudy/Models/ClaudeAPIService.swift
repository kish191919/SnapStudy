
//  Models/ClaudeAPIService.swift
//  14.86 - 14.80 - 14.73    14.57 - 14.42 (0.15) -14.07(0.35)  //  13.70 - 13.61 - 13.53 // 13.43 - 13.34 -13.25
import SwiftUI
import Foundation

import SwiftUI
import Foundation

class ClaudeAPIService {
    static let shared = ClaudeAPIService()
        private let baseURL = "https://api.anthropic.com/v1/messages"
        private let maxImageSize = 3 * 1024 * 1024
        private let session: URLSession
        private let maxRetries = 3
        
        private init() {
            // URLSession 설정
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 60  // 60초
            configuration.timeoutIntervalForResource = 300 // 5분
            configuration.waitsForConnectivity = true     // 연결이 불안정할 때 기다림
            self.session = URLSession(configuration: configuration)
        }
    
    private func compressImage(_ image: UIImage) -> Data? {
        // 초기 압축 품질
        var compression: CGFloat = 0.8
        let step: CGFloat = 0.1
        
        // 이미지 크기 조정 (가로 또는 세로가 2000픽셀을 넘지 않도록)
        let maxDimension: CGFloat = 2000.0
        var targetSize = image.size
        
        if targetSize.width > maxDimension || targetSize.height > maxDimension {
            let widthRatio = maxDimension / targetSize.width
            let heightRatio = maxDimension / targetSize.height
            let ratio = min(widthRatio, heightRatio)
            targetSize = CGSize(
                width: targetSize.width * ratio,
                height: targetSize.height * ratio
            )
        }
        
        // 이미지 리사이징
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage = resizedImage else { return nil }
        
        // 압축 품질을 조절하며 데이터 생성
        var imageData = finalImage.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxImageSize && compression > 0.1 {
            compression -= step
            imageData = finalImage.jpegData(compressionQuality: compression)
            print("Trying compression quality: \(compression), size: \(Double(data.count) / 1024 / 1024) MB")
        }
        
        if let finalData = imageData {
            let base64Size = Double(finalData.base64EncodedString().count) / 1024 / 1024
            print("Final base64 size: \(base64Size) MB")
        }
        
        return imageData
    }
    
    func generateQuestions(from image: UIImage) async throws -> [Question] {
            var attemptCount = 0
            let maxAttempts = 3
            
            while attemptCount < maxAttempts {
                do {
                    return try await generateQuestionsInternal(from: image)
                } catch let error as NSError {
                    attemptCount += 1
                    print("Attempt \(attemptCount) failed: \(error.localizedDescription)")
                    
                    if attemptCount == maxAttempts {
                        throw error
                    }
                    
                    // 재시도 전 지수 백오프 대기
                    let delay = pow(2.0, Double(attemptCount)) // 2, 4, 8초...
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
            
            throw APIError.networkError(NSError(domain: "APIError", code: -1,
                                              userInfo: [NSLocalizedDescriptionKey: "최대 재시도 횟수를 초과했습니다."]))
        }
        
        private func generateQuestionsInternal(from image: UIImage) async throws -> [Question] {
            guard let apiKey = APIKeyManager.shared.getClaudeAPIKey() else {
                throw APIError.missingAPIKey
            }
            
            // 이미지 압축
            guard let imageData = compressImage(image) else {
                throw APIError.invalidData
            }
            
            let base64Image = imageData.base64EncodedString()
            let base64Size = Double(base64Image.count) / 1024 / 1024
            
            guard base64Size <= 5.0 else {
                throw APIError.imageTooLarge
            }
            
            print("Image size: \(base64Size) MB")
            
            var request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.timeoutInterval = 60 // 요청별 타임아웃 설정
            
            let promptText = """
            Based on the image content, please create the following types of questions.
            Each question must be in exact JSON format:

            1. Multiple Choice (4 questions):
            {
             "questionType": "multipleChoice",
             "questionText": "Write your question here",
             "options": ["option1", "option2", "option3", "option4"],
             "correctAnswer": 0,
             "difficulty": "medium"
            }

            2. Fill in the Blank (4 questions):
            {
             "questionType": "fill-in-the-blank",
             "questionText": "Write the sentence with a _____ for the blank",
             "correctAnswer": "answer",
             "difficulty": "medium"
            }

            3. Matching (2 questions):
            Please follow this format exactly:
            {
             "questionType": "matching",
             "questionText": "Match the following words with their correct meanings",
             "matching": [
               {"word": "word1", "synonym": "meaning1"},
               {"word": "word2", "synonym": "meaning2"},
               {"word": "word3", "synonym": "meaning3"},
               {"word": "word4", "synonym": "meaning4"}
             ],
             "difficulty": "medium"
            }

            Important notes:
            - All JSON must be complete and properly formatted
            - Use double quotes (") for strings
            - Do not include commas after the last item in arrays
            - Each matching question must include exactly 4 word-meaning pairs
            - Keep each meaning/synonym concise (maximum 5 words)
            - Difficulties should be "easy", "medium", or "hard"
            - Make questions that test understanding, not just memorization
            - Each question should be relevant to the image content

            Please ensure each question follows the exact structure shown above.
            """
            
            let requestBody: [String: Any] = [
                "model": "claude-3-opus-20240229",
                "max_tokens": 4000,
                "messages": [
                    [
                        "role": "user",
                        "content": [
                            [
                                "type": "image",
                                "source": [
                                    "type": "base64",
                                    "media_type": "image/jpeg",
                                    "data": base64Image
                                ]
                            ],
                            [
                                "type": "text",
                                "text": promptText
                            ]
                        ]
                    ]
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if httpResponse.statusCode != 200 {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    throw APIError.invalidResponse
                }
                
                return try parseQuestionsFromResponse(data)
            } catch {
                print("Network error: \(error.localizedDescription)")
                throw APIError.networkError(error)
            }
        }
    
    func generateQuestionsProgressively(from image: UIImage) -> AsyncThrowingStream<Question, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    // 기존의 단일 API 호출로 모든 문제 생성
                    let allQuestions = try await generateQuestions(from: image)
                    
                    // 문제들을 점진적으로 yield
                    for question in allQuestions {
                        // 각 문제 사이에 약간의 딜레이를 주어 자연스러운 로딩 효과 생성
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초
                        continuation.yield(question)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func parseQuestionsFromResponse(_ data: Data) throws -> [Question] {
        let decoder = JSONDecoder()
        let response = try decoder.decode(ClaudeResponse.self, from: data)
        
        guard let contentText = response.content.first?.text else {
            throw APIError.noContent
        }
        
        print("\nRaw API Response:", contentText) // 전체 응답 확인용
        
        var questions: [Question] = []
        
        // 정규식 패턴 수정
        let pattern = "\\{\\s*\"questionType\"[^{]*\"matching\"\\s*:\\s*\\[[^\\]]*\\]\\s*,\\s*\"difficulty\"\\s*:\\s*\"[^\"]*\"\\s*\\}|\\{\\s*\"questionType\"[^}]*\\}"
        let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: contentText, range: NSRange(contentText.startIndex..., in: contentText))
        
        print("\nFound \(matches.count) potential question objects")
        
        for (index, match) in matches.enumerated() {
            if let range = Range(match.range, in: contentText) {
                let jsonString = String(contentText[range])
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("\nProcessing question #\(index + 1):")
                print(jsonString)
                
                do {
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        print("Failed to convert string to data")
                        continue
                    }
                    
                    guard let questionDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                        print("Failed to parse JSON")
                        continue
                    }
                    
                    guard let type = questionDict["questionType"] as? String else {
                        print("Missing questionType")
                        continue
                    }
                    
                    let question: Question?
                    switch type {
                    case "multipleChoice":
                        question = try createMultipleChoiceQuestion(from: questionDict)
                    case "fill-in-the-blank":
                        question = try createFillInBlankQuestion(from: questionDict)
                    case "matching":
                        print("\nProcessing matching question:")
                        print(questionDict)
                        question = try createMatchingQuestion(from: questionDict)
                    default:
                        print("Unknown question type:", type)
                        continue
                    }
                    
                    if let question = question {
                        questions.append(question)
                        print("Successfully created \(type) question")
                    }
                } catch {
                    print("Error processing question:", error)
                    print("JSON string:", jsonString)
                }
            }
        }
        
        // 문제 유형별 통계 출력
        print("\nFinal question counts:")
        print("Multiple Choice:", questions.filter { $0 is MultipleChoiceQuestion }.count)
        print("Fill in Blank:", questions.filter { $0 is FillInBlankQuestion }.count)
        print("Matching:", questions.filter { $0 is MatchingQuestion }.count)
        
        if questions.isEmpty {
            throw APIError.noContent
        }
        
        return questions
    }

    private func createMultipleChoiceQuestion(from dict: [String: Any]) throws -> MultipleChoiceQuestion? {
        do {
            guard let questionText = dict["questionText"] as? String,
                  let options = dict["options"] as? [String],
                  let correctAnswer = dict["correctAnswer"] as? Int,
                  let difficultyString = dict["difficulty"] as? String else {
                print("Invalid multiple choice question data:", dict)
                throw APIError.invalidFormat
            }
            
            guard let difficulty = Difficulty(rawValue: difficultyString.lowercased()),
                  options.count == 4 else {
                print("Invalid difficulty or options count:", dict)
                throw APIError.invalidFormat
            }
            
            return MultipleChoiceQuestion(
                difficulty: difficulty,
                category: "General",
                imageData: nil,
                questionText: questionText,
                options: options,
                correctAnswerIndex: correctAnswer,
                points: 10
            )
        } catch {
            print("Error creating multiple choice question:", error)
            return nil
        }
    }

    private func createFillInBlankQuestion(from dict: [String: Any]) throws -> FillInBlankQuestion? {
        do {
            guard let questionText = dict["questionText"] as? String,
                  let correctAnswer = dict["correctAnswer"] as? String,
                  let difficultyString = dict["difficulty"] as? String else {
                print("Invalid fill in blank question data:", dict)
                throw APIError.invalidFormat
            }
            
            guard let difficulty = Difficulty(rawValue: difficultyString.lowercased()) else {
                print("Invalid difficulty:", difficultyString)
                throw APIError.invalidFormat
            }
            
            return FillInBlankQuestion(
                difficulty: difficulty,
                category: "Vocabulary",
                imageData: nil,
                questionText: questionText,
                correctAnswer: correctAnswer,
                similarAcceptableAnswers: [],
                points: 10
            )
        } catch {
            print("Error creating fill in blank question:", error)
            return nil
        }
    }

    private func createMatchingQuestion(from dict: [String: Any]) throws -> MatchingQuestion? {
        print("\nCreating matching question from dict:", dict)
        
        guard let questionText = dict["questionText"] as? String else {
            print("Missing questionText")
            throw APIError.invalidFormat
        }
        
        guard let matching = dict["matching"] as? [[String: String]] else {
            print("Missing or invalid matching array")
            throw APIError.invalidFormat
        }
        
        guard let difficultyString = dict["difficulty"] as? String else {
            print("Missing difficulty")
            throw APIError.invalidFormat
        }
        
        guard let difficulty = Difficulty(rawValue: difficultyString.lowercased()) else {
            print("Invalid difficulty value:", difficultyString)
            throw APIError.invalidFormat
        }
        
        var leftItems: [String] = []
        var rightItems: [String] = []
        
        print("Processing matching pairs:", matching)
        
        for (_, pair) in matching.enumerated() {
            guard let word = pair["word"],
                  let match = pair["synonym"] else {
                print("Invalid pair:", pair)
                continue
            }
            
            leftItems.append(word)
            rightItems.append(match)
        }
        
        guard !leftItems.isEmpty && leftItems.count == rightItems.count else {
            print("Empty or mismatched items. Left:", leftItems.count, "Right:", rightItems.count)
            throw APIError.invalidFormat
        }
        
        return MatchingQuestion(
            difficulty: difficulty,
            category: "Vocabulary",
            imageData: nil,
            questionText: questionText,
            leftItems: leftItems,
            rightItems: rightItems,
            points: 10
        )
    }
}

struct ClaudeResponse: Codable {
    let id: String
    let content: [Content]
    
    struct Content: Codable {
        let type: String
        let text: String
    }
}

enum APIError: Error {
    case invalidResponse
    case invalidData
    case networkError(Error)
    case decodingError(Error)
    case missingAPIKey
    case imageTooLarge
    case noContent
    case invalidFormat
    
    var errorMessage: String {
        switch self {
        case .invalidResponse:
            return "서버로부터 유효하지 않은 응답을 받았습니다."
        case .invalidData:
            return "데이터를 처리할 수 없습니다."
        case .networkError(let error):
            return "네트워크 오류가 발생했습니다: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 변환 중 오류가 발생했습니다: \(error.localizedDescription)"
        case .missingAPIKey:
            return "API 키를 찾을 수 없습니다."
        case .imageTooLarge:
            return "이미지 크기가 너무 큽니다. 더 작은 이미지를 선택해주세요."
        case .noContent:
            return "API 응답에 내용이 없습니다."
        case .invalidFormat:
            return "응답 형식이 올바르지 않습니다."
        }
    }
}

