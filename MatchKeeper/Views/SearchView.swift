//
//  SearchView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/13/26.
//

import SwiftUI

struct SearchView: View {
    @State private var match: String = ""
    @State private var date: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                VStack(spacing: 20) {
                    
                    Text("Search For A Match!")
                        .font(.system(size: 35))
                        .fontDesign(.serif)
                        .foregroundStyle(.green)
                        .bold()
                    
                    TextField("Matchup (Team A vs Team B)", text: $match)
                        .autocapitalization(.none)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )
                    
                    TextField("Date (m/d/y)", text: $date)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )
                    
                    Button(action: {
                        //logic for search
                    }, label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                    })
                    .frame(width: 110, height: 35)
                    .background(Color.green)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
                }
                .padding(15)
                
                
                
                //navigation link appears once search return
                
                Spacer()
            }
        }
        
    }
}

#Preview {
    SearchView()
}
