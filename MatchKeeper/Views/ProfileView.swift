//
//  ProfileView.swift
//  MatchKeeper
//
//  Created by GitHub Copilot on 4/21/26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoImage: Image?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader

                VStack(alignment: .leading, spacing: 16) {
                    profileRow(title: "Name", value: displayName)
                    profileRow(title: "Date Joined", value: joinedDate)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedPhotoImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            Group {
                if let selectedPhotoImage {
                    selectedPhotoImage
                        .resizable()
                        .scaledToFill()
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

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Text("Add Profile Picture")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }

            Text("Photo is currently previewed locally. Cloud saving can be added next.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    private var displayName: String {
        if let name = authViewModel.user?.displayName,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return "Name not set"
    }

    private var joinedDate: String {
        guard let creationDate = authViewModel.user?.metadata.creationDate else {
            return "Unavailable"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: creationDate)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
