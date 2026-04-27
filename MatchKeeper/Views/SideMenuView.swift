//
//  SideMenuView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/11/26.
//

import SwiftUI

enum MenuItem: String, Identifiable, CaseIterable {
    case home
    case profile
    case search
    case savedGames
    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .profile:
            return "Profile"
        case .search:
            return "Search"
        case .savedGames:
            return "Saved Games"
        }
    }
    var icon: String{
        switch self{
        case .home:
            return "house"
        case .profile:
            return "person"
        case .search:
            return "magnifyingglass"
        case .savedGames:
            return "bookmark"
        }
    }
}

struct SideMenuView: View {
    @Binding var selectedMenuItem: MenuItem
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25){
            Text("Menu")
                .font(.largeTitle.bold())
                .padding(.top, 60)
            
            ForEach(MenuItem.allCases){ item in
                Button{
                    withAnimation{
                        selectedMenuItem = item
                        showMenu = false
                    }
                } label: {
                    Label(item.title, systemImage: item.icon)
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 200)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}




#Preview {
    //SideMenuView()
}
