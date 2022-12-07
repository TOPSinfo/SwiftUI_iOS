//
//  AddEventModel.swift
//  Astroyodha
//
//  Created by Tops on 20/10/22.
//

import Foundation
import SwiftUI

// not used
enum AddEventDuration: Int, Identifiable, CaseIterable {
    case fifteen = 15
    case thirty = 30
    case fourtyFive = 45
    case sixty = 60
    
    var id: RawValue { rawValue }
    
    var displayTitle: String{
        switch self{
        case .fifteen : return "15 minutes"
        case .thirty : return "30 minutes"
        case .fourtyFive : return "45 minutes"
        case .sixty : return "60 minutes"
        }
    }
}
