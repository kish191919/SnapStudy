
//  Models/ClaudeAPIService.swift
//  14.86 - 14.80 - 14.73    14.57 - 14.42
import SwiftUI
import Foundation

import SwiftUI
import Foundation

class ClaudeAPIService {
    static let shared = ClaudeAPIService()
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let maxImageSize = 3 * 1024 * 1024 // base64 인코딩 후 크기 증가를 고려하여 3MB로 제한
    
    private init() {}
    
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
    
    private func generateQuestions(from image: UIImage) async throws -> [Question] {
        guard let apiKey = APIKeyManager.shared.getClaudeAPIKey() else {
            throw APIError.missingAPIKey
        }
        
        guard let imageData = compressImage(image) else {
            throw APIError.invalidData
        }
        
        let base64Image = imageData.base64EncodedString()
        let base64Size = Double(base64Image.count) / 1024 / 1024
        
        guard base64Size <= 5.0 else {
            print("Image still too large after compression: \(base64Size) MB")
            throw APIError.invalidData
        }
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
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
                            "text": """
                            이 이미지의 내용을 바탕으로 다양한 유형의 문제를 만들어주세요:
                            1. 4지선다형 문제 8개
                            2. 빈칸 채우기 문제 8개
                            3. 매칭 문제 4개
                            
                            각 문제의 난이도를 easy, medium, hard로 적절히 분배해주세요.
                            문제는 단순 암기가 아닌 이해와 분석이 필요한 형태로 만들어주세요.
                            
                            각 문제는 아래 JSON 형식으로 제공해주세요:

                            4지선다형:
                            {
                              "questionType": "multipleChoice",
                              "questionText": "문제 내용",
                              "options": ["보기1", "보기2", "보기3", "보기4"],
                              "correctAnswer": 0,
                              "difficulty": "medium"
                            }

                            빈칸 채우기:
                            {
                              "questionType": "fill-in-the-blank",
                              "questionText": "문제 내용 _____ 빈칸이 있는 문장",
                              "correctAnswer": "정답",
                              "difficulty": "medium"
                            }

                            매칭:
                            {
                              "questionType": "matching",
                              "questionText": "매칭 지시문",
                              "matching": [
                                {"word": "단어1", "synonym": "매칭1"},
                                {"word": "단어2", "synonym": "매칭2"},
                                {"word": "단어3", "synonym": "매칭3"},
                                {"word": "단어4", "synonym": "매칭4"}
                              ],
                              "difficulty": "medium"
                            }
                            """
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorInfo = errorJson["error"] as? [String: Any],
               let errorMessage = errorInfo["message"] as? String {
                print("API Error: \(errorMessage)")
            }
            print("Status Code: \(httpResponse.statusCode)")
            print("Raw Response: \(String(data: data, encoding: .utf8) ?? "")")
            throw APIError.invalidResponse
        }
        
        return try parseQuestionsFromResponse(data)
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
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(ClaudeResponse.self, from: data)
            
            guard let contentText = response.content.first?.text else {
                throw APIError.noContent
            }
            
            var questions: [Question] = []
            
            // 각 JSON 객체를 찾아서 파싱
            let pattern = "\\{[^\\{\\}]*\\}"
            let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
            let matches = regex.matches(in: contentText, range: NSRange(contentText.startIndex..., in: contentText))
            
            for match in matches {
                guard let range = Range(match.range, in: contentText),
                      let jsonData = String(contentText[range]).data(using: .utf8),
                      let questionDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    continue
                }
                
                if let type = questionDict["questionType"] as? String {
                    switch type {
                    case "multipleChoice":
                        if let question = try createMultipleChoiceQuestion(from: questionDict) {
                            questions.append(question)
                        }
                    case "fill-in-the-blank":
                        if let question = try createFillInBlankQuestion(from: questionDict) {
                            questions.append(question)
                        }
                    case "matching":
                        if let question = try createMatchingQuestion(from: questionDict) {
                            questions.append(question)
                        }
                    default:
                        print("Unknown question type: \(type)")
                    }
                }
            }
            
            print("Successfully parsed \(questions.count) questions")
            return questions
            
        } catch {
            print("Parsing error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func createMultipleChoiceQuestion(from dict: [String: Any]) throws -> MultipleChoiceQuestion? {
        guard let questionText = dict["questionText"] as? String,
              let options = dict["options"] as? [String],
              let correctAnswer = dict["correctAnswer"] as? Int,
              let difficultyString = dict["difficulty"] as? String,
              let difficulty = Difficulty(rawValue: difficultyString) else {
            return nil
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
    }
    
    private func createFillInBlankQuestion(from dict: [String: Any]) throws -> FillInBlankQuestion? {
        guard let questionText = dict["questionText"] as? String,
              let correctAnswer = dict["correctAnswer"] as? String,
              let difficultyString = dict["difficulty"] as? String,
              let difficulty = Difficulty(rawValue: difficultyString) else {
            return nil
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
    }
    
    private func createMatchingQuestion(from dict: [String: Any]) throws -> MatchingQuestion? {
        guard let questionText = dict["questionText"] as? String,
              let matching = dict["matching"] as? [[String: String]],
              let difficultyString = dict["difficulty"] as? String,
              let difficulty = Difficulty(rawValue: difficultyString) else {
            return nil
        }
        
        var leftItems: [String] = []
        var rightItems: [String] = []
        var correctPairs: [(Int, Int)] = []
        
        for (index, pair) in matching.enumerated() {
            if let word = pair["word"], let match = pair["synonym"] ?? pair["antonym"] {
                leftItems.append(word)
                rightItems.append(match)
                correctPairs.append((index, index))
            }
        }
        
        return MatchingQuestion(
            difficulty: difficulty,
            category: "Vocabulary",
            imageData: nil,
            questionText: questionText,
            leftItems: leftItems,
            rightItems: rightItems,
            correctPairs: correctPairs,
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

