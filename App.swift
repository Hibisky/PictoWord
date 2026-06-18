// PictoWordApp.swift
import SwiftUI

@main
struct PictoWordApp: App {
    
    // DatabaseManager est créé une seule fois ici
    // et partagé dans tout l'app via .environmentObject
    @StateObject private var dbManager = DatabaseManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(dbManager)
        }
    }
}