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
                NavigationLink(
                    destination: BookingCalendarView(),
                    isActive: self.$bookingViewModel.isCalendarTapped) {EmptyView()}
                
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

// MARK: - COMPONENTS
extension BookingListView {
    // Navigaiton Bar
    private var navigationBarView: some View {
        Text("")
            .navigationBarItems(leading: Text(strMyBooking))
            .font(appFont(type: .poppinsBold, size: 22))
            .foregroundColor(AppColor.c242424)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .navigationBarColor(backgroundColor: .white,
                                titleColor: .black)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        Button {
                            bookingViewModel.isCalendarTapped.toggle()
                        } label: {
                            Image("imgCalendar")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(AppColor.c242424)
                                .frame(width: 22, height: 22)
                        }
                        
                        if currentUserType == .user {
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
    
    // Top TabBar
    private var swipableTopTabBarView: some View {
        VStack {
            CITTopTabBarView(selectedTab: $bookingViewModel.selectedTab,
                             tabs: $bookingViewModel.tabs,
                             config: bookingViewModel.config)
            
            TabView(selection: $bookingViewModel.selectedTab) {
                ForEach(Array(bookingViewModel.tabs.enumerated()), id: \.offset) { _, tab in
                    
                    if tab.title == BookingFilter.upcoming.rawValue.uppercased() {
                        if bookingViewModel.arrUpcomingBookings.isEmpty {
                            noDataFoundView
                        } else {
                            BookingItemView(arrBookings: $bookingViewModel.arrUpcomingBookings)
                        }
                    } else if tab.title == BookingFilter.ongoing.rawValue.uppercased() {
                        if bookingViewModel.arrOnGoingBookings.isEmpty {
                            noDataFoundView
                        } else {
                            BookingItemView(arrBookings: $bookingViewModel.arrOnGoingBookings)
                        }
                    } else if tab.title == BookingFilter.past.rawValue.uppercased() {
                        if bookingViewModel.arrPastBookings.isEmpty {
                            noDataFoundView
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
    
    // No Data Found View
    private var noDataFoundView: some View {
        Text(strNoDataFound)
            .font(appFont(type: .poppinsRegular, size: 17))
            .foregroundColor(AppColor.c242424)
    }
}

// MARK: - BOOKING ITEM VIEW
struct BookingItemView: View {
    @Binding var arrBookings: [BookingAstrologerModel]
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(0..<arrBookings.count, id: \.self) { index in
                    let objBooking = arrBookings[index]
                    let dateWords = objBooking.date.components(separatedBy: ["-"])
                    
                    let startTime = extractTimeFrom(date: objBooking.starttime)
                    let endTime = extractTimeFrom(date: objBooking.endtime)
                    
                    HStack(alignment: .center, spacing: 10) {
                        Rectangle()
                            .fill(
                                colorAsPerBookingStatus(objBooking: objBooking))
                            .frame(
                                width: UIScreen.main.bounds.width * 0.25,
                                height: UIScreen.main.bounds.width * 0.28,
                                alignment: .center)
                            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                            .overlay {
                                Text(dateWords[0] + "\n" + dateWords[1])
                                    .multilineTextAlignment(.center)
                                    .font(appFont(type: .poppinsBold, size: 18))
                                    .foregroundColor(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Your Appointment with \((currentUserType == .user) ? objBooking.astrologername : objBooking.username)")
                                .lineLimit(2)
                                .font(appFont(type: .poppinsRegular, size: 15))
                                .foregroundColor(AppColor.c242424)
                            
                            Text("Time: \(startTime) to \(endTime)")
                                .font(appFont(type: .poppinsRegular, size: 13))
                                .foregroundColor(AppColor.c999999)
                            
                            HStack {
                                Text(strStatus)
                                    .font(appFont(type: .poppinsRegular, size: 13))
                                    .foregroundColor(AppColor.c999999)
                                
                                Text(objBooking.status)
                                    .font(appFont(type: .poppinsRegular, size: 13))
                                    .foregroundColor(
                                        colorAsPerBookingStatus(objBooking: objBooking))
                            }
                        }
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
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
    
    func colorAsPerBookingStatus(objBooking: BookingAstrologerModel) -> Color {
        if objBooking.status == BookingStatus.approved.rawValue {
            return AppColor.c27AAE1
        } else if objBooking.status == BookingStatus.waiting.rawValue {
            return AppColor.cF1A341
        } else if objBooking.status == BookingStatus.rejected.rawValue {
            return AppColor.cF06649
        } else if objBooking.status == BookingStatus.deleted.rawValue {
            return AppColor.cBC2626
        } else if objBooking.status == BookingStatus.completed.rawValue {
            return AppColor.c80C181
        } else {
            return AppColor.c27AAE1
        }
    }
}
