//
//  trackable.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 11.04.2024.
//

import Foundation
import SwiftData

// ----------------------------------------------------------------------------
// systemova zprava pres notifikacni centrum
extension Notification.Name {
    //
    static let tracking = Notification.Name("myTrackingEvent")
}

// ----------------------------------------------------------------------------
// ...
protocol Trackable {
    //
}

// ----------------------------------------------------------------------------
// charakter sledovane zmeny
enum TrackingEvent {
    //
    case inserted(Trackable)
    case deleted(Trackable)
    case updated(Trackable)
}


// ----------------------------------------------------------------------------
// funkcionalita pro vsechny implementatory
extension Trackable {
    //
    func post(event: TrackingEvent) {
        //
        NotificationCenter.default.post(name: .tracking, object: event)
    }
    
    //
    func inserted() { post(event: .inserted(self)) }
    func deleted() { post(event: .deleted(self)) }
    func updated() { post(event: .updated(self)) }
}

// ----------------------------------------------------------------------------
//
extension ModelContext {
    //
    func trackableDelete<ON>(_ onObject: ON) where ON:PersistentModel, ON:Trackable{
        //
        self.delete(onObject); onObject.deleted()
    }
    
    //
    func trackableInsert<ON>(_ onObject: ON) where ON:PersistentModel, ON:Trackable{
        //
        self.insert(onObject); onObject.inserted()
    }
}
