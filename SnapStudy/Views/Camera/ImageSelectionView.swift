
//  Views/Camera/ImageSelectionView.swift
import SwiftUI

struct ImageSelectionView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack(spacing: 20) {
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
                    Label("카메라로 촬영", systemImage: "camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    sourceType = .photoLibrary
                    isShowingImagePicker = true
                }) {
                    Label("갤러리에서 선택", systemImage: "photo")
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
