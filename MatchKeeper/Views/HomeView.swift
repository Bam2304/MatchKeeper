//
//  ContentView.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/11/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dM: DataManager
    @StateObject private var fetcher = matchFetcher()
    @State private var isLoading = false
    @State private var refreshTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            Text("WELCOME!")
                .font(.system(size: 55))
                .fontDesign(.serif)
                .foregroundStyle(.green)
                .bold()
            
            if isLoading {
                ProgressView()
            } else if fetcher.recentMatches.isEmpty {
                Text("No recent games available.")
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .font(.title3)
            } else {
                List {
                    ForEach(fetcher.recentMatches) { match in
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
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(match.strEvent ?? "")
                                        .font(.headline)
                                    if let date = match.dateEvent {
                                        Text(date)
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .cornerRadius(12)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .task {
            await loadRecentGames()
            startAutoRefresh()
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
    }
    
    private func loadRecentGames() async {
        isLoading = true

        do {
            try await fetcher.getRecentGames()
        } catch {
            print("Error loading recent games: \(error)")
        }

        isLoading = false
    }

    private func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(120))
                if Task.isCancelled { break }
                await loadRecentGames()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
