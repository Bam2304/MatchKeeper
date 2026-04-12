//
//  ContentView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/11/26.
//

import SwiftUI



struct HomeView: View {
    var body: some View {
        VStack {
            Text("WELCOME!")
                .font(.system(size: 55))
                .fontDesign(.serif)
                .foregroundStyle(.green)
                .bold()
            
            Spacer()
        }
        
    }
}

#Preview {
    HomeView()
}
