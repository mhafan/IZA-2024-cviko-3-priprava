//
//  IZA_2024_cviko_3_pripravaApp.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import SwiftUI
import SwiftData

// ----------------------------------------------------------------------------
// main() Aplikace
@main struct MojeSwiftDataAPP: App {
    // ------------------------------------------------------------------------
    // Zavedeni SwiftData stacku
    // ------------------------------------------------------------------------
    // singleton MojeSwiftDataAPP.sharedModelContainer
    static let sharedModelContainer: ModelContainer = {
        // --------------------------------------------------------------------
        // DB schema tvoreny tridami @Model
        let schema = Schema([
            Notebook.self,
            Note.self
        ])
        
        // --------------------------------------------------------------------
        // Inicializace stacku <- schema
        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false)

        //
        do {
            //
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // stack typicky nejde inicializovat po vyznamne zmene schematu
            // pak:
            // 1) smazat aplikaci v zarizeni + nova instalace
            // 2) pokrocilejsi techniky aktualizace DB schematu, verzovani
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // ------------------------------------------------------------------------
    //
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(MojeSwiftDataAPP.sharedModelContainer)
    }
}
