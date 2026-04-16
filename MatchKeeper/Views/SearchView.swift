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
    @StateObject private var fetcher = matchFetcher()
    
    
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
                    
                    TextField("Date (yyyy-m-d)", text: $date)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green)
                        )
                    
                    Button(action: {
                        //logic for search
                        Task {
                            try await fetcher.getMatch(matchup: match, date: date)
                        }
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
                
                //if the match has loaded, display it, else show placeholders
                //navigation link appears once search return
                if let match = fetcher.returnedMatch {
                    NavigationLink {
                        MatchDetailView(thisMatch: match)
                    } label: {
                        HStack(spacing: 15) {
                            AsyncImage(url: URL(string: match.strThumb ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 80)
                            .clipped()
                            .cornerRadius(8)
                            
                            Text(match.strEvent ?? "")
                                .font(.headline)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    
                } else {
                    Text("No Match Found Currently...")
                        .foregroundColor(.gray)
                }
                
                
                
                Spacer()
            }
        }
        
    }
}

#Preview {
    SearchView()
}
