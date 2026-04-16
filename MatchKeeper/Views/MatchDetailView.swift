//
//  MatchDetailView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/15/26.
//

import SwiftUI
import WebKit
import YouTubePlayerKit


struct MatchDetailView: View {
    var thisMatch: Match
    @State var journalText: String = ""
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                Text(thisMatch.strEvent ?? "")
                    .font(.title)
                    .fontDesign(.serif)
                    .foregroundStyle(.green)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("\(thisMatch.intHomeScore ?? "") - \(thisMatch.intAwayScore ?? "")")
                    .font(.title)
                    .fontDesign(.serif)
                    .foregroundStyle(.green)
                    
                
                Text("Competition: \(thisMatch.strLeague ?? "")")
                    .font(.system(size: 18))
                    .fontDesign(.serif)
                    .foregroundStyle(.green)
                
                Text("Venue: \(thisMatch.strVenue ?? "")")
                    .font(.system(size: 18))
                    .fontDesign(.serif)
                    .foregroundStyle(.green)
                
                Text("Date: \(thisMatch.dateEvent ?? "")")
                    .font(.system(size: 18))
                    .fontDesign(.serif)
                    .foregroundStyle(.green)
                
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Journal Your Experience Below!:")
                        .fontDesign(.serif)
                        .foregroundStyle(.green)
                        .underline()
                        .padding(.leading, 10)
                    TextField("", text: $journalText,  axis: .vertical)
                        .lineLimit(5...10)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.green)
                        )
                        .padding(10)
                    
                    
                    //video player
                    YouTubePlayerView(
                        YouTubePlayer(urlString: thisMatch.strVideo ?? "")
                    )
                    .aspectRatio(16/9, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    
                    //map for stadium location maybe
                    
                    
                }
                
                
                Button("Save"){
                    //saving logic to come
                }
                .frame(width: 100, height: 40)
                .background(Color.green)
                .foregroundStyle(Color.white)
                .cornerRadius(10)
                
                
                Spacer()
            }
        }
        
    }
}

#Preview {
    MatchDetailView(thisMatch: dummyMatch)
}
