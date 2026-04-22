//
//  dataManager.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/16/26.
//

import Foundation
import Combine
import SwiftUI

class DataManager: ObservableObject {
    //when user saves a match, appears here
    @Published var matchList: [Match] = []
    
    func addMatch(_ match: Match) {
        //if match is already there, they must be updating journal text, so dont add again
        if matchList.contains(where: { $0.idEvent == match.idEvent }) {
            return
        }
        matchList.append(match)
    }
    
    func updateJournal(for matchID: String, text: String) {
        if let index = matchList.firstIndex(where: { $0.idEvent == matchID }) {
            matchList[index].journal = text
        }
    }
    
    func removeMatch(at offsets: IndexSet){
        matchList.remove(atOffsets: offsets)
    }
    
    
}
