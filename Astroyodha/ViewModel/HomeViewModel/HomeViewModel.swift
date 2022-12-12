//
//  HomeViewModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    let backImageName = currentUserType == .user ? "userHomeBack" : "astrologerHomeBack"
    let bannerVM = HomeBannerVM(title: "Appointment",
                                description: "Connect with astrologer by booking an appointment.",
                                imageName: "astrologerAd")

    var astrolgerGridVMs: [AstrologerGridItmeVM] = []
    let upcomingVMs = [
        HomeUserUpcomingItemVM(title: "Daily Horoscope",
                               imageName: "dailyHoroscope",
                               color: AppColor.cF06649),
        HomeUserUpcomingItemVM(title: "Free Kundali",
                               imageName: "freeKundali",
                               color: AppColor.c27AAE1),
        HomeUserUpcomingItemVM(title: "Horoscope Matching",
                               imageName: "horoscopeMatching",
                               color: AppColor.cF1A341)
    ]
    @Published var arrAstrologers: [AstrologerGridItmeVM] = []
    @Published var objLoggedInUser: UserModel?
    let userViewModel = UserViewModel()
    var firebase: FirebaseService = FirebaseService()
    @Published var isAddEvent = false
    @Published var astrologerGridVMs: [AstrologerGridItmeVM]?
    @Published var selectAstrologer : AstrologerGridItmeVM?
    var gridColumns = [
        GridItem(.flexible(minimum: 0, maximum: 500), spacing: 14),
        GridItem(.flexible(minimum: 0, maximum: 500), spacing: 14)
    ]
    var columns = [
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 10.6),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 10.6),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 10.6)
    ]
    @Published var isBookAppointmentTapped = false
    
    init() {
        self.fetchCurrentUser()
        if currentUserType == .user {
            self.fetchAllAstrologers()
        }
    }
    
    // MARK: - Get Astrologer List
    func fetchAllAstrologers() {
        firebase.fetchAllAstrologer { arrData in
            self.arrAstrologers = arrData
        }
    }
    
    // MARK: - Get Current User
    func fetchCurrentUser() {
        userViewModel.fetchCurrentUserData(completion: { user in
            self.objLoggedInUser = user
            Singletion.shared.objLoggedInUser = user
        })
    }
}
