//
//  BookingCalendarView.swift
//  Astroyodha
//
//  Created by Tops on 21/11/22.
//

import SwiftUI
import FSCalendar
import Introspect

struct BookingCalendarView: View {
    @State var uiTabarController: UITabBarController?
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = BookingCalendarViewModel()
    var dateFormatter = DateFormatter()
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                ZStack(alignment: .top) {
                    CalendarViewRepresentable(selectedDate: $viewModel.selectedDate, pageCurrent: $viewModel.crntPage)
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                    
                    nextPreviousMonthView
                }
                selectedDateView
                selectedDateEventsView
            }
            
            navigationView
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
        }
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
        }
        .onAppear {
            uiTabarController?.tabBar.isHidden = false
            dateFormatter.dateFormat = viewModel.selectedDate.dateFormatWithSuffix()
            viewModel.strSelectedDate = dateFormatter.string(from: viewModel.selectedDate)
        }
        // Get the user selected date through the Notification Center
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.dateSelection))
        { obj in
            // Extracted selected date from the Dictionary and Fetch the selected date booking data
            if let userInfo = obj.userInfo, let info = userInfo["selectedDate"] {
                if let dtSelected = info as? Date {
                    dateFormatter.dateFormat = dtSelected.dateFormatWithSuffix()
                    viewModel.strSelectedDate = dateFormatter.string(from: dtSelected)
                    viewModel.fetchSelectedDateBookings(dtSelected: dtSelected)
                }
            }
        }
    }
}

struct BookingCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        BookingCalendarView()
    }
}

// MARK: - CALENDAR VIEW (WE HAVE USED SWIFT LIBRARY CODE INTO SWIFTUI THROUGH UIViewRepresentable)
struct CalendarViewRepresentable: UIViewRepresentable {
    typealias UIViewType = FSCalendar
    
    fileprivate var calendar = FSCalendar()
    @Binding var selectedDate: Date
    @Binding var pageCurrent: Date
    
    var userViewModel = UserViewModel()
    
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.appearance.todayColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        calendar.appearance.titleTodayColor = currentUserType.themeUIColor
        calendar.appearance.selectionColor = currentUserType.themeUIColor
        calendar.appearance.eventDefaultColor = .red
        calendar.appearance.titleTodayColor = currentUserType.themeUIColor
        calendar.appearance.titleFont = appUIFont(type: .poppinsRegular, size: 14)
        calendar.appearance.titleWeekendColor = AppUIColor.c242424
        calendar.appearance.weekdayTextColor = AppUIColor.c242424
        calendar.appearance.weekdayFont = appUIFont(type: .poppinsBold, size: 15)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.12
        calendar.appearance.headerTitleFont = appUIFont(type: .poppinsBold, size: 22)
        calendar.appearance.headerTitleColor = AppUIColor.c242424
        calendar.appearance.borderRadius = 0.3
        calendar.headerHeight = 60
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.clipsToBounds = false
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.setCurrentPage(pageCurrent, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarViewRepresentable
        
        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
        }
        
        // Fire Post notification when user select the data to get the selected date booking data. We have set the selected date into dictionary and pass that dictionary into the Notification center
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            var dictDate: [String: Date] = [:]
            dictDate["selectedDate"] = date
            NotificationCenter.default.post(name: NSNotification.dateSelection, object: nil, userInfo: dictDate)
        }
       
        func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
            return nil
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            var eventCount = 0
            Singletion.shared.arrBookingDates.forEach { eventDate in
                if eventDate.formatted(date: .complete, time: .omitted) == date.formatted(date: .complete, time: .omitted){
                    eventCount += 1;
                }
            }
            return eventCount
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return true
        }
    }
}

// MARK: - COMPONENTS
extension BookingCalendarView {
    // MARK: - Navigation View
    private var navigationView: some View {
        Text("")
            .navigationBarItems(leading: Text("Calendar"))
            .font(appFont(type: .poppinsRegular, size: 18))
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .navigationBarColor(backgroundColor: currentUserType.themeColor, titleColor: .white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButtonView
                }
            }
    }
    
    // MARK: - Back Button View
    private var backButtonView: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "arrow.left")
                .renderingMode(.template)
                .foregroundColor(.white)
        })
    }
    
    // MARK: - Next Previous Month Action view
    private var nextPreviousMonthView: some View {
        HStack (alignment: .top) {
            Button {
                viewModel.moveToPreviousMonth()
            } label: {
                Image("imgPrevious")
                    .resizable()
                    .frame(width: 12, height: 20)
            }
            .padding()
            .padding(.top, 8)
            .background(.white)

            Spacer()
            
            Button {
                viewModel.moveToNextMonth()
            } label: {
                Image("imgNext")
                    .resizable()
                    .frame(width: 12, height: 20)
            }
            .padding()
            .padding(.top, 8)
            .background(.white)
        }
    }
    
    // MARK: - Selected date View
    private var selectedDateView: some View {
        Text(viewModel.strSelectedDate + " Events")
            .font(appFont(type: .poppinsBold, size: 15))
            .foregroundColor(AppColor.c242424)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Selected Date Event View
    private var selectedDateEventsView: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                ForEach(0..<viewModel.bookings.count, id: \.self) { index in
                    let objBooking = viewModel.bookings[index]
                    
                    let startTime = Singletion.shared.convertDateFormate(date: objBooking.starttime, currentFormate: datePickerSelectedFormat, outputFormat: "hh:mm a")
                    let endTime = Singletion.shared.convertDateFormate(date: objBooking.endtime, currentFormate: datePickerSelectedFormat, outputFormat: "hh:mm a")
                    
                    HStack (alignment: .center, spacing: 10) {
                        Rectangle()
                            .fill(AppColor.c27AAE1)
                            .frame(width: UIScreen.main.bounds.width * 0.17, height: UIScreen.main.bounds.width * 0.2, alignment: .center)
                            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                            .overlay {
                                Image("imgBookingApproval")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 32)
                            }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Your Appointment with \((currentUserType == .user) ? objBooking.astrologername : objBooking.username)")
                                .lineLimit(2)
                                .font(appFont(type: .poppinsMedium, size: 15))
                                .foregroundColor(AppColor.c242424)
                                .padding(.horizontal, 5)
                            
                            Text("Time: \(startTime) to \(endTime)")
                                .font(appFont(type: .poppinsRegular, size: 13))
                                .foregroundColor(AppColor.c999999)
                                .padding(.horizontal, 5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height + 49, alignment: .center)
            .background(AppColor.cFAFAFA)
        }
    }
}
