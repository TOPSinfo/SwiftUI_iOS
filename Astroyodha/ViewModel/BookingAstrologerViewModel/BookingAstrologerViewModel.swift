//
//  BookingAstrologerViewModel.swift
//  Astroyodha
//
//  Created by Tops on 02/11/22.
//

import Foundation
import SwiftUI

class BookingAstrologerViewModel: ObservableObject {
    @Published var astrologerBookingList = [BookingAstrologerModel]()
    @Published var strAlertMessage = ""
    @Published var strDetails = ""
    @Published var strFullName = ""
    @Published var strPlaceOfBirth = ""
    @Published var strDurationSelection = "15 minutes"
    @Published var strPaymentModeText = "Select payment mode"
    @Published var strNotificationSelection = "5 minutes before"
    @Published var strPaymentModeSelection = "Pay with wallet"
    @Published var datePicker = Date()
    @Published var datePickerBirthDate = Date()
    @Published var timePicker = Date()
    @Published var timePickerBirth = Date()
    @Published var pickedImage = UIImage(named: "imgUploadImage")!
    @Published var pickedImageKundali = UIImage(named: "imgUploadImage")!
    @Published var showToast = false
    @Published var isCameraSelected = false
    @Published var showImagePicker = false
    @Published var actionSheet: Bool = false
    @Published var actionSheetOption : ActionSheetOption = .gallery
    @Published var cameraSheet: cameraSheet?

    var arrDuration = ["15 minutes", "30 minutes", "45 minutes", "60 minutes"]
    var arrNotification = ["5 minutes before", "10 minutes before", "15 minutes before", "30 minutes before", "1 hour before", "1 hour after"]
    var arrPaymentOption = ["Pay with wallet", "Pay with online"]
    
    var dateRange: ClosedRange<Date> {
        let TenDaysAfter = Calendar.current.date(byAdding: .day, value: +10, to: Date())!
        let currentDayBefore = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        return currentDayBefore...TenDaysAfter
    }
    
    var firebase: FirebaseService = FirebaseService()
    
    // MARK: - Image Picker
    func imagePickerView() -> some View {
        if isCameraSelected {
            return ImagePickerView(sourceType: .camera) { image in
                if self.cameraSheet == .first {
                    self.pickedImage = image
                } else {
                    self.pickedImageKundali = image
                }
            }
        } else {
            return ImagePickerView(sourceType: .photoLibrary) { image in
                if self.cameraSheet == .first {
                    self.pickedImage = image
                } else {
                    self.pickedImageKundali = image
                }
            }
        }
    }
    
    // MARK: - ACTION SHEET
    func showActionSheet() -> ActionSheet {
        let cameraButton: ActionSheet.Button = .default(Text("Camera")) {
            self.isCameraSelected = true
            self.showImagePicker = true
        }
        
        let gallaryButton: ActionSheet.Button = .default(Text("Gallery")) {
            self.isCameraSelected = false
            self.showImagePicker = true
        }
        
        let cancelButton: ActionSheet.Button = .cancel()
        switch actionSheetOption {
        case .camera:
            return ActionSheet(title: Text(""),
                               message: Text("Select Option"),
                               buttons: [cameraButton, gallaryButton, cancelButton])
        case .gallery:
            return ActionSheet(title: Text(""),
                               message: Text("Select Option"),
                               buttons: [cameraButton, gallaryButton, cancelButton])
        }
    }
    
    // MARK: - BUTTON ACTION FOR PAYMENT MODE
    func cancelPaymentMode() {
        strPaymentModeText = "Select payment mode"
    }
    
    func btnPayOnline() {
        strPaymentModeText = "Pay with online"
    }
    
    func btnPayWallet() {
        strPaymentModeText = "Pay with wallet"
    }
    
    // MARK: - VALIDATIONS
    func isValidate() -> Bool {
        if strDetails.isEmpty {
            displayAlertWith(message: strEnterUserDetail)
            return false
        } else if pickedImage.isEqual(UIImage(named: "imgUploadImage")) {
            displayAlertWith(message: strUploadPhoto)
            return false
        } else if pickedImageKundali.isEqual(UIImage(named: "imgUploadImage")) {
            displayAlertWith(message: strUploadKundali)
            return false
        } else if strPlaceOfBirth.isEmpty {
            displayAlertWith(message: strAddBirthPlace)
            return false
        }
        return true
    }
    
    // MARK: - Set Alert Message
    func displayAlertWith(message: String) {
        strAlertMessage = message
        showToast.toggle()
    }
    
