//
//  matchModel.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/14/26.
//

import Foundation

struct Match: Decodable, Identifiable{
    let idEvent: String
    let strEvent: String?
    let strLeague: String?
    let intHomeScore: String?
    let intAwayScore: String?
    let dateEvent: String?
    let strVenue: String?
    let strThumb: String?
    let strVideo: String?
    let strCountry: String?
    var id: Int {
        return Int(idEvent)!
    }
    // this is the journal text from the user
    var journal: String? = nil
    var rating: Int? = nil
    // contructing location string to eventually get coordinates
    var location: String {
        if let ven = strVenue, let con = strCountry {
            return "\(ven), \(con)"
        }
        return ""
    }
}

struct MatchResponse: Decodable {
    let event: [Match]?
}

let dummyMatch: Match = Match(idEvent: "", strEvent: "Arsenal vs Chelsea", strLeague: "English Premier League", intHomeScore: "0", intAwayScore: "1", dateEvent: "2025-01-23", strVenue: "Emirates Stadium", strThumb: "https://r2.thesportsdb.com/images/media/event/thumb/sswrrr1430243855.jpg", strVideo: "https://www.youtube.com/watch?v=yQaaKW9CzNM", strCountry: "England")
