//
//  UserTabView.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI
import CoreMedia
import SSCustomTabbar

// MARK: - View
struct UserTabView: View {
    @State var isTabBarHidden: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            userTabView
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    SwiftUITabBarController.refreshViews()
            }
        }
    }
    
    var userTabView: some View {
        let homeVC = SwiftUITabView(content: UIHostingController(rootView: HomeView()),
                                    title: "Dashboard",
                                    selectedImage: "tabHome",
                                    unSelectedImage: "tabHome")
        let userBookingVC = SwiftUITabView(content: UIHostingController(rootView: BookingListView()),
                                       title: "Booking",
                                       selectedImage: "tabBooking",
                                       unSelectedImage: "tabBooking")
        let userProfileVC = SwiftUITabView(content: UIHostingController(rootView: ProfileView()),
                                       title: "Profile",
                                       selectedImage: "tabProfile",
                                       unSelectedImage: "tabProfile")
        
        let tabBarView = SwiftUITabBarController(tabItems: [homeVC, userBookingVC, userProfileVC],
                                                 configuration: .constant(SSTabConfiguration(
                                                    waveHeight: 25,
                                                    selectedTabTintColor: currentUserType.themeUIColor,
                                                    unselectedTabTintColor: AppUIColor.c999999,
                                                    shadowColor: AppUIColor.cF2F2F7)),
                                                 isTabBarHidden: self.$isTabBarHidden)
        return tabBarView
    }
}

// MARK: - Preview
struct UserTabView_Previews: PreviewProvider {
    static var previews: some View {
        UserTabView()
            .environmentObject(UserViewModel())
    }
}
