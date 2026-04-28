//
//  SavedGamesView.swift
//  MatchKeeper
//
//  Created by Jessica Gutierrez on 4/27/26.
//

import SwiftUI

struct SavedGamesView: View {
    @EnvironmentObject var dM: DataManager
    
    var body: some View {
        VStack {
            Text("SAVED GAMES")
                .font(.system(size: 55))
                .fontDesign(.serif)
                .foregroundStyle(.green)
                .bold()
            
            if dM.matchList.isEmpty {
                Text("You have no matches saved yet. Try searching for one and saving it now!")
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .font(.title3)
            }
            
            List {
                ForEach(dM.matchList) { match in
                    NavigationLink {
                        MatchDetailView(thisMatch: match)
                            .environmentObject(dM)
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
                }
                .onDelete(perform: dM.removeMatch) // swipe to delete match
            }
            
            Spacer()
        }
    }
}

#Preview {
    SavedGamesView()
        .environmentObject(DataManager())
}
