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
    var id: Int {
        return Int(idEvent)!
    }
}

struct MatchResponse: Decodable {
    let match: [Match]
}
