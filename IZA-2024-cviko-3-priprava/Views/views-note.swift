//
//  views-note.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import Foundation
import SwiftUI
import SwiftData


// ----------------------------------------------------------------------------
//
struct NoteRowView: View {
    //
    let note: Note
    
    //
    var body: some View {
        //
        VStack(alignment: .leading) {
            //
            Text(note.created.description)
            
            //
            Text(note.nbTitle)
        }
    }
}



// ----------------------------------------------------------------------------
//
struct NoteDetailView: View {
    //
    @Bindable var note: Note
    
    //
    var body: some View {
        //
        VStack {
            Text("cosi")
            Spacer()
            TextField("content", text: $note.content, axis: .vertical)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 400)
        }.padding()
    }
}


// ----------------------------------------------------------------------------
//
struct PageOfNotes: View {
    // ------------------------------------------------------------------------
    // reference na ManagedObjectContext (jeho ekvivalent ve SwiftData)
    @Environment(\.modelContext) private var modelContext
    
    //
    @Query(sort: \Note.created) var notes: [Note] = []
    
    //
    func removeAll() {
        //
        for i in notes {
            //
            i.getDeleted(from: modelContext)
        }
    }
    
    //
    var body: some View {
        //
        NavigationStack {
            //
            List(notes) { nt in
                //
                NoteRowView(note: nt)
            }
            
            .toolbar {
                //
                Button(action: removeAll) { Text("Remove-all") }
            }
        }
    }
}
