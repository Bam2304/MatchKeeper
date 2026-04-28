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
    @Published var recentMatches: [Match] = []
    
    
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
    
    func getRecentGames() async throws {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var collectedMatches: [Match] = []
        var seenEventIDs = Set<String>()

        for daysBack in 0..<10 {
            guard let targetDate = calendar.date(byAdding: .day, value: -daysBack, to: Date()) else {
                continue
            }

            let dayString = dateFormatter.string(from: targetDate)
            let endpoint = "https://www.thesportsdb.com/api/v1/json/123/eventsday.php?d=\(dayString)&s=Soccer"

            guard let url = URL(string: endpoint) else {
                throw URLError.badURL
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(MatchResponse.self, from: data)

            for match in response.allEvents where seenEventIDs.insert(match.idEvent).inserted {
                collectedMatches.append(match)
            }

            if collectedMatches.count >= 20 {
                break
            }
        }

        self.recentMatches = Array(collectedMatches.sorted { lhs, rhs in
            compare(match: lhs, isEarlierThan: rhs)
        }.prefix(20))
    }

    private func compare(match lhs: Match, isEarlierThan rhs: Match) -> Bool {
        let lhsDate = combinedDate(for: lhs)
        let rhsDate = combinedDate(for: rhs)
        return lhsDate > rhsDate
    }

    private func combinedDate(for match: Match) -> Date {
        if let timestamp = match.strTimestamp {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: timestamp) {
                return date
            }

            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: timestamp) {
                return date
            }
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateString = (match.dateEvent ?? "") + " " + (match.strTime ?? "00:00:00")
        return formatter.date(from: dateString) ?? .distantPast
    }
    
    func buildURLFromInputs(matchup: String, date: String) -> String{
        let formattedMatchup = matchup.split(separator: " ").joined(separator: "_")
        return "https://www.thesportsdb.com/api/v1/json/123/searchevents.php?e=\(formattedMatchup)&d=\(date)"
    }
}
