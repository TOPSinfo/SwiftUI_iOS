//
//  GeneralModel.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI

// MARK: - User Type
enum UserType: String {
    case user
    case astrologer
    
    var themeColor: Color {
        switch self {
        case .user: return AppColor.cF06649
        case .astrologer: return AppColor.c27AAE1
        }
    }
    
    var themeUIColor: UIColor {
        switch self {
        case .user: return AppUIColor.cF06649
        case .astrologer: return AppUIColor.c27AAE1
        }
    }
}
