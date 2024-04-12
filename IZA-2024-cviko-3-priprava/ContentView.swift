//
//  ContentView.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import SwiftUI
import SwiftData
import Combine

// ----------------------------------------------------------------------------
//
struct ContentView: View {
    //
    var body: some View {
        //
        TabView {
            //
            PageOfNotebooks().tabItem {
                //
                Text("Notebooks")
            }
            
            //
            PageOfNotes().tabItem {
                //
                Text("Notes")
            }
            
            //
            PageOfOverview().tabItem {
                //
                Text("Metas")
            }
        }
    }
}

