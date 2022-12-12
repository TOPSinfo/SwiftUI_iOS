//
//  AstrologerTabView.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI
import SSCustomTabbar

// MARK: - View
struct AstrologerTabView: View {
    @State var isTabBarHidden: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            tabView
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    SwiftUITabBarController.refreshViews()
            }
        }
    }
    
    var tabView: some View {
        let bookingVC = SwiftUITabView(content: UIHostingController(rootView: BookingListView()),
                                       title: "Booking",
                                       selectedImage: "tabBooking",
                                       unSelectedImage: "tabBooking")
        let profileVC = SwiftUITabView(content: UIHostingController(rootView: ProfileView()),
                                       title: "Profile",
                                       selectedImage: "tabProfile",
                                       unSelectedImage: "tabProfile")
        
        let tabBarView = SwiftUITabBarController(tabItems: [bookingVC, profileVC],
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
struct AstrologerTabView_Previews: PreviewProvider {
    static var previews: some View {
        AstrologerTabView()
            .environmentObject(UserViewModel())
    }
}
