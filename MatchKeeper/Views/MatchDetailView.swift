//
//  MatchDetailView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/15/26.
//

import SwiftUI
import WebKit
import YouTubePlayerKit
import MapKit

//function to get coordinates from match venue
func getCoordinates(from query: String) async -> CLLocationCoordinate2D? {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    
    let search = MKLocalSearch(request: request)
    
    do {
        let response = try await search.start()
        return response.mapItems.first?.location.coordinate
    } catch {
        print("Search error:", error)
        return nil
    }
}

struct MatchDetailView: View {
    var thisMatch: Match
    @State var journalText: String = ""
    @EnvironmentObject var dM: DataManager
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic
    
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
                    
                    //map for stadium location
                    Map(position: $position) {
                        if let coordinate {
                            Marker(thisMatch.strVenue ?? "", systemImage: "sportscourt", coordinate: coordinate)
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .task {
                        if let coord = await getCoordinates(from: thisMatch.location) {
                            coordinate = coord
                            position = .region(
                                MKCoordinateRegion(
                                    center: coord,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                )
                            )
                        }
                    }
                    
                    //video player found from github api YouTubePlayerKit
                    YouTubePlayerView(
                        YouTubePlayer(urlString: thisMatch.strVideo ?? "")
                    )
                    .aspectRatio(16/9, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    
                   
                }
                
                
                Button("Save"){
                    //saving logic
                    dM.addMatch(thisMatch)
                    dM.updateJournal(for: thisMatch.idEvent, text: journalText)
                }
                .frame(width: 100, height: 40)
                .background(Color.green)
                .foregroundStyle(Color.white)
                .cornerRadius(10)
                
                
                Spacer()
            }
        }
        .onAppear {
            journalText = thisMatch.journal ?? ""
        }
        
    }
    
}

#Preview {
    MatchDetailView(thisMatch: dummyMatch)
        .environmentObject(DataManager())
}
