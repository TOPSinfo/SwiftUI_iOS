//
//  EditProfileViewModel.swift
//  Astroyodha
//
//  Created by Tops on 06/12/22.
//

import Foundation
import SwiftUI

class EditProfileViewModel: ObservableObject {
    @Published var objLoggedInUser: UserModel?
    @Published var isFullNameChange: Bool = false
    @Published var strFullName: String = ""
    @Published var strPhoneNumber: String = ""
    @Published var isEmailChange: Bool = false
    @Published var strEmail: String = ""
    @Published var isDatePickerVisible: Bool = false
    @Published var datePickerBirthDate = Date()
    @Published var isTimePickerVisible: Bool = false
    @Published var datePickerTime = Date()
    @Published var isBirthPlaceChange: Bool = false
    @Published var strBirthPlace: String = ""
    @Published var showToast: Bool = false
    @Published var strAlertMessage: String = ""
    @Published var isLanguageVisible: Bool = false
    @Published var strLanguage: String = ""
    @Published var isAstrologyVisible: Bool = false
    @Published var strAstrology: String = ""
    @Published var isPriceChange: Bool = false
    @Published var strPrice: String = ""
    @Published var isExperienceChange: Bool = false
    @Published var strExperience: String = ""
    @Published var isAboutChange: Bool = false
    @Published var strAbout: String = ""
    @Published var isAppointmentTapped: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var pickedImage = UIImage(named: "imgProfile")!
    @Published var isCameraSelected = false
    @Published var actionSheet: Bool = false
    @Published var actionSheetOption: ActionSheetOption = .gallery
    @Published var isImageChanged: Bool = false
    @Published var arrAppointments: [AppointmentTimeSlotModel] = []
    @Published var arrLanguages: [LanguageObject] = []
    @Published var arrAstrology: [AstrologyObject] = []
    var firebase: FirebaseService = FirebaseService()
    
    init() {
        self.objLoggedInUser = Singletion.shared.objLoggedInUser
        self.getTimeslotList()
    }
    
    // MARK: - Image Picker
    func imagePickerview() -> some View {
        if isCameraSelected {
            return ImagePickerView(sourceType: .camera) { image in
                self.pickedImage = image
                self.isImageChanged = true
            }
        }
        else {
            return ImagePickerView(sourceType: .photoLibrary) { image in
                self.pickedImage = image
                self.isImageChanged = true
            }
        }
    }
    
