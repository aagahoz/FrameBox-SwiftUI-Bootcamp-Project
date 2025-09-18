//
//  Item.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 19.09.2025.
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
