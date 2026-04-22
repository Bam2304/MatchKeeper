//
//  AuthViewModel.swift
//  MatchKeeper
//
//  Created by Jessica Gutierrez on 4/16/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    func startListening() {
        guard authStateListenerHandle == nil else {
            return
        }
        guard FirebaseApp.app() != nil else {
            return
        }
        user = Auth.auth().currentUser
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }
    
    deinit {
        guard let authStateListenerHandle else {
            return
        }
        Auth.auth().removeStateDidChangeListener(authStateListenerHandle)
    }
    
    var isSignedIn: Bool {
        user != nil
    }
    
    func signIn(email: String, password: String) {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessage = "Enter both email and password."
            return
        }
        
        errorMessage = nil
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            Task { @MainActor in
                self?.isLoading = false
                if let error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signUp(name: String, email: String, password: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessage = "Enter your name, email, and password."
            return
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = nil
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            Task { @MainActor in
                if let error {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let user = authResult?.user else {
                    self?.isLoading = false
                    self?.errorMessage = "Could not create account. Please try again."
                    return
                }

                let profileChangeRequest = user.createProfileChangeRequest()
                profileChangeRequest.displayName = trimmedName
                profileChangeRequest.commitChanges { [weak self] error in
                    Task { @MainActor in
                        self?.isLoading = false
                        if let error {
                            self?.errorMessage = error.localizedDescription
                            self?.user = Auth.auth().currentUser
                            return
                        }
                        self?.user = Auth.auth().currentUser
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
