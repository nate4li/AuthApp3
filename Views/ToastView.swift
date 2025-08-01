//
//  ToastView.swift
//  authApp3
//
//  Created by Nathaniel Monroe Jr on 7/23/25.
//


import SwiftUI

struct ToastView: View {
    
    let message: String
    
    var body: some View {
        
        Text(message)
                .font(.caption)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 10)
    }
}

#Preview {
    ToastView(message: "toast message")
}
