//
//  Font+Extension.swift
//  Astroyodha
//
//  Created by Tops on 05/09/22.
//

import SwiftUI

public enum AppFont: String {
    case poppinsRegular = "Poppins-Regular"
    case poppinsItalic = "Poppins-Italic"
    case poppinsThin = "Poppins-Thin"
    case poppinsThinItalic = "Poppins-ThinItalic"
    case poppinsExtraLight = "Poppins-ExtraLight"
    case poppinsExtraLightItalic = "Poppins-ExtraLightItalic"
    case poppinsLight = "Poppins-Light"
    case poppinsLightItalic = "Poppins-LightItalic"
    case poppinsMedium = "Poppins-Medium"
    case poppinsMediumItalic = "Poppins-MediumItalic"
    case poppinsSemiBold = "Poppins-SemiBold"
    case poppinsSemiBoldItalic = "Poppins-SemiBoldItalic"
    case poppinsBold = "Poppins-Bold"
    case poppinsBoldItalic = "Poppins-BoldItalic"
    case poppinsExtraBold = "Poppins-ExtraBold"
    case poppinsExtraBoldItalic = "Poppins-ExtraBoldItalic"
    case poppinsBlack = "Poppins-Black"
    case poppinsBlackItalic = "Poppins-BlackItalic"
}

public func appFont(type: AppFont, size: CGFloat) -> Font {
    return Font.custom(type.rawValue, size: size)
}

public func appUIFont(type: AppFont, size: CGFloat) -> UIFont {
    return UIFont.init(name: type.rawValue, size: size)!
}