    // MARK: - Photo Selection Action Sheet
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
            return ActionSheet(
                title: Text("Options"),
                message: Text("Select one option"),
                buttons: [cameraButton, gallaryButton, cancelButton])
            
            
        case .gallery:
            return ActionSheet(
                title: Text("Options"),
                message: Text("Select one option"),
                buttons: [cameraButton, gallaryButton, cancelButton])
        }
    }
    
    // MARK: - Set User Data
    func setUserData() {
        DispatchQueue.main.async {
            self.strFullName = self.objLoggedInUser?.fullname ?? ""
            self.strPhoneNumber = self.objLoggedInUser?.phone ?? ""
            self.strEmail = self.objLoggedInUser?.email ?? ""
            self.strBirthPlace = (self.objLoggedInUser?.birthplace ?? "")
            
            self.datePickerBirthDate = Singletion.shared.getDateMonthYearFromDate(
                birthDate: (self.objLoggedInUser?.birthdate ?? ""),
                inputFormat: datePickerDateFormatWithoutDash)
            self.datePickerTime = Singletion.shared.getDateMonthYearFromDate(
                birthDate: (self.objLoggedInUser?.birthtime ?? ""),
                inputFormat: datePickertimeFormat)
            
            // ASTROLOGER
            
            // LANGUAGE
            (self.objLoggedInUser?.languages ?? []).isEmpty
            ? (self.strLanguage = "Language") : (self.strLanguage = Singletion.shared.convertUserLanguagesIntoString(objLoggedInUser: self.objLoggedInUser!))
            self.arrLanguages = Singletion.shared.arrLanguage
            
            // ASTROLOGY
            (self.objLoggedInUser?.speciality ?? []).isEmpty
            ? (self.strAstrology = "Astrology Type") : (self.strAstrology =  Singletion.shared.convertUserAstrologyIntoString(objLoggedInUser: self.objLoggedInUser!))
            
            self.arrAstrology = Singletion.shared.arrAstrology
            
            // PRICE
            (self.objLoggedInUser?.price ?? 0) <= 0
            ? (self.strPrice = "") : (self.strPrice = "\(self.objLoggedInUser?.price ?? 0)")
            
            // EXPERIENCE
            (self.objLoggedInUser?.experience ?? 0) <= 0
            ? (self.strExperience = "") : (self.strExperience =  "\(self.objLoggedInUser?.experience ?? 0)")
            
            // ABOUT YOU
            self.strAbout = self.objLoggedInUser?.aboutYou ?? ""
        }
    }
    
    // MARK: - Upload Profile Photo
    func uploadProfileImage(dictUser: [String: Any], completion: @escaping (_ isCompleted: Bool) -> Void) {
        firebase.uploadProfileImage(imgPhoto: pickedImage,
                                    dict: dictUser,
                                    isUser: (currentUserType == .user) ? true : false) { isCompleted in
            Singletion.shared.hideProgress()
            if isCompleted {
                self.displayAlertWith(message: strProfileUpdated)
                Singletion.shared.hideProgress()
            } else {
                self.displayAlertWith(message: strTryAgainLater)
            }
            completion(isCompleted)
        }
    }
    
    // MARK: - Update User Data
    func updateUserData(dictUser: [String: Any],
                        completion: @escaping (_ isCompleted: Bool) -> Void) {
        firebase.updateUserData(dict: dictUser) { isCompleted in
            if isCompleted {
                self.displayAlertWith(message: strProfileUpdated)
                Singletion.shared.hideProgress()
            }
            completion(isCompleted)
        }
    }
    
    // MARK: - Update Astrologer Data
    func updateAstrologerData(dictAstrologer: [String: Any],
                              completion: @escaping (_ isCompleted: Bool) -> Void) {
        firebase.updateAstrologerData(dict: dictAstrologer) { isCompleted in
            if isCompleted {
                self.displayAlertWith(message: strProfileUpdated)
                Singletion.shared.hideProgress()
            }
            completion(isCompleted)
        }
    }
    
    // MARK: - Get Appointment TimeSlots
    func getTimeslotList() {
        firebase.getUserTimeSlots { appointments in
            self.arrAppointments = appointments
        }
    }
    
    // MARK: - Delete Timeslot Data
    func deleteTimeSlotData(objAppointment: AppointmentTimeSlotModel) {
        firebase.deleteAstrologerTimeSlotData(objSlot: objAppointment) { isCompleted in
            if isCompleted {
                if let index = self.arrAppointments.firstIndex(where: {$0.timeslotid == objAppointment.timeslotid}) {
                    self.arrAppointments.remove(at: index)
                }
                
                self.firebase.getUserTimeSlots { appointments in
                    self.arrAppointments = appointments
                    self.displayAlertWith(message: strTimeSlotDeleted)
                }
            }
        }
    }
    
    // MARK: - User Validation
    func isUserValidate() -> Bool {
        if strFullName.isEmpty {
            self.displayAlertWith(message: strEnterFullName)
            return false
        } else if strPhoneNumber.isEmpty {
            self.displayAlertWith(message: strEnterPhoneNumber)
            return false
        } else if strEmail.isEmpty {
            self.displayAlertWith(message: strEnterEmail)
            return false
        } else if !Singletion.shared.isValidEmail(strEmail) {
            self.displayAlertWith(message: strEnterValidEmail)
            return false
        }
        return true
    }
    
    // MARK: - Astrologer Validation
    func isAstrologerValidate() -> Bool {
        let strBirthDate = Singletion.shared.convertDateFormate(date: datePickerBirthDate,
                                                                currentFormate: datePickerSelectedFormat,
                                                                outputFormat: datePickerDateFormatWithoutDash)
        
        if strFullName.isEmpty {
            self.displayAlertWith(message: strEnterFullName)
            return false
        } else if strPhoneNumber.isEmpty {
            self.displayAlertWith(message: strEnterPhoneNumber)
            return false
        } else if strEmail.isEmpty {
            self.displayAlertWith(message: strEnterEmail)
            return false
        } else if !Singletion.shared.isValidEmail(strEmail) {
            self.displayAlertWith(message: strEnterValidEmail)
            return false
        } else if strBirthDate.isEmpty {
            self.displayAlertWith(message: strSelectBirthDate)
            return false
        } else if strAbout.isEmpty {
            self.displayAlertWith(message: strEnterAboutYou)
            return false
        }
        return true
    }
    
    // MARK: - Set Alert Message
    func displayAlertWith(message: String) {
        strAlertMessage = message
        showToast.toggle()
    }
    
    func isFullNameChanging(editingChanged: Bool) {
        if editingChanged {
            isFullNameChange = true
        } else {
            isFullNameChange = false
        }
    }
}
