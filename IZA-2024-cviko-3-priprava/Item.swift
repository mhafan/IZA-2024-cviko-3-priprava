//
//  Item.swift
//  IZA-2024-cviko-3-priprava
//
//  Created by Martin Hruby on 10.04.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
