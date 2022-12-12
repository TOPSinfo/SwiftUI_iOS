//
//  BookingCalendarViewModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation

class BookingCalendarViewModel: ObservableObject {
    @Published private(set) var arrAllBookings: [BookingAstrologerModel] = []
    @Published private(set) var arrSelectedDayBookings: [BookingAstrologerModel] = []
    
    @Published var selectedDate: Date = Date()
    @Published var crntPage: Date = Date()
    
    var firebase: FirebaseService = FirebaseService()
    @Published var bookings: [BookingAstrologerModel] = []
    @Published var strSelectedDate: String = ""
    
    @Published var dateFormatter = DateFormatter()
    
    init() {
        fetchBookingList()
        firebase.fetchSelectedDateBookings(selectedDate: selectedDate) { bookingsData in
            self.bookings = bookingsData
        }
    }
    
    // MARK: - Fetch Bookings
    func fetchBookingList() {
        firebase.fetchBookingsData { upcomingData, ongoingData, pastData in
            self.arrAllBookings.removeAll()
            self.arrAllBookings.append(contentsOf: upcomingData)
            self.arrAllBookings.append(contentsOf: ongoingData)
            self.arrAllBookings.append(contentsOf: pastData)
            
            self.arrSelectedDayBookings.removeAll()
            for booking in self.arrAllBookings {
                print(booking.starttime)
                
                let endDate = Singletion.shared.convertStringToDate(strDate: booking.date, outputFormate: datePickerDateFormat)
                
                let currentDate = Singletion.shared.convertStringToDate(strDate: Singletion.shared.convertDateFormate(date: self.selectedDate, currentFormate: datePickerSelectedFormat, outputFormat: datePickerDateFormatWithoutDash), outputFormate: datePickerDateFormatWithoutDash)
                
                let bookingDate = Singletion.shared.convertStringToDate(strDate: Singletion.shared.convertDateFormate(date: endDate, currentFormate: datePickerSelectedFormat, outputFormat: datePickerDateFormatWithoutDash), outputFormate: datePickerDateFormatWithoutDash)
                
                if bookingDate == currentDate {
                    self.arrSelectedDayBookings.append(booking)
                }
            }
            
            //Initially Fetch current date Bookings
            self.fetchSelectedDateBookings(dtSelected: self.selectedDate)
        }
    }
    
    // MARK: - Fetch Selected Date Bookings
    func fetchSelectedDateBookings(dtSelected: Date) {
        firebase.fetchSelectedDateBookings(selectedDate: dtSelected) { bookingsData in
            self.bookings = bookingsData
        }
    }
    
    // MARK: - Previous Month
    func moveToPreviousMonth() {
        self.crntPage = Calendar.current.date(byAdding: .month, value: -1, to: self.crntPage)!
    }
    
    // MARK: - Next Month
    func moveToNextMonth() {
        self.crntPage = Calendar.current.date(byAdding: .month, value: 1, to: self.crntPage)!
    }
}
