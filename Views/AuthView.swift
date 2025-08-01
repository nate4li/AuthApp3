//
//  AuthView.swift
//  authApp3
//
//  Created by Nathaniel Monroe Jr on 7/23/25.
//

import SwiftUI

struct AuthView: View {
    
    @ObservedObject var mainViewModel : MainViewModel
    
    var body: some View {
        
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            //display an image
            Image("Nlogo")
                .resizable()
                .scaledToFit()
                .containerRelativeFrame(.horizontal){
                    size, axis in size * 0.6
                }.clipShape(.capsule).padding(.bottom, 500)
            
            VStack(spacing: 16){
                Spacer()
                    .frame(height: 100)
                
                emailTextField
                
                if mainViewModel.showSignInView == false {
                    usernameTextField
                }
                
                passwordTextField
            
                actionButton
            
                toggleButton
            
            }
            .padding()
            
            
            if mainViewModel.showToast {
                ToastView(message: mainViewModel.toastMessage)
                    .padding(.top, 50)
                    .transition(.opacity)
                    .animation(
                        .easeIn(duration: 0.8),
                      value: mainViewModel.showToast
                    )
            }
            
            
        } //end of zsack
    } //end of body{}
    
    
    //Reusabele Views go here
    
    private var emailTextField: some View {
        HStack{
            TextField("Email", text: $mainViewModel.email)
                .padding()
                .foregroundStyle(.black)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }.background()
    }
    

    private var passwordTextField: some View {
            
            HStack{
                if mainViewModel.isPasswordVisible {
                    TextField("Password", text: $mainViewModel.password)
                        .padding()
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }else{
                    
                    SecureField("Password", text: $mainViewModel.password)
                        .padding()
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
              
                //Eye button to toggle secure field
                Button {
                    mainViewModel.isPasswordVisible.toggle()
                } label: {
                    Image(systemName: mainViewModel.isPasswordVisible ? "eye.slash" : "eye"
                    ).foregroundStyle(.black)
                    
                }.padding(.trailing, 8)
                
            }
            .background()
        
        
    } // end of reusable password view
    
    //UserName
    private var usernameTextField: some View {
        HStack{
            TextField("Username", text: $mainViewModel.username)
                .padding()
                .foregroundStyle(.black)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }.background()
    } // end of reusable username view
    
    
    //Sign in Or Sign UP Button
    private var actionButton: some View {
        Button {
  
            if mainViewModel.showSignInView{
                mainViewModel.signIn()
            }else{
                mainViewModel.signUp()
            }
        } label: {
    
            Text(mainViewModel.showSignInView ? "Sign In" : "Sign Up")
                .font(.headline)
                .foregroundColor(
            mainViewModel.isValidEmail() ? .white : .black
                )
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    mainViewModel.isValidEmail() ? Color.green : Color.gray
                )
                .cornerRadius(10)

        }
        .disabled(!mainViewModel.isValidEmail())
    } //end of actionButton
    
    

    //Toggle view button to show Sign Up ir Sign In View
    private var toggleButton: some View {
        Button {
          
            mainViewModel.showSignInView.toggle()
          
        } label: {
            Text(
            mainViewModel.showSignInView ? "Don't have account? Sign Up"
                : "Already have an account? Sign In"
            )
                .font(.headline)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                mainViewModel.showSignInView ? Color.red : Color.black
                )
                .cornerRadius(10)

        }
    }
    

} // end of AuthView{}


#Preview {
    AuthView(mainViewModel: MainViewModel())
}


