//
//  LoginView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewController()
    
    var body: some View {
        List {
            Section {
                VStack {
                    Image(systemName: "light.beacon.max")
                        .font(.system(size: 96))
                        .foregroundStyle(.tint)
                        .shadow(color: .accentColor, radius: 64)
                        .padding()
                    
                    Text("Welcome to Pagrr!")
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text("Get push notifications from your services, without the hassle.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 15)
            }
            
            Section("Sign In") {
                VStack {
                    Button {
                        viewModel.startSignInWithAppleFlow()
                    } label: {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
                    }
                    .buttonStyle(.glassProminent)
                    .buttonSizing(.flexible)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
