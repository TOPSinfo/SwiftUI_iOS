//
//  TimeSlotViewModel.swift
//  Astroyodha
//
//  Created by Tops on 06/12/22.
//

import Foundation
import SwiftUI
import Firebase

class TimeSlotViewModel: ObservableObject {
    @Published var currentTimeSlot: TimeSlot = TimeSlot.repeatOption
    @Published var repeatTitle: String = "Repeat"
    @Published var isRepeatPopupShow: Bool = false
    @Published var isStartDateSelected: Bool = false
    @Published var strStartDateTitle: String = "Start Date"
    @Published var datePickerStartDate = Date()
    @Published var isEndDateSelected: Bool = false
    @Published var strEndDateTitle: String = "End Date"
    @Published var datePickerEndDate = Date()
    @Published var isStartTimeSelected: Bool = false
    @Published var strStartTimeTitle: String = "Start Time"
    @Published var timePickerStartTime = Date()
    @Published var isEndTimeSelected: Bool = false
    @Published var strEndTimeTitle: String = "End Time"
    @Published var timePickerEndTime = Date()
    @Published var showToast: Bool = false
    @Published var strAlertMessage: String = ""
    @Published var arrDays: [DayObject] = []
    @Published var arrRepeat: [RepeatObject] = []
    var firebase: FirebaseService = FirebaseService()
    
    init() {
        arrDays = Singletion.shared.arrDays
        self.objectWillChange.send()
        
        arrRepeat = Singletion.shared.arrRepeat
        arrRepeat[0].isSelected = true
    }
    
    // MARK: - Time Slot Validation
    func isValideTimeSlot(completion: @escaping (_ isCompleted: Bool) -> Void) {
        let strStartDate = convert(date: datePickerStartDate,
                                       fromFormat: datePickerSelectedFormat,
                                       toFormat: datePickerDateFormat)
        let strEndDate = convert(date: datePickerEndDate,
                                     fromFormat: datePickerSelectedFormat,
                                     toFormat: datePickerDateFormat)
        let strStartTime = convert(date: timePickerStartTime,
                                       fromFormat: datePickerSelectedFormat,
                                       toFormat: datePickertimeFormat)
        let strEndTime = convert(date: timePickerEndTime,
                                     fromFormat: datePickerSelectedFormat,
                                     toFormat: datePickertimeFormat)
        
        // CHECK THE CURRENT SELECTED TIME SLOT OPTION
        if currentTimeSlot == .repeatOption {
            // IF ALL SELECTED DETAILS ARE VALID THEN ADD SELETED DATA INTO DATABASE
            let isValidRepeat = self.isValidRepeateSelection(strStartDate: strStartDate,
                                                             strEndDate: strEndDate,
                                                             strStartTime: strStartTime,
                                                             strEndTime: strEndTime)
            
            if isValidRepeat {
                if let userUID = Auth.auth().currentUser?.uid {
                    let randomDocumentID: String = Singletion.shared.randomAlphaNumericString(length: 20)
                    print(randomDocumentID)
                    
                    let objTimeSlot = AppointmentTimeSlotModel.init(startDate: strStartDate,
                                                                    startTime: strStartTime,
                                                                    endDate: strEndDate,
                                                                    endTime: strEndTime,
                                                                    repeatDays: [],
                                                                    timeslotid: randomDocumentID,
                                                                    type: currentTimeSlot.rawValue,
                                                                    uid: userUID)
                    
                    // ADD DATA INTO DATABASE
                    self.addTimeSlotData(objTimeSlot: objTimeSlot) { isCompleted in
                        completion(isCompleted)
                    }
                }
            }
        } else if currentTimeSlot == .weeklyOption {
            // IF ALL SELECTED DETAILS ARE VALID THEN ADD SELETED DATA INTO DATABASE
            let isValidWeekly = self.isValideWeeklySelection(strStartTime: strStartTime,
                                                             strEndTime: strEndTime)
            
            if isValidWeekly {
                let arrUpdateNames = arrDays.filter({ return $0.isSelected == true })
                var arrName = arrUpdateNames.map({ (weekDay: DayObject) -> String in
                    weekDay.name.lowercased()
                })
                
                arrName = arrName.map { $0.capitalized }
                if let userUID = Auth.auth().currentUser?.uid {
                    let randomDocumentID: String = Singletion.shared.randomAlphaNumericString(length: 20)
                    print(randomDocumentID)
                    
                    let objTimeSlot = AppointmentTimeSlotModel.init(startDate: "",
                                                                    startTime: strStartTime,
                                                                    endDate: "",
                                                                    endTime: strEndTime,
                                                                    repeatDays: arrName,
                                                                    timeslotid: randomDocumentID,
                                                                    type: currentTimeSlot.rawValue,
                                                                    uid: userUID)
                    
                    self.addTimeSlotData(objTimeSlot: objTimeSlot) { isCompleted in
                        completion(isCompleted)
                    }
                }
            }
        } else if currentTimeSlot == .customOption {
            // IF ALL SELECTED DETAILS ARE VALID THEN ADD SELETED DATA INTO DATABASE
            let isValidCustom = self.isValidCustomSelection(strStartDate: strStartDate,
                                                            strStartTime: strStartTime,
                                                            strEndTime: strEndTime)
            
            if isValidCustom {
                if let userUID = Auth.auth().currentUser?.uid {
                    let randomDocumentID: String = Singletion.shared.randomAlphaNumericString(length: 20)
                    print(randomDocumentID)
                    
                    let objTimeSlot = AppointmentTimeSlotModel.init(startDate: strStartDate,
                                                                    startTime: strStartTime,
                                                                    endDate: "",
                                                                    endTime: strEndTime,
                                                                    repeatDays: [],
                                                                    timeslotid: randomDocumentID,
                                                                    type: currentTimeSlot.rawValue,
                                                                    uid: userUID)
                    
                    self.addTimeSlotData(objTimeSlot: objTimeSlot) { isCompleted in
                        completion(isCompleted)
                    }
                }
            }
        }
    }
    