    // MARK: SET BOOKING DATA TO FIREBASE
    func addBookingData(selectedAstrologer: AstrologerGridItmeVM?,
                        completion: @escaping (_ isCompleted: Bool) -> Void) {
        if isValidate() {
            UIApplication.shared.dismissKeyboard()
            Singletion.shared.showDefaultProgress()
            
            let strNotification:String = strNotificationSelection
            let strNotificationSelectionWitoutMin = String(strNotification.prefix(2))
            let finalTramNotification = strNotificationSelectionWitoutMin.trimmingCharacters(in: .whitespaces)
            
            let strMyBirthDate = Singletion.shared.convertDateFormate(date: datePickerBirthDate,
                                                                      currentFormate: datePickerDateFormat,
                                                                      outputFormat: "dd MMM yyyy")
            let strBirthMonth = Singletion.shared.convertDateFormate(date: datePickerBirthDate,
                                                                     currentFormate: datePickerDateFormat,
                                                                     outputFormat: "MM")
            let strBirthYear = Singletion.shared.convertDateFormate(date: datePickerBirthDate,
                                                                    currentFormate: datePickerDateFormat,
                                                                    outputFormat: "yyyy")
            let strMyBirthTime = Singletion.shared.convertDateFormate(date: timePickerBirth,
                                                                      currentFormate: "h:mm a",
                                                                      outputFormat: "h:mm a")
            let strSelectedDate = Singletion.shared.convertDateFormate(date: datePicker,
                                                                       currentFormate: datePickerDateFormat,
                                                                       outputFormat: "dd-MMM-yyyy")
            
            let randomDocumentIDBooking: String = Singletion.shared.randomAlphaNumericString(length: 20)
            
            let str:String = strDurationSelection
            let intDuration = Int(str.prefix(2))!
            let endTime = Calendar.current.date(byAdding: .minute, value: intDuration, to: timePicker)!
            
            if let objLoginDataCache = LoginDataCache.get() {
                objAddBooking.allowextend = "no"
                objAddBooking.amount = selectedAstrologer!.price
                objAddBooking.astrologercharge = Int(getPaymentAmount(selectedAstrologer: selectedAstrologer))!
                objAddBooking.astrologerid = selectedAstrologer!.uid
                objAddBooking.astrologername = selectedAstrologer!.name
                objAddBooking.birthdate = strMyBirthDate
                objAddBooking.birthplace = strPlaceOfBirth
                objAddBooking.birthtime = strMyBirthTime
                objAddBooking.bookingid = randomDocumentIDBooking
                objAddBooking.date = strSelectedDate
                objAddBooking.month = strBirthMonth
                objAddBooking.year = strBirthYear
                objAddBooking.starttime = timePicker
                objAddBooking.endtime = endTime
                objAddBooking.description = strDetails
                objAddBooking.extendtime = 0
                objAddBooking.fullName = strFullName
                objAddBooking.kundali = ""
                objAddBooking.kundalipath = ""
                objAddBooking.notificationmin = finalTramNotification
                objAddBooking.notify = strNotificationSelection
                objAddBooking.paymentstatus = ""
                objAddBooking.paymenttype = strPaymentModeSelection
                objAddBooking.photo = ""
                objAddBooking.status = "approve"
                objAddBooking.transactionid = ""
                objAddBooking.uid = objLoginDataCache.uid
                objAddBooking.userbirthdate = objLoginDataCache.birthdate
                objAddBooking.username = objLoginDataCache.fullname
                objAddBooking.userprofileimage = objLoginDataCache.profileimage
                
                firebase.uploadImage(imageProfile: pickedImage,
                                     imageKundali: pickedImageKundali,
                                     timeslotid: randomDocumentIDBooking) { isCompleted in
                    if isCompleted {
                        self.displayAlertWith(message: strEventAdded)
                        Singletion.shared.hideProgress()
                    } else {
                        self.displayAlertWith(message: strTryAgainLater)
                        Singletion.shared.hideProgress()
                    }
                    completion(isCompleted)
                }
            }
        }
    }
    
    // get payment amount
    func getPaymentAmount(selectedAstrologer: AstrologerGridItmeVM?) -> String {
        let intDuration = Int(strDurationSelection.prefix(2))!
        let intMinAmount = (intDuration / 15)
        let title = (intMinAmount * selectedAstrologer!.price).description
        return title
    }
    
    func changePhotoSelection(isKundaliPhoto: Bool) {
        if !isKundaliPhoto {
            cameraSheet = .first
        } else {
            cameraSheet = .second
        }
        actionSheet.toggle()
    }
}
