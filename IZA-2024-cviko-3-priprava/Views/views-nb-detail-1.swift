//
//  views-nb-detail-1.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 11.04.2024.
//

import Foundation
import SwiftUI
import SwiftData

// ----------------------------------------------------------------------------
// Spolecne vlastnosti pro vsechny View typu "detail" nad NB
protocol NotebookDetailViewProtocol {
    //
    var notebook: Notebook { get }
    var modelContext: ModelContext { get }
    var vm: PageOfNotebooksVM { get }
}


// ----------------------------------------------------------------------------
//
extension NotebookDetailViewProtocol {
    // ------------------------------------------------------------------------
    //
    func addNewNote() {
        //
        let nn = Note(content: "...")
        
        //
        modelContext.trackableInsert(nn)
        nn.connect(to: notebook)
    }
    
    // ------------------------------------------------------------------------
    // Odstraneni poznamek v NB
    func clearNB() {
        //
        notebook.clearNotes(andDeleteInContext: modelContext)
    }
    
    // ------------------------------------------------------------------------
    // smazani NB
    func deleteNB() {
        // primitivni operacne nad ManageObjectContext
        // - automaticky zajistuje "deleterule" nad notes: [Note]
        modelContext.trackableDelete(notebook)
        
        // vyskocit z pohledu -> Navigation.pop
        let _ = vm.navigation.popLast()
    }
    
    // ------------------------------------------------------------------------
    //
    func performDelete(notes: [Note], atIndexes: IndexSet) {
        //
        atIndexes
            .map { notes[$0] }
            .forEach {
                notebook.remove(note: $0)
            }
    }
    
    // ------------------------------------------------------------------------
    //
    var toolbar: some ToolbarContent {
        //
        ToolbarItemGroup(placement: .topBarTrailing) {
            // pridani poznamky
            Button(action: addNewNote) { Image(systemName: "plus") }
            
            // smazani celeho NB
            Button(action: deleteNB) { Image(systemName: "trash") }
            
            // vymazani poznamek v NB
            Button(action: clearNB) { Text("Clear") }
            
            //
            EditButton()
        }
    }
}

// ----------------------------------------------------------------------------
//
struct NotebookDetailView_Plain: View, NotebookDetailViewProtocol {
    // ------------------------------------------------------------------------
    //
    @Bindable var notebook: Notebook
    
    // ------------------------------------------------------------------------
    //
    @EnvironmentObject var vm: PageOfNotebooksVM
    
    // ------------------------------------------------------------------------
    // reference na ManagedObjectContext (jeho ekvivalent ve SwiftData)
    @Environment(\.modelContext) var modelContext
    
    // ------------------------------------------------------------------------
    //
    var body: some View {
        //
        Form {
            //
            Section("Title") {
                //
                TextField("title", text: $notebook.title)
                    .disableAutocorrection(true)
            }
            
            //
            Section("Notes") {
                //
                ForEach(notebook.notes) { note in
                    //
                    NavigationLink(value: NotebookNavigation.toNote(nb: notebook, note: note)) {
                        NoteRowView(note: note)
                    }
                }.onDelete {
                    //
                    performDelete(notes: notebook.notes, atIndexes: $0)
                }
            }
        }
        
        //
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(notebook.description)
        
        //
        .toolbar {
            //
            self.toolbar
        }
    }
}

// ----------------------------------------------------------------------------
//
struct NotebookDetailView_Query: View, NotebookDetailViewProtocol {
    // ------------------------------------------------------------------------
    //
    @Bindable var notebook: Notebook
    
    // ------------------------------------------------------------------------
    //
    @EnvironmentObject var vm: PageOfNotebooksVM
    
    // ------------------------------------------------------------------------
    // reference na ManagedObjectContext (jeho ekvivalent ve SwiftData)
    @Environment(\.modelContext) var modelContext
    
    // ------------------------------------------------------------------------
    // deklaruji prazdnou QUERY, kterou beztak pri konstrukci nastavim
    @Query var qNotes: [Note] = []
    
    // ------------------------------------------------------------------------
    //
    init(notebook: Notebook) {
        //
        self.notebook = notebook
        
        // konstruuj @Query z konkretniho FETCH
        self._qNotes = Query(notebook.myNotesFetch)
    }
    
    // ------------------------------------------------------------------------
    //
    var body: some View {
        //
        Form {
            //
            Section("Title") {
                //
                TextField("title", text: $notebook.title)
                    .disableAutocorrection(true)
            }
            
            //
            if qNotes.isEmpty == false {
                //
                Section("Notes") {
                    //
                    ForEach(qNotes) { note in
                        //
                        NavigationLink(value: NotebookNavigation.toNote(nb: notebook, note: note)) {
                            NoteRowView(note: note)
                        }
                    }.onDelete { performDelete(notes: qNotes, atIndexes: $0) }
                }
            } else {
                //
                Text("Zatim zadne notes...")
            }
        }
        
        //
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(notebook.description)
        
        //
        .toolbar {
            //
            self.toolbar
        }
    }
}
