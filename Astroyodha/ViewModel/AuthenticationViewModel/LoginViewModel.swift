//
//  LoginViewModel.swift
//  Astroyodha
//
//  Created by Tops on 02/12/22.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var strAlertMessage = ""
    @Published var strPhoneNumber = ""
    @Published var selectedCountryCode = "+91"
    @Published var selectedCountry = "Afghanistan"
    @Published var isTextFieldChange = false
    @Published var isUserLoggedIn = false
    @Published var showToast = false
    var dropDownList = Country.countryNamesByCode()
    var firebase: FirebaseService = FirebaseService()
    
    // Check wether the given Mobile number is exist or not and then do further steps
    func fireBaseSendOTPCode() {
        let phone = selectedCountryCode + strPhoneNumber
        /*
         - Check Phone number is already exist or not.
         - If Phone number is exist then send OTP to the phone number
         - If Phone number is not exist then show Number is not registered
         */
        firebase.checkMobileNumberIsExistOrNot(strPhoneNumber: phone, completion: { isCompleted in
            if isCompleted {
                // send otp for new user
                self.firebase.loginUser(strPhoneNumber: phone) { isSuccess in
                    if isSuccess {
                        objUser.phone = phone
                        self.isUserLoggedIn = true
                    } else {
                        self.isUserLoggedIn = false
                        self.displayAlertWith(message: strMobileNotRegisteredDoSignUp)
                    }
                }
            } else {
                Singletion.shared.hideProgress()
                self.displayAlertWith(message: strMobileNotRegistered)
            }
        })
    }
    
    // MARK: - Phone Number Validation
    func isValidate() -> Bool {
        if strPhoneNumber.isEmpty {
            displayAlertWith(message: strEnterPhoneNumber)
            return false
        } else if !Singletion.shared.isValidPhone(phone: "\(strPhoneNumber)") {
            displayAlertWith(message: strEnterValidPhoneNumber)
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Set Alert Message
    func displayAlertWith(message: String) {
        strAlertMessage = message
        showToast.toggle()
    }
}
