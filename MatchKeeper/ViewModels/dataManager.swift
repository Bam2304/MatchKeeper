//
//  dataManager.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/16/26.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class DataManager: ObservableObject {
    //when user saves a match, appears here
    @Published var matchList: [Match] = []
    
    
    private enum GameField {
        static let gameID = "gameID"
        static let eventName = "strEvent"
        static let homeTeam = "homeTeam"
        static let legacyHomeTeam = "hometeam"
        static let awayTeam = "awayTeam"
        static let homeScore = "homeScore"
        static let awayScore = "awayScore"
        static let date = "date"
        static let league = "league"
        static let venue = "venue"
        static let thumbnail = "thumbnail"
        static let video = "video"
        static let country = "country"
        static let notes = "notes"
        static let rating = "rating"
        static let score = "score"
    }
    
    func addMatch(_ match: Match, notes: String = "", rating: Int? = nil) {
        var savedMatch = match
        savedMatch.journal = notes
        savedMatch.rating = rating ?? match.rating

        if matchList.contains(where: { $0.idEvent == match.idEvent }) {
            if let index = matchList.firstIndex(where: { $0.idEvent == match.idEvent }) {
                matchList[index] = savedMatch
            }
        } else {
            matchList.append(savedMatch)
        }

        saveGame(game: match, notes: notes, rating: rating)
    }

    func loadSavedGames() {
        guard let uid = Auth.auth().currentUser?.uid else {
            matchList = []
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("savedGames")
            .getDocuments { [weak self] snapshot, error in
                guard let snapshot, error == nil else {
                    return
                }

                let loadedMatches: [Match] = snapshot.documents.map { document in
                    let data = document.data()
                    let matchID = data[GameField.gameID] as? String ?? document.documentID
                    let homeTeam = self?.stringValue(in: data, keys: [GameField.homeTeam, GameField.legacyHomeTeam]) ?? ""
                    let awayTeam = self?.stringValue(in: data, keys: [GameField.awayTeam, "awayTeam"]) ?? ""
                    let date = data[GameField.date] as? String
                    let league = self?.stringValue(in: data, keys: [GameField.league, "strLeague"])
                    let venue = self?.stringValue(in: data, keys: [GameField.venue, "strVenue"])
                    let thumb = self?.stringValue(in: data, keys: [GameField.thumbnail, "strThumb"])
                    let video = self?.stringValue(in: data, keys: [GameField.video, "strVideo"])
                    let country = self?.stringValue(in: data, keys: [GameField.country, "strCountry"])
                    let notes = data[GameField.notes] as? String
                    let rating = self?.intValue(in: data, keys: [GameField.rating])
                    let eventFromDoc = self?.stringValue(in: data, keys: [GameField.eventName]) ?? ""

                    let homeScoreFromField = self?.stringValue(in: data, keys: [GameField.homeScore]) ?? ""
                    let awayScoreFromField = self?.stringValue(in: data, keys: [GameField.awayScore]) ?? ""
                    let legacyScore = self?.stringValue(in: data, keys: [GameField.score]) ?? ""
                    let scoreParts = legacyScore.split(separator: "-", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    let homeScore = !homeScoreFromField.isEmpty ? homeScoreFromField : (scoreParts.first ?? "")
                    let awayScore = !awayScoreFromField.isEmpty ? awayScoreFromField : (scoreParts.count > 1 ? scoreParts[1] : "")

                    let eventName = [homeTeam, awayTeam]
                        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        .joined(separator: " vs ")

                    return Match(
                        idEvent: matchID,
                        strEvent: eventFromDoc.isEmpty ? (eventName.isEmpty ? nil : eventName) : eventFromDoc,
                        strLeague: league?.isEmpty == false ? league : nil,
                        intHomeScore: homeScore.isEmpty ? nil : homeScore,
                        intAwayScore: awayScore.isEmpty ? nil : awayScore,
                        dateEvent: date,
                        strVenue: venue?.isEmpty == false ? venue : nil,
                        strThumb: thumb?.isEmpty == false ? thumb : nil,
                        strVideo: video?.isEmpty == false ? video : nil,
                        strCountry: country?.isEmpty == false ? country : nil,
                        journal: notes,
                        rating: rating
                    )
                }

                Task { @MainActor in
                    self?.matchList = loadedMatches
                }
            }
    }

    func saveGame(game: Match, notes: String = "", rating: Int? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        let gameRef = db.collection("users")
            .document(uid)
            .collection("savedGames")
            .document(game.idEvent)

        let teams = (game.strEvent ?? "").components(separatedBy: " vs ")
        let homeTeam = teams.first ?? ""
        let awayTeam = teams.count > 1 ? teams[1] : ""
        let score = "\(game.intHomeScore ?? "-")-\(game.intAwayScore ?? "-")"
        let persistedRating = rating ?? game.rating

        gameRef.setData([
            GameField.gameID: game.idEvent,
            GameField.eventName: game.strEvent ?? "",
            GameField.homeTeam: homeTeam,
            GameField.legacyHomeTeam: homeTeam,
            GameField.awayTeam: awayTeam,
            GameField.homeScore: game.intHomeScore ?? "",
            GameField.awayScore: game.intAwayScore ?? "",
            GameField.date: game.dateEvent ?? "",
            GameField.league: game.strLeague ?? "",
            GameField.venue: game.strVenue ?? "",
            GameField.thumbnail: game.strThumb ?? "",
            GameField.video: game.strVideo ?? "",
            GameField.country: game.strCountry ?? "",
            GameField.notes: notes,
            GameField.rating: persistedRating ?? NSNull(),
            GameField.score: score,
            "createdAt": Timestamp(date: Date())
        ], merge: true) { [weak self] error in
            guard error == nil else {
                return
            }

            self?.refreshUserProfileStats(for: uid)
        }
    }

    private func refreshUserProfileStats(for uid: String) {
        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .collection("savedGames")
            .getDocuments { snapshot, error in
                guard let snapshot, error == nil else {
                    return
                }

                var teamCounts: [String: Int] = [:]

                for document in snapshot.documents {
                    let data = document.data()
                    let homeTeam = self.stringValue(in: data, keys: [GameField.homeTeam, GameField.legacyHomeTeam])
                    let awayTeam = self.stringValue(in: data, keys: [GameField.awayTeam, "awayTeam"])

                    [homeTeam, awayTeam].forEach { team in
                        let trimmedTeam = team.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTeam.isEmpty else {
                            return
                        }
                        teamCounts[trimmedTeam, default: 0] += 1
                    }
                }

                let favoriteTeam = teamCounts.max { lhs, rhs in
                    if lhs.value == rhs.value {
                        return lhs.key > rhs.key
                    }
                    return lhs.value < rhs.value
                }?.key ?? ""

                db.collection("users")
                    .document(uid)
                    .setData([
                        "gamesSavedCount": snapshot.documents.count,
                        "favoriteteam": favoriteTeam
                    ], merge: true)
            }
    }

    private func stringValue(in data: [String: Any], keys: [String]) -> String {
        for key in keys {
            if let value = data[key] as? String {
                return value
            }
        }
        return ""
    }

    private func intValue(in data: [String: Any], keys: [String]) -> Int? {
        for key in keys {
            if let value = data[key] as? Int {
                return value
            }
            if let value = data[key] as? Int64 {
                return Int(value)
            }
            if let value = data[key] as? NSNumber {
                return value.intValue
            }
        }
        return nil
    }
    
    func updateJournal(for matchID: String, text: String) {
        if let index = matchList.firstIndex(where: { $0.idEvent == matchID }) {
            matchList[index].journal = text
        }
    }

    func removeSavedGame(game: Match) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        let gameRef = db.collection("users")
            .document(uid)
            .collection("savedGames")
            .document(game.idEvent)

        gameRef.delete { [weak self] error in
            guard error == nil else {
                return
            }

            self?.refreshUserProfileStats(for: uid)
        }
    }
    
    func removeMatch(at offsets: IndexSet){
        let matchesToRemove = offsets.compactMap { index in
            matchList.indices.contains(index) ? matchList[index] : nil
        }
        matchesToRemove.forEach { removeSavedGame(game: $0) }
        matchList.remove(atOffsets: offsets)
    }
    
    
}
