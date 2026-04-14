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

class matchFetcher: ObservableObject {
    @Published var returnedMatch: Match?
    
    
    func getMatch() async throws {
        var endpoint: String = "" // will make a function to build url from the match and date, which'll be used here
        
        guard let url = URL(string: endpoint) else {
            throw URLError.badURL //dummy error
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(MatchResponse.self, from: data) //try to decode into a matchresponse object (conatins a list of 1 match object)
        self.returnedMatch = response.match[0]
        
    }
    
    func buildURLFromInputs(matchup: String, date: String) -> String{
        
        
        return ""
    }
}
