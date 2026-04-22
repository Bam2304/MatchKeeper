//
//  LoginView.swift
//  MatchKeeper
//
//  Created by Jessica Gutierrez on 4/16/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    let onTapSignUp: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 14) {
                    // app logo
                    Image("logo").resizable()
                        .scaledToFit()
                        .scaleEffect(1.5)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        .frame(width: 280, height: 280)
                        .padding(15)
                    
                    
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )

                    SecureField("Password", text: $password)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        authViewModel.signIn(email: email, password: password)
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .disabled(authViewModel.isLoading)

                    Button(action: onTapSignUp) {
                        Text("Need an account? Sign Up")
                            .foregroundStyle(.green)
                            .fontWeight(.medium)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 108)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    LoginView(onTapSignUp: {})
        .environmentObject(AuthViewModel())
}
