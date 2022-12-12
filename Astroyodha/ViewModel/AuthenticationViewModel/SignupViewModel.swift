//
//  SignupViewModel.swift
//  Astroyodha
//
//  Created by Tops on 02/12/22.
//

import Foundation
import SwiftUI

class SignupViewModel: ObservableObject {
    @Published var strAlertMessage = ""
    @Published  var strPhoneNumber = ""
    @Published var strFirstName = ""
    @Published var strEmail = ""
    @Published var selectedCountryCode = "+91"
    @Published var selectedCountry = "Afghanistan"
    
    @Published var checkState: Bool = false
    @Published var isFirstNameChange = false
    @Published var isPhoneNumberChange = false
    @Published var isChangeEmail = false
    @Published var isChecked = false
    @Published var isUserSignUp = false
    @Published var showToast = false
    
    @Published var trimVal : CGFloat = 0
    var dropDownList = Country.countryNamesByCode()
    var firebase: FirebaseService = FirebaseService()
    
    // Check wether the given Mobile number is exist or not and then do further steps
    func fireBaseSendOTPCode() {
        let phone = selectedCountryCode + strPhoneNumber
        //check email already exist or not
        firebase.checkMobileNumberIsExistOrNot(strPhoneNumber: phone, completion: { isCompleted in
            if !isCompleted {
                // send otp for new user
                self.firebase.loginUser(strPhoneNumber: phone) { isSuccess in
                    if isSuccess {
                        // store data in object
                        objUser.fullname = self.strFirstName
                        objUser.phone = phone
                        objUser.email = self.strEmail.lowercased()
                        self.isUserSignUp.toggle()
                    } else {
                        Singletion.shared.hideProgress()
                        self.displayAlertWith(message: strTryAgainLater)
                    }
                }
            } else {
                Singletion.shared.hideProgress()
                self.displayAlertWith(message: strMobilealreadyRegistered)
            }
        })
    }
    
    // MARK: - VALIDATION
    func isValidate() -> Bool {
        if strFirstName.isEmpty {
            self.displayAlertWith(message: strMobilealreadyRegistered)
            return false
        } else if strPhoneNumber.isEmpty {
            self.displayAlertWith(message: strEnterPhoneNumber)
            return false
        }else if !Singletion.shared.isValidPhone(phone: "\(strPhoneNumber)") {
            self.displayAlertWith(message: strEnterValidPhoneNumber)
            return false
        }  else if strEmail.isEmpty {
            self.displayAlertWith(message: strEnterEmail)
            return false
        } else if !Singletion.shared.isValidEmail(strEmail) {
            self.displayAlertWith(message: strEnterValidEmail)
            return false
        } else if !isChecked {
            self.displayAlertWith(message: strAcceptPrivacyPolicy)
            return false
        }
        return true
    }
    
    // MARK: - Set Alert Message
    func displayAlertWith(message: String) {
        strAlertMessage = message
        showToast.toggle()
    }
}
