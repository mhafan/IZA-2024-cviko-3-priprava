//
//  note.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import Foundation
import SwiftData

// ----------------------------------------------------------------------------
// DB Model pro 1ks poznamky
@Model class Note : Trackable {
    // ------------------------------------------------------------------------
    // ulozene atributy
    var created: Date
    var content: String
    
    // ------------------------------------------------------------------------
    // RelationShip
    // deleteRule: pokud je Note smazana -> v cili (Notebook) se zajisti nulovani
    // (odstraneni) reference na Note
    // inverse: cil relationShip 1:N
    @Relationship(deleteRule: .nullify, inverse: \Notebook.notes) var inNotebook: Notebook?
    
    // ------------------------------------------------------------------------
    //
    var nbTitle: String { inNotebook?.title ?? "mimo-NB" }
    
    // ------------------------------------------------------------------------
    //
    func getDeleted(from: ModelContext) {
        //
        self.inNotebook = nil
        
        //
        from.trackableDelete(self)
    }
    
    // ------------------------------------------------------------------------
    // poznamka se stane prvkem NoteBook, tj
    // rozsiri se jeho to.notes.append(self)
    func connect(to: Notebook) {
        // --------------------------------------------------------------------
        // propojeni 1:N vazby NB->Note, resp inverzne Note->NB lze provest
        // z obou stran:
        // 1) ze strany Note
        // self.inNotebook = to
        // 2) ze strany NoteBooku
        to.add(note: self)
                
        // --------------------------------------------------------------------
        // Dusledky:
        // - varianty 1) a 2) probehnou DATABAZOVE ok
        // - pouze varianta 2) aktualizuje View nad NB
    }

    // ------------------------------------------------------------------------
    // trida vyzaduje explicitni konstruktor
    init(content: String, created: Date = .now) {
        //
        self.created = created
        self.content = content
    }
}
