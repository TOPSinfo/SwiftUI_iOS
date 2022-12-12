//
//  HomeModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation
import SwiftUI

// MARK: - IDENTIFIABLE ASTROLOGER
struct AstrologerGridItmeVM: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let uid: String
    let ratting: Float
    let address: String
    let imageAstro: String
    let speciality: [String]
    
    init(name: String, price: Int, uid: String, ratting: Float, address: String, imageAstro: String, speciality: [String]) {
        self.name = name
        self.price = price
        self.uid = uid
        self.ratting = ratting
        self.address = address
        self.imageAstro = imageAstro
        self.speciality = speciality
    }
}

// MARK: - Banner
struct HomeBannerVM {
    let title: String
    let description: String
    let imageName: String
    let backColor: Color = currentUserType.themeColor
}

// MARK: - Upcoming Item
struct HomeUserUpcomingItemVM: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let color: Color
}
