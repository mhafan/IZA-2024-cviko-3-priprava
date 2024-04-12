//
//  notebook.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import Foundation
import SwiftData

// ----------------------------------------------------------------------------
// Model entity NoteBook
@Model class Notebook: CustomStringConvertible, Trackable {
    // ------------------------------------------------------------------------
    // primitivni ulozeny atribut
    var title: String
    
    // ------------------------------------------------------------------------
    // !!!!
    // moje explicitni interni UUID objektu, ktere usnadni tvorbu #Predicate
    var myID: String
    
    // ------------------------------------------------------------------------
    // atribut typu relation-ship 1:N, kde deleteRule znaci automatickou akci:
    // smaze se notebook => kaskadove se smazou jeho poznamky
    @Relationship(deleteRule: .cascade) var notes: [Note] = []
    
    // ------------------------------------------------------------------------
    //
    var numberOfNotes: Int { notes.count }
    var description: String { "\(title): \(numberOfNotes)"}
    
    // ------------------------------------------------------------------------
    // specifikace FETCH -> @Query 
    var myNotesFetch: FetchDescriptor<Note> {
        //
        var f = FetchDescriptor<Note>()
    
        // --------------------------------------------------------------------
        // Makro transformujici vyraz na SQL where klauzuli
        f.predicate = #Predicate<Note> { nt in
            // tady dochazi k transformaci
            // melo by vzdy vest na operaci nad PRIMITIVNIMI typy
            // tj ne identita
            nt.inNotebook?.myID == myID
            
            // !!! Nelze:
            // nt.inNotebook == self (hodnota)
            // nt.inNotebook === self (identita)
        }
        
        //
        f.sortBy = [SortDescriptor(\Note.created, order: .forward)]
        
        //
        return f
    }
    
    // ------------------------------------------------------------------------
    //
    var fetchMyNotes: [Note] {
        //
        guard let _them = try? self.modelContext?.fetch(myNotesFetch)
        else { return [] }
        
        //
        return _them
    }
    
    // ------------------------------------------------------------------------
    // propojeni vazby 1:N
    func add(note: Note) {
        // 1) zapise do pole, coz je abstrakce pro zaveneni vazby
        // 2) soucasne aktualizuje @Observable prvek "notes", tj zmenu zachyti
        // patricny View
        self.notes.append(note)
    }
    
    // ------------------------------------------------------------------------
    // odstraneni jedne poznamky
    func remove(note: Note, andDeleteInContext: ModelContext? = nil) {
        // operace vynulovani vazby ze strany Note provede inverzni
        // operaci na self.notes (remove z pole), ale negeneruje udalost do View
        note.inNotebook = nil; print(notes.count)
        
        //
        if let _context = andDeleteInContext {
            //
            _context.trackableDelete(note)
        }
    }
    
    // ------------------------------------------------------------------------
    // odstran poznamky z NB ve dvou provedenich
    // - andDeleteInContext = nil -> jenom odstrani vazbu, poznamka prezije (mimo NB)
    // - andDeleteInContext != nil -> smaze se i poznamka
    func clearNotes(andDeleteInContext: ModelContext? = nil) {
        //
        for n in notes {
            //
            remove(note: n, andDeleteInContext: andDeleteInContext)
        }
    }
    
    //
    init(title: String, notes: [Note] = []) {
        //
        self.title = title
        self.myID = UUID().uuidString
        self.notes = notes
    }
}
