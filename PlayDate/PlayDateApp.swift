//
//  PlayDateApp.swift
//  PlayDate
//
//  Created by Pattapon Gowanit on 9/5/2569 BE.
//

import SwiftUI
import FirebaseCore

@main
struct PlayDateApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
