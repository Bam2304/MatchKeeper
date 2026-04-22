//
//  BaseView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/11/26.
//

import SwiftUI

struct BaseView: View {
    @State private var selected: MenuItem = .home
    @State private var showMenu: Bool = false
    @EnvironmentObject var dM: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack(alignment: .leading){
            NavigationStack{
                ViewThatFits
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading) {
                            Button{
                                withAnimation{
                                    showMenu.toggle()
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing){
                            Button{
                                authViewModel.signOut()
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
            }
            
            if showMenu{
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                    .zIndex(1)
            }
            
            SideMenuView(selectedMenuItem: $selected, showMenu: $showMenu)
                .offset(x: showMenu ? 0 : -200)
                .zIndex(2)
        }
        .animation(.easeInOut(duration: 0.25), value: showMenu)
    }
    
    
    @ViewBuilder
    var ViewThatFits: some View {
        switch selected {
        case .home:
            HomeView()
                .environmentObject(dM)
        case .profile:
            ProfileView()
                .environmentObject(authViewModel)
        case .search:
            SearchView()
                .environmentObject(dM)
        }
    }
}

#Preview {
    BaseView()
        .environmentObject(DataManager())
    .environmentObject(AuthViewModel())
}
