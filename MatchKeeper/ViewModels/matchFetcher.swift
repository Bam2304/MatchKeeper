//
//  placeholderVM.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/11/26.
//

import Foundation
import Combine

enum URLError: Error{
    case badURL //dummy error
}

@MainActor
class matchFetcher: ObservableObject {
    @Published var returnedMatch: Match?
    
    
    func getMatch(matchup: String, date: String) async throws {
        let endpoint: String = buildURLFromInputs(matchup: matchup, date: date) // formats the url properly
        
        guard let url = URL(string: endpoint) else {
            throw URLError.badURL //dummy error
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(MatchResponse.self, from: data) // try to decode into a matchresponse object (conatins a list of 1 match object)
        self.returnedMatch = response.event?[0] ?? nil
        
    }
    
    func buildURLFromInputs(matchup: String, date: String) -> String{
        let formattedMatchup = matchup.split(separator: " ").joined(separator: "_")
        return "https://www.thesportsdb.com/api/v1/json/123/searchevents.php?e=\(formattedMatchup)&d=\(date)"
    }
}
