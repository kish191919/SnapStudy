
//  Views/Question/QuestionView.swift
import SwiftUI
import PhotosUI

struct QuestionView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    @State private var selectedImage: UIImage?
    @State private var isShowingCamera = false
    @State private var isShowingPhotoLibrary = false
    
    private func questionContent(for question: Question) -> some View {
            VStack {
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
            .animation(.default, value: viewModel.currentIndex)
        }
    
    var body: some View {
        ZStack {
            VStack {
                if !viewModel.questions.isEmpty {
                    // 진행 상황 표시
                    ProgressBar(
                        current: viewModel.currentIndex + 1,
                        total: viewModel.questions.count,
                        loadedCount: viewModel.loadedQuestionsCount
                    )
                    .padding()
                    
                    if let question = viewModel.currentQuestion {
                        questionContent(for: question)
                            .padding()
                            .transition(.slide)
                        
                        if viewModel.showFeedback {
                            FeedbackView(isCorrect: viewModel.isCorrect) {
                                withAnimation {
                                    viewModel.nextQuestion()
                                }
                            }
                            .transition(.scale)
                        }
                    }
                } else {
                    // 이미지 선택 버튼들
                    ImageSelectionButtons(
                        isShowingCamera: $isShowingCamera,
                        isShowingPhotoLibrary: $isShowingPhotoLibrary
                    )
                    .padding()
                }
            }
            
            // 로딩 상태 표시
            if case .loading = viewModel.loadingState {
                LoadingOverlay(
                    loadedCount: viewModel.loadedQuestionsCount
                )
            }
            
            // 에러 표시
            if case .error(let message) = viewModel.loadingState {
                ErrorView(message: message) {
                    viewModel.loadingState = .idle
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                viewModel.loadQuestions(from: image)
            }
        }
    }
}

// 새로운 보조 뷰들
struct ProgressBar: View {
    let current: Int
    let total: Int
    let loadedCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("문제 \(current)/\(total)")
                Spacer()
                if loadedCount < total {
                    Text("생성된 문제: \(loadedCount)")
                        .foregroundColor(.gray)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(current) / CGFloat(total))
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
    }
}

struct LoadingOverlay: View {
    let loadedCount: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Text("문제 생성 중...")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(loadedCount)개 생성됨")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

struct ErrorView: View {
    let message: String
    let dismissAction: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text("오류가 발생했습니다")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("확인") {
                dismissAction()
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ImageSelectionButtons: View {
    @Binding var isShowingCamera: Bool
    @Binding var isShowingPhotoLibrary: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { isShowingCamera = true }) {
                Label("카메라로 촬영", systemImage: "camera")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: { isShowingPhotoLibrary = true }) {
                Label("갤러리에서 선택", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
