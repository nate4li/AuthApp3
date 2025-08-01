//
//  UserProfileView.swift
//  authApp3
//
//  Created by Nathaniel Monroe Jr on 7/23/25.
//

import Foundation
import SwiftUI
import UIKit


class ProfileImageManager {
    static let shared = ProfileImageManager()
    private init() {}

    private let filename = "profile.jpg"

    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(filename)
    }

    func save(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    func load() -> UIImage? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
}



//Image picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}




struct UserProfileView: View {
    
    @ObservedObject var mainViewModel : MainViewModel
    //variables
        @State private var profileImage: UIImage? = nil
        @State private var showingImagePicker = false
        @State private var selectedImage: UIImage?
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
                    
                VStack{
                    
                    Image("hglogotrans")
                        .resizable()
                        .scaledToFit()
                        .containerRelativeFrame(.horizontal){ size, axis in
                            size * 0.6
                        }
                        .clipShape(.capsule)
                   
            
                    Text("Welome, \(mainViewModel.email)")
                    .padding()
                    
                    //display user's username
                    Text("@" + (mainViewModel.databaseUser?.username ??  "No user logged in") )
                                   .font(.largeTitle)
                
                    
//                    Image(systemName: "person.fill")
//                        .font(.system(size:150))
//                        
                    
                    
                    
                    
                    Text("You are now signed in")
                        .padding()
                    
                    
                    //before picking image
                                        if let image = profileImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipShape(Circle())
                                                .shadow(radius: 4)
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 150, height: 150)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 100))
                                                )
                                        }

                                        Button("Change Picture") {
                                            showingImagePicker = true
                                        }
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.black)
                                        .cornerRadius(10)
                                        .padding(.top, 20)
                                        .padding(.bottom, 20)











                    NavigationLink{
                        ContentView(mainViewModel: mainViewModel)
                    } label: {
                        
                            Text("Get Started")
                        
                            Image(systemName: "house.fill")
                          
                        
                    }.font(.largeTitle)
                     .foregroundStyle(.black)
                     .padding(.bottom, 150)
                    
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: {
                                    if let selected = selectedImage {
                                        ProfileImageManager.shared.save(image: selected)
                                        profileImage = selected
                                    }
                                }) {
                                    ImagePicker(image: $selectedImage)

                                }
            
            
            
        }.onAppear {
            mainViewModel.fetchCurrentUserEmail()
            mainViewModel.fetchUserData()
        }
        
    }
}

#Preview {
    UserProfileView(mainViewModel: MainViewModel())
}
