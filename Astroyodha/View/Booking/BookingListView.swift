//
//  UserBookingView.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI
import Introspect

enum BookingFilter: String {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case past = "Past"
}

enum BookingStatus: String {
    case approved = "approve"
    case waiting = "waiting"
    case rejected = "rejected"
    case deleted = "deleted"
    case completed = "completed"
}

// MARK: -
struct BookingListView: View {
    @State var uiTabarController: UITabBarController?
    @StateObject private var bookingViewModel = BookingViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                
                swipableTopTabBarView
                    .edgesIgnoringSafeArea(.all)
                NavigationLink(destination: BookingCalendarView(), isActive: self.$bookingViewModel.isCalendarTapped) {EmptyView()}
                
                navigationBarView
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .introspectTabBarController { (UITabBarController) in
                        UITabBarController.tabBar.isHidden = false
                        uiTabarController = UITabBarController
                    }
                    .onAppear {
                        uiTabarController?.tabBar.isHidden = false
                    }
            }
        }
    }
}

struct BookingListView_Previews: PreviewProvider {
    static var previews: some View {
        BookingListView()
    }
}

//MARK: - COMPONENTS
extension BookingListView {
    //Navigaiton Bar
    private var navigationBarView: some View {
        Text("")
            .navigationBarItems(leading: Text("My Bookings"))
            .font(appFont(type: .poppinsBold, size: 22))
            .foregroundColor(AppColor.c242424)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .navigationBarColor(backgroundColor: .white, titleColor: .black)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack (spacing: 10) {
                        Button {
                            bookingViewModel.isCalendarTapped.toggle()
                        } label: {
                            Image("imgCalendar")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(AppColor.c242424)
                                .frame(width: 22, height: 22)
                        }
                        
                        if (currentUserType == .user) {
                            NavigationLink(destination: {
                                UserGridView()
                            },
                                           label: {
                                Image("imgAdd")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundColor(AppColor.c242424)
                                    .frame(width: 22, height: 22)
                            })
                        }
                    }
                }
            }
    }
    
    //Top TabBar
    private var swipableTopTabBarView: some View {
        VStack {
            CITTopTabBarView(selectedTab: $bookingViewModel.selectedTab, tabs: $bookingViewModel.tabs, config: bookingViewModel.config)
            
            TabView(selection: $bookingViewModel.selectedTab) {
                ForEach(Array(bookingViewModel.tabs.enumerated()), id: \.offset) { offset, tab in
                    
                    if (tab.title == BookingFilter.upcoming.rawValue.uppercased()) {
                        if (bookingViewModel.arrUpcomingBookings.isEmpty) {
                            Text("No Data Found")
                                .font(appFont(type: .poppinsRegular, size: 17))
                                .foregroundColor(AppColor.c242424)
                        } else {
                            BookingItemView(arrBookings: $bookingViewModel.arrUpcomingBookings)
                        }
                    }
                    else if (tab.title == BookingFilter.ongoing.rawValue.uppercased()) {
                        if (bookingViewModel.arrOnGoingBookings.isEmpty) {
                            Text("No Data Found")
                                .font(appFont(type: .poppinsRegular, size: 17))
                                .foregroundColor(AppColor.c242424)
                        } else {
                            BookingItemView(arrBookings: $bookingViewModel.arrOnGoingBookings)
                        }
                    }
                    else if (tab.title == BookingFilter.past.rawValue.uppercased()) {
                        if (bookingViewModel.arrPastBookings.isEmpty) {
                            Text("No Data Found")
                                .font(appFont(type: .poppinsRegular, size: 17))
                                .foregroundColor(AppColor.c242424)
                        } else {
                            BookingItemView(arrBookings: $bookingViewModel.arrPastBookings)
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

//MARK: - BOOKING ITEM VIEW
struct BookingItemView: View {
    @Binding var arrBookings: [BookingAstrologerModel]
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(0..<arrBookings.count, id: \.self) { index in
                    let objBooking = arrBookings[index]
                    let dateWords = objBooking.date.components(separatedBy: ["-"])
                    
                    let startTime = Singletion.shared.convertDateFormate(date: objBooking.starttime, currentFormate: datePickerSelectedFormat, outputFormat: "hh:mm a")
                    let endTime = Singletion.shared.convertDateFormate(date: objBooking.endtime, currentFormate: datePickerSelectedFormat, outputFormat: "hh:mm a")
                    
                    HStack (alignment: .center, spacing: 10) {
                        Rectangle()
                            .fill((objBooking.status == BookingStatus.approved.rawValue) ? AppColor.c27AAE1 : (objBooking.status == BookingStatus.waiting.rawValue) ? AppColor.cF1A341 : (objBooking.status == BookingStatus.rejected.rawValue) ? AppColor.cF06649 : (objBooking.status == BookingStatus.deleted.rawValue) ? AppColor.cBC2626 : (objBooking.status == BookingStatus.completed.rawValue) ? AppColor.c80C181 : AppColor.c27AAE1)
                            .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.28, alignment: .center)
                            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                            .overlay {
                                Text(dateWords[0] + "\n" + dateWords[1])
                                    .multilineTextAlignment(.center)
                                    .font(appFont(type: .poppinsBold, size: 18))
                                    .foregroundColor(.white)
                            }
                        
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Your Appointment with \((currentUserType == .user) ? objBooking.astrologername : objBooking.username)")
                                .lineLimit(2)
                                .font(appFont(type: .poppinsRegular, size: 15))
                                .foregroundColor(AppColor.c242424)
                            
                            Text("Time: \(startTime) to \(endTime)")
                                .font(appFont(type: .poppinsRegular, size: 13))
                                .foregroundColor(AppColor.c999999)
                            
                            HStack {
                                Text("Status:")
                                    .font(appFont(type: .poppinsRegular, size: 13))
                                    .foregroundColor(AppColor.c999999)
                                
                                Text(objBooking.status)
                                    .font(appFont(type: .poppinsRegular, size: 13))
                                    .foregroundColor((objBooking.status == BookingStatus.approved.rawValue) ? AppColor.c27AAE1 : (objBooking.status == BookingStatus.waiting.rawValue) ? AppColor.cF1A341 : (objBooking.status == BookingStatus.rejected.rawValue) ? AppColor.cF06649 : (objBooking.status == BookingStatus.deleted.rawValue) ? AppColor.cBC2626 : (objBooking.status == BookingStatus.completed.rawValue) ? AppColor.c80C181 : AppColor.c27AAE1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(AppColor.cFAFAFA)
                    .cornerRadius(10)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                }
                .padding(.bottom, 10)
            }
        }
    }
}