    // MARK: - Repeat Action Validation
    func isValidRepeateSelection(strStartDate: String,
                                 strEndDate: String,
                                 strStartTime: String,
                                 strEndTime: String) -> Bool {
        if strStartDate.isEmpty {
            self.displayAlertWith(message: strSelectDate)
            return false
        } else if strEndDate.isEmpty {
            self.displayAlertWith(message: strSelectDate)
            return false
        } else if strStartTime.isEmpty {
            self.displayAlertWith(message: strSelectStartTime)
            return false
        } else if strEndTime.isEmpty {
            self.displayAlertWith(message: strSelectEndTime)
            return false
        } else {
            if strStartDate == strEndDate {
                self.displayAlertWith(message: strSelectEndDateGreaterThanStartDate)
                return false
            } else if datePickerEndDate < datePickerStartDate {
                self.displayAlertWith(message: strSelectEndDateGreaterThanStartDate)
                return false
            } else if strStartTime == strEndTime {
                self.displayAlertWith(message: strSelectEndTimeGreaterThanStartTime)
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: - Weekly Action Validation
    func isValideWeeklySelection(strStartTime: String,
                                 strEndTime: String) -> Bool {
        let selectedDaysCount = arrDays.filter({ $0.isSelected == true }).count
        
        if selectedDaysCount <= 0 {
            self.displayAlertWith(message: strSelectDays)
            return false
        } else if strStartTime.isEmpty {
            self.displayAlertWith(message: strSelectStartTime)
            return false
        } else if strEndTime.isEmpty {
            self.displayAlertWith(message: strSelectEndTime)
            return false
        } else {
            if strStartTime == strEndTime {
                self.displayAlertWith(message: strSelectEndTimeGreaterThanStartTime)
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: - Custom Action Validation
    func isValidCustomSelection(strStartDate: String,
                                strStartTime: String,
                                strEndTime: String) -> Bool {
        if strStartDate.isEmpty {
            self.displayAlertWith(message: strSelectDate)
            return false
        } else if strStartTime.isEmpty {
            self.displayAlertWith(message: strSelectStartTime)
            return false
        } else if strEndTime.isEmpty {
            self.displayAlertWith(message: strSelectEndTime)
            return false
        } else {
            if strStartTime == strEndTime {
                self.displayAlertWith(message: strSelectEndTimeGreaterThanStartTime)
                return false
            } else {
                return true
            }
        }
    }
    
    func changeTimeSlotRepeatSelection(index: Int) {
        arrRepeat.indices.forEach { arrRepeat[$0].isSelected = false }
        arrRepeat[index].isSelected.toggle()
        if index == 0 {
            currentTimeSlot = .repeatOption
        } else if index == 1 {
            currentTimeSlot = .weeklyOption
        } else {
            currentTimeSlot = .customOption
        }
        
        isRepeatPopupShow.toggle()
    }
    
    // MARK: - Add TimeSlot Data
    private func addTimeSlotData(objTimeSlot: AppointmentTimeSlotModel,
                                 completion: @escaping (_ isCompleted: Bool) -> Void) {
        Singletion.shared.showDefaultProgress()
        firebase.addAstrologerTimeSlotData(objSlot: objTimeSlot) { isCompleted in
            if isCompleted {
                Singletion.shared.hideProgress()
            } else {
                Singletion.shared.hideProgress()
            }
            completion(isCompleted)
        }
    }
    
    // MARK: - Set Alert Message
    func displayAlertWith(message: String) {
        strAlertMessage = message
        showToast.toggle()
    }
}
