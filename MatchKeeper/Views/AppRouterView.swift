//
//  AppRouterView.swift
//  MatchKeeper
//
//  Created by Jessica Gutierrez on 4/16/26.
//

import SwiftUI
import FirebaseAuth

struct AppRouterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dM: DataManager
    @State private var showSignUp = false
    
    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                BaseView()
            } else {
                if showSignUp {
                    SignUpView {
                        authViewModel.errorMessage = nil
                        showSignUp = false
                    }
                } else {
                    LoginView {
                        authViewModel.errorMessage = nil
                        showSignUp = true
                    }
                }
            }
        }
        .task {
            authViewModel.startListening()
        }
        .task(id: authViewModel.user?.uid) {
            if authViewModel.isSignedIn {
                dM.loadSavedGames()
            } else {
                dM.matchList = []
            }
        }
    }
}

#Preview {
    AppRouterView()
        .environmentObject(DataManager())
        .environmentObject(AuthViewModel())
}
