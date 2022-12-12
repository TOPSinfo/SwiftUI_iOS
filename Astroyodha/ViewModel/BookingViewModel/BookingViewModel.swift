//
//  BookingViewModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation
import SwiftUI

class BookingViewModel: ObservableObject {
    @Published var tabs: [CITTopTab] = [
        .init(title: BookingFilter.upcoming.rawValue.uppercased(), icon: nil),
        .init(title: BookingFilter.ongoing.rawValue.uppercased(), icon: nil),
        .init(title: BookingFilter.past.rawValue.uppercased(), icon: nil)
    ]
    
    var config: CITTopTabBarView.Configuration {
        var example: CITTopTabBarView.Configuration = .exampleUnderlined
        example.underlineColor = currentUserType.themeColor
        example.font = appFont(type: .poppinsRegular, size: 14)
        example.textColor = AppColor.c999999
        example.backgroundColor = AppColor.cFAFAFA
        example.selectedTextColor = currentUserType.themeColor
        example.widthMode = .fixed
        example.tabBarInsets = EdgeInsets.init(top: 10, leading: 0, bottom: 0, trailing: 0)
        return example
    }
    
    @Published var isCalendarTapped: Bool = false
    
    @Published var currentBooking: BookingFilter = .upcoming
    @Published var selectedTab: Int = 0
    
    @Published var arrUpcomingBookings: [BookingAstrologerModel] = []
    @Published var arrOnGoingBookings: [BookingAstrologerModel] = []
    @Published var arrPastBookings: [BookingAstrologerModel] = []
    
    @Published private(set) var arrAllBookings: [BookingAstrologerModel] = []
    
    var firebase: FirebaseService = FirebaseService()
    
    var arrBookingDates: [Date] = []
    
    init() {
        fetchBookingList()
    }
    
    // MARK: - Fetch Booking List
    func fetchBookingList() {
        firebase.fetchBookingsData { upcomingData, ongoingData, pastData in
            self.arrAllBookings.removeAll()
            self.arrUpcomingBookings = upcomingData
            self.arrOnGoingBookings = ongoingData
            self.arrPastBookings = pastData
            
            self.arrAllBookings.append(contentsOf: upcomingData)
            self.arrAllBookings.append(contentsOf: ongoingData)
            self.arrAllBookings.append(contentsOf: pastData)
            
            // After fetching the bookings data we are creating one booking date array to show the dot in calendar View
            self.arrBookingDates = self.arrAllBookings.map({ (booking: BookingAstrologerModel) -> Date in
                return Singletion.shared.convertStringToDate(strDate: booking.date, outputFormate: datePickerDateFormat)
            })
            
            var result = Set<Date>()
            _ = self.arrBookingDates.map{ result.insert($0) }
            
            Singletion.shared.arrBookingDates = result.sorted()
        }
    }
}
