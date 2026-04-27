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
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var passwordChangeMessage: String?
    @Published var isLoading = false
    @Published var profileName = ""
    @Published var profileBio = ""
    @Published var favoriteTeam = ""
    @Published var gamesSavedCount = 0
    @Published var dateJoined: Date?
    @Published var profileImageURL = ""
    @Published var averageRating: Double = 0.0
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var profileListener: ListenerRegistration?
    
    func startListening() {
        guard authStateListenerHandle == nil else {
            return
        }
        guard FirebaseApp.app() != nil else {
            return
        }
        user = Auth.auth().currentUser
        if user != nil {
            fetchUserProfile()
        }
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                if user != nil {
                    self?.fetchUserProfile()
                } else {
                    self?.profileListener?.remove()
                    self?.profileListener = nil
                    self?.passwordChangeMessage = nil
                    self?.profileName = ""
                    self?.profileBio = ""
                    self?.favoriteTeam = ""
                    self?.gamesSavedCount = 0
                    self?.dateJoined = nil
                    self?.profileImageURL = ""
                    self?.averageRating = 0.0
                }
            }
        }
    }
    
    deinit {
        profileListener?.remove()
        guard let authStateListenerHandle else {
            return
        }
        Auth.auth().removeStateDidChangeListener(authStateListenerHandle)
    }
    
    var isSignedIn: Bool {
        user != nil
    }

    private enum UserField {
        static let name = "name"
        static let email = "email"
        static let bio = "bio"
        static let dateJoined = "dateJoined"
        static let legacyDateJoined = "datejoined"
        static let favoriteTeam = "favoriteteam"
        static let gamesSavedCount = "gamesSavedCount"
        static let legacyGamesSavedCount = "gamesavedCount"
        static let profileImageURL = "profileImageURL"
    }

    private func upsertUserDocument(for user: User, name: String, completion: @escaping @Sendable (Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        userRef.setData([
            UserField.name: name,
            UserField.email: user.email ?? "",
            UserField.dateJoined: Timestamp(date: Date()),
            UserField.bio: "",
            UserField.favoriteTeam: "",
            UserField.gamesSavedCount: 0,
            UserField.profileImageURL: ""
        ], merge: true, completion: completion)
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        profileListener?.remove()
        profileListener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    guard let data = snapshot?.data() else {
                        self?.profileName = ""
                        self?.profileBio = ""
                        self?.favoriteTeam = ""
                        self?.gamesSavedCount = 0
                        self?.dateJoined = nil
                        self?.profileImageURL = ""
                        self?.averageRating = 0.0
                        return
                    }

                    self?.profileName = data[UserField.name] as? String ?? ""
                    self?.profileBio = data[UserField.bio] as? String ?? ""
                    self?.favoriteTeam = data[UserField.favoriteTeam] as? String ?? ""
                    self?.gamesSavedCount = (data[UserField.gamesSavedCount] as? Int)
                        ?? (data[UserField.legacyGamesSavedCount] as? Int)
                        ?? 0
                    self?.profileImageURL = data[UserField.profileImageURL] as? String ?? ""

                    let joinedTimestamp = (data[UserField.dateJoined] as? Timestamp)
                        ?? (data[UserField.legacyDateJoined] as? Timestamp)
                    self?.dateJoined = joinedTimestamp?.dateValue()
                    
                    self?.fetchAverageRating(for: uid)
                }
            }
    }
    
    private func fetchAverageRating(for uid: String) {
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("savedGames")
            .getDocuments { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    guard let snapshot, error == nil else {
                        self.averageRating = 0.0
                        return
                    }
                    
                    var totalRating = 0
                    var ratedGames = 0
                    
                    for document in snapshot.documents {
                        let data = document.data()
                        if let rating = data["rating"] as? Int {
                            totalRating += rating
                            ratedGames += 1
                        } else if let rating = data["rating"] as? Int64 {
                            totalRating += Int(rating)
                            ratedGames += 1
                        } else if let rating = data["rating"] as? NSNumber {
                            totalRating += rating.intValue
                            ratedGames += 1
                        }
                    }
                    
                    self.averageRating = ratedGames > 0 ? Double(totalRating) / Double(ratedGames) : 0.0
                }
            }
    }

    func updateProfileImageURL(_ urlString: String, completion: ((Bool) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(false)
            return
        }

        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedURL: String

        if trimmedURL.isEmpty {
            normalizedURL = ""
        } else {
            let withScheme = trimmedURL.hasPrefix("http://") || trimmedURL.hasPrefix("https://")
                ? trimmedURL
                : "https://\(trimmedURL)"

            guard let components = URLComponents(string: withScheme),
                  let scheme = components.scheme?.lowercased(),
                  ["http", "https"].contains(scheme),
                  components.host != nil else {
                errorMessage = "Please enter a valid image URL (http or https)."
                completion?(false)
                return
            }

            normalizedURL = withScheme
        }

        if !normalizedURL.isEmpty, URL(string: normalizedURL) == nil {
            errorMessage = "Please enter a valid image URL."
            completion?(false)
            return
        }

        isLoading = true
        errorMessage = nil

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData([
                UserField.profileImageURL: normalizedURL
            ], merge: true) { [weak self] error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    if let error {
                        self.errorMessage = error.localizedDescription
                        completion?(false)
                        return
                    }
                    self.profileImageURL = normalizedURL
                    self.errorMessage = nil
                    completion?(true)
                }
            }
    }

    func updateProfile(name: String, bio: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData([
                UserField.name: trimmedName,
                UserField.bio: trimmedBio
            ], merge: true) { [weak self] error in
                Task { @MainActor [weak self] in
                    if let error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.errorMessage = nil
                    self?.profileName = trimmedName
                    self?.profileBio = trimmedBio
                }
            }
    }

    func changePassword(newPassword: String, completion: @escaping (Bool) -> Void = { _ in }) {
        let trimmedPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPassword.isEmpty else {
            errorMessage = "Password cannot be empty."
            completion(false)
            return
        }

        guard trimmedPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            completion(false)
            return
        }

        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No signed-in user found."
            completion(false)
            return
        }

        errorMessage = nil
        passwordChangeMessage = nil
        isLoading = true
        currentUser.updatePassword(to: trimmedPassword) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                self?.passwordChangeMessage = "Password updated successfully."
                completion(true)
            }
        }
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
                        if let error {
                            self?.isLoading = false
                            self?.errorMessage = error.localizedDescription
                            self?.user = Auth.auth().currentUser
                            return
                        }

                        self?.upsertUserDocument(for: user, name: trimmedName) { firestoreError in
                            Task { @MainActor in
                                self?.isLoading = false
                                if let firestoreError {
                                    self?.errorMessage = firestoreError.localizedDescription
                                }
                                self?.user = Auth.auth().currentUser
                            }
                        }
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void = { _ in }) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            completion(false)
            return
        }
        
        errorMessage = nil
        passwordChangeMessage = nil
        isLoading = true
        
        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                self?.passwordChangeMessage = "Password reset email sent to \(trimmedEmail). Please check your inbox."
                completion(true)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            passwordChangeMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
