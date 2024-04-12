//
//  MetaView.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 11.04.2024.
//


import SwiftUI
import SwiftData
import Combine


// ----------------------------------------------------------------------------
// Naznak FetchedResultsController (inspirace CoreData)
@MainActor class FRC<Entity>: ObservableObject where Entity:Trackable, Entity:PersistentModel {
    // ------------------------------------------------------------------------
    // vysledne pole fetched-results
    @Published public var content: [Entity] = []
    
    // ------------------------------------------------------------------------
    // interni
    private let MOC: ModelContext
    private var _tracking: AnyCancellable?
    
    // ------------------------------------------------------------------------
    // provede stanoveny dotaz (muze mit vlastni predicate)
    private let fetchd: FetchDescriptor<Entity>
    // ... a ten dodatecne filtruje
    private let filter: ((Entity) -> Bool)?
    
    // ------------------------------------------------------------------------
    //
    func update(with: [Entity]) {
        //
        if let _filter = filter {
            //
            content = with.filter { _filter($0) }
        } else {
            //
            content = with
        }
    }
    
    // ------------------------------------------------------------------------
    //
    func fetch() -> [Entity] {
        //
        if let _f = try? MOC.fetch(fetchd) {
            //
            return _f
        }
        
        //
        return []
    }
    
    // ------------------------------------------------------------------------
    // TODO: nejak osetrit udalost updated
    // TODO: nejak osetrit, zda-li se udalost vubec tyka me Entity
    private func receive(event: TrackingEvent) {
        //
        switch event {
        case .deleted, .inserted:
            //
            update(with: fetch())
        default: ()
        }
    }
    
    
    // ------------------------------------------------------------------------
    //
    init(MOC: ModelContext, fetchd: FetchDescriptor<Entity>, filter: ((Entity) -> Bool)? = nil) {
        //
        self.MOC = MOC
        self.fetchd = fetchd
        self.filter = filter
        
        // proved iniciacni fetch
        update(with: fetch())
        
        // sleduj zmeny na Notification udalosti
        _tracking = NotificationCenter.default.publisher(for: Notification.Name.tracking)
            .sink { event in
                //
                guard let _event = event.object as? TrackingEvent else { return }
                
                //
                self.receive(event: _event)
            }
        
    }
}

// ----------------------------------------------------------------------------
//
@MainActor class MetaVM: ObservableObject {
    // ------------------------------------------------------------------------
    //
    @Published var numberOfNBs = 0
    @Published var numberOfNotes = 0
    
    // ------------------------------------------------------------------------
    //
    private let FRC_NB: FRC<Notebook>
    private let FRC_Notes: FRC<Note>
    
    // ------------------------------------------------------------------------
    // ulozeni subscriptions
    private var _anies = Set<AnyCancellable>()
    
    // ------------------------------------------------------------------------
    //
    static let shared = MetaVM(moc: MojeSwiftDataAPP.sharedModelContainer.mainContext)
    
    // ------------------------------------------------------------------------
    //
    init(moc: ModelContext) {
        //
        FRC_NB = FRC(MOC: moc, fetchd: FetchDescriptor<Notebook>())
        FRC_Notes = FRC(MOC: moc, fetchd: FetchDescriptor<Note>())
        
        // vytvoreni subscriptions
        // .map v obou pripadech transformuje [Entity] -> [].count
        FRC_NB.$content
            .map { $0.count }
            .assign(to: \MetaVM.numberOfNBs, on: self)
            .store(in: &_anies)
        
        //
        FRC_Notes.$content
            .map { $0.count }
            .assign(to: \MetaVM.numberOfNotes, on: self)
            .store(in: &_anies)
    }
}

// ----------------------------------------------------------------------------
//
struct MetaRow<Value>: View where Value: CustomStringConvertible {
    //
    @ObservedObject var vm: MetaVM
    
    //
    let kp: KeyPath<MetaVM, Value>
    let label: String
    
    //
    var body: some View {
        //
        HStack {
            //
            Text(label); Spacer(); Text(vm[keyPath: kp].description)
        }
    }
}

// ----------------------------------------------------------------------------
//
struct PageOfOverview: View {
    //
    @ObservedObject var vm = MetaVM.shared
    
    //
    var body: some View {
        //
        List {
            //
            Text("Prehled")
            
            //
            MetaRow(vm: vm, kp: \.numberOfNBs, label: "Pocet NB")
            MetaRow(vm: vm, kp: \.numberOfNotes, label: "Pocet poznamek")
        }
    }
}
