//
//  views-notebook.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import Foundation
import SwiftUI
import SwiftData

// ----------------------------------------------------------------------------
//
enum NotebookNavigation: Hashable {
    //
    case toNotebookPlain(nb: Notebook)
    case toNotebookQuery(nb: Notebook)
    case toNote(nb: Notebook, note: Note)
}

// ----------------------------------------------------------------------------
//
class PageOfNotebooksVM: ObservableObject {
    //
    @Published var navigation: [NotebookNavigation] = []
    
    //
    static let shared = PageOfNotebooksVM()
}

// ----------------------------------------------------------------------------
// Radek v tabulce
struct NotebookRowView: View {
    // drzim referenci, pro read-only
    let notebook: Notebook
    
    // ...
    var body: some View {
        //
        HStack {
            //
            Text(notebook.title)
                .font(.largeTitle)
            
            //
            Spacer()
            
            //
            Text("\(notebook.numberOfNotes)")
        }
    }
}


// ----------------------------------------------------------------------------
// Stranka TabView pro prehled NoteBook
struct PageOfNotebooks: View {
    // ------------------------------------------------------------------------
    // reference na ManagedObjectContext (jeho ekvivalent ve SwiftData)
    @Environment(\.modelContext) private var modelContext
    
    // ------------------------------------------------------------------------
    // FetchedResultsController nad NB
    @Query(sort: \Notebook.title) var allNoteBooks: [Notebook] = []
    
    // ------------------------------------------------------------------------
    //
    @ObservedObject var vm = PageOfNotebooksVM.shared
    
    // ------------------------------------------------------------------------
    //
    private func addNewNotebook() {
        //
        let nb = Notebook(title: "novy")
        
        //
        modelContext.trackableInsert(nb)
    }
    
    // ------------------------------------------------------------------------
    //
    private func deleteNotebooksAt(at: IndexSet) {
        //
        let objs = at.map { allNoteBooks[$0] }
        
        //
        for nb in objs {
            //
            modelContext.trackableDelete(nb)
        }
    }
    
    // ------------------------------------------------------------------------
    //
    var body: some View {
        //
        NavigationStack(path: $vm.navigation) {
            //
            List {
                //
                ForEach(allNoteBooks) { nb in
                    //
                    NavigationLink(value: NotebookNavigation.toNotebookQuery(nb: nb)) {
                        //
                        NotebookRowView(notebook: nb)
                    }
                }
                .onDelete { deleteNotebooksAt(at: $0) }
            }
            
            //
            .navigationDestination(for: NotebookNavigation.self) { value in
                //
                switch value {
                    //
                case .toNotebookPlain(nb: let nb):
                    //
                    NotebookDetailView_Plain(notebook: nb)
                        .environmentObject(vm)
                    
                case .toNotebookQuery(nb: let nb):
                    //
                    NotebookDetailView_Query(notebook: nb)
                        .environmentObject(vm)
                    
                    //
                case .toNote(nb: _, note: let note):
                    //
                    NoteDetailView(note: note)
                }
            }
            
            //
            .navigationTitle("Notebooks")
            
            //
            .toolbar {
                //
                ToolbarItemGroup {
                    //
                    Button(action: addNewNotebook) { Image(systemName: "plus")}
                    
                    //
                    EditButton()
                }
            }
        }
    }
}
