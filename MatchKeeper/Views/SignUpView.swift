//
//  SignUpView.swift
//  MatchKeeper
//
//  Created by Jessica Gutierrez on 4/16/26.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localErrorMessage: String?
    let onTapLogIn: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 14) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )

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

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )

                    if let localErrorMessage {
                        Text(localErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    } else if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        guard password == confirmPassword else {
                            localErrorMessage = "Passwords do not match."
                            return
                        }
                        localErrorMessage = nil
                        authViewModel.signUp(name: name, email: email, password: password)
                        onTapLogIn()
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign Up")
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

                    Button(action: onTapLogIn) {
                        Text("Already have an account? Log In")
                            .foregroundStyle(.green)
                            .fontWeight(.medium)
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                Text("MATCHKEEPER")
                    .font(.system(size: 45))
                    .fontDesign(.serif)
                    .foregroundStyle(.green)
                    .bold()
                    .padding(.top, geometry.size.height * 0.23)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    SignUpView(onTapLogIn: {})
        .environmentObject(AuthViewModel())
}
