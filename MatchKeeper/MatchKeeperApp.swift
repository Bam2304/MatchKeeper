//
//  MatchKeeperApp.swift
//  MatchKeeper
//
//  Created by Bamidele Adeyemo on 4/11/26.
//

import SwiftUI

@main
struct MatchKeeperApp: App {
    @StateObject var dM: DataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            BaseView()
                .environmentObject(dM)
        }
    }
}
