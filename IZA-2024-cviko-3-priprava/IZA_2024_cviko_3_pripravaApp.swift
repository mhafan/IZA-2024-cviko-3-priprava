//
//  IZA_2024_cviko_3_pripravaApp.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import SwiftUI
import SwiftData

@main
struct IZA_2024_cviko_3_pripravaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
