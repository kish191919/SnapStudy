
//  Views/Camera/ImageSelectionView.swift
import SwiftUI

// 이미지 선택 뷰 예시
struct ImageSelectionView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    sourceType = .camera
                    isShowingImagePicker = true
                }) {
                    Label("카메라", systemImage: "camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    sourceType = .photoLibrary
                    isShowingImagePicker = true
                }) {
                    Label("갤러리", systemImage: "photo")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
    }
}
