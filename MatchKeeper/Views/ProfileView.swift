//
//  ProfileView.swift
//  MatchKeeper
//
//  Created by Jessica Gutierrez on 4/21/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var editableName = ""
    @State private var editableBio = ""
    @State private var editableProfileImageURL = ""
    @State private var isEditSheetPresented = false
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPasswordAlert = false
    @State private var passwordAlertMessage = ""
    @State private var passwordAlertTitle = ""

    var body: some View {
        List {
            Section {
                profileHeader
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            }

            Section("Profile") {
                profileRow(title: "Name", value: displayName)
                profileRow(title: "Date Added", value: joinedDate)
                profileRow(title: "Bio", value: bioText)
                profileRow(title: "Most Watched Team", value: favoriteTeamText)
                profileRow(title: "Games Saved", value: "\(authViewModel.gamesSavedCount)")
                profileRow(title: "Average Rating", value: averageRatingText)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    hydrateEditableProfileFields()
                    isEditSheetPresented = true
                }
            }
        }
        .sheet(isPresented: $isEditSheetPresented) {
            NavigationStack {
                Form {
                    Section("Edit Profile") {
                        TextField("Name", text: $editableName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()

                        TextField("Profile Image URL", text: $editableProfileImageURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .textContentType(.URL)

                        Text("Use a direct image URL like \"https://.../photo.jpg\" or \"https://.../photo.png\". Google Images links, Instagram/Twitter page URLs, or any URL that opens a website (instead of the image file itself) will not work.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextEditor(text: $editableBio)
                                .frame(minHeight: 110)
                        }
                    }

                    Section("Change Password") {
                        SecureField("New Password", text: $newPassword)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            isEditSheetPresented = false
                            newPassword = ""
                            confirmPassword = ""
                            authViewModel.errorMessage = nil
                            authViewModel.passwordChangeMessage = nil
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            handleSaveWithPasswordChange()
                        }
                        .disabled(editableName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .onAppear {
            hydrateEditableProfileFields()
            authViewModel.fetchUserProfile()
        }
        .alert(passwordAlertTitle, isPresented: $showPasswordAlert) {
            Button("OK") { }
        } message: {
            Text(passwordAlertMessage)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            Group {
                if let remoteURL = URL(string: authViewModel.profileImageURL),
                          !authViewModel.profileImageURL.isEmpty {
                    AsyncImage(url: remoteURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(.green)
                        case .empty:
                            ProgressView()
                                .progressViewStyle(.circular)
                        @unknown default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(.green)
                        }
                    }
                    .id(authViewModel.profileImageURL)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.green)
                }
            }
            .frame(width: 130, height: 130)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.green, lineWidth: 3))

            Text("Set your profile image by URL in Edit Profile.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let errorMessage = authViewModel.errorMessage,
               !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }

    private var displayName: String {
        if !authViewModel.profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return authViewModel.profileName
        }

        if let name = authViewModel.user?.displayName,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return "Name not set"
    }

    private var joinedDate: String {
        let dateToDisplay: Date?
        if let firestoreDate = authViewModel.dateJoined {
            dateToDisplay = firestoreDate
        } else {
            dateToDisplay = authViewModel.user?.metadata.creationDate
        }

        guard let dateToDisplay else {
            return "Unavailable"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dateToDisplay)
    }

    private var bioText: String {
        let trimmedBio = authViewModel.profileBio.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedBio.isEmpty ? "No bio added" : trimmedBio
    }

    private var favoriteTeamText: String {
        let trimmedTeam = authViewModel.favoriteTeam.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTeam.isEmpty ? "No most watched team yet" : trimmedTeam
    }
    
    private var averageRatingText: String {
        if authViewModel.averageRating == 0 {
            return "No ratings yet"
        }
        return String(format: "%.1f", authViewModel.averageRating) + " / 5.0"
    }

    private func hydrateEditableProfileFields() {
        if !authViewModel.profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            editableName = authViewModel.profileName
        } else if let authName = authViewModel.user?.displayName,
                  !authName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            editableName = authName
        }

        editableBio = authViewModel.profileBio
        editableProfileImageURL = authViewModel.profileImageURL
    }
    
    private func handleSaveWithPasswordChange() {
        let hasNewPassword = !newPassword.isEmpty
        let hasConfirmPassword = !confirmPassword.isEmpty
        
        // Check for incomplete password entries
        if hasNewPassword && !hasConfirmPassword {
            passwordAlertTitle = "Password Incomplete"
            passwordAlertMessage = "Please enter your confirm password."
            showPasswordAlert = true
            return
        }
        
        if !hasNewPassword && hasConfirmPassword {
            passwordAlertTitle = "Password Incomplete"
            passwordAlertMessage = "Please enter your new password."
            showPasswordAlert = true
            return
        }
        
        // If both password fields are filled, validate and change
        if hasNewPassword && hasConfirmPassword {
            if newPassword != confirmPassword {
                passwordAlertTitle = "Passwords Do Not Match"
                passwordAlertMessage = "Please ensure both password fields match."
                showPasswordAlert = true
                return
            }
            
            // Change password with completion handler
            authViewModel.changePassword(newPassword: newPassword) { success in
                if success {
                    passwordAlertTitle = "Password Changed"
                    passwordAlertMessage = "Your password has been successfully updated."
                } else {
                    passwordAlertTitle = "Password Change Failed"
                    passwordAlertMessage = authViewModel.errorMessage ?? "An error occurred while changing your password."
                }
                showPasswordAlert = true
            }
            
            newPassword = ""
            confirmPassword = ""
        }
        
        // Always save profile updates
        authViewModel.updateProfile(name: editableName, bio: editableBio)
        authViewModel.updateProfileImageURL(editableProfileImageURL) { success in
            if success {
                authViewModel.errorMessage = nil
                isEditSheetPresented = false
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
