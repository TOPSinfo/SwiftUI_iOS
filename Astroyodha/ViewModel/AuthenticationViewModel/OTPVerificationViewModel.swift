//
//  OTPVerificationViewModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation
import SwiftUI
import Firebase

class OTPVerificationViewModel: ObservableObject {
    @Published var id = ""
    @Published var strAlertMessage = ""
    @Published var timeRemaining = 10
    
    @Published var isFromLogin = false
    @Published var isFocused = false
    @Published var isValidationPass = false
    @Published var isResendOTP = false
    @Published var showToast = false
    
    @Published var otpField = "" {
        didSet {
            guard otpField.count <= 6,
                  otpField.last?.isNumber ?? true else {
                      otpField = oldValue
                      return
                  }
        }
    }
    var otp1: String {
        guard otpField.count >= 1 else {
            return ""
        }
        return String(Array(otpField)[0])
    }
    var otp2: String {
        guard otpField.count >= 2 else {
            return ""
        }
        return String(Array(otpField)[1])
    }
    var otp3: String {
        guard otpField.count >= 3 else {
            return ""
        }
        return String(Array(otpField)[2])
    }
    var otp4: String {
        guard otpField.count >= 4 else {
            return ""
        }
        return String(Array(otpField)[3])
    }
    
    var otp5: String {
        guard otpField.count >= 5 else {
            return ""
        }
        return String(Array(otpField)[4])
    }
    
    var otp6: String {
        guard otpField.count >= 6 else {
            return ""
        }
        return String(Array(otpField)[5])
    }
    
    @Published var borderColor: UIColor = .black
    @Published var isTextFieldDisabled = false
    var successCompletionHandler: (()->())?
    
    @Published var showResendText = false
    
    @Published var objLoggedInUser: UserModel?
    let userViewModel = UserViewModel()
    var firebase: FirebaseService = FirebaseService()
    
    // Validation to check OTP Fields
    func isValidate() -> Bool {
        if otp1.isEmpty || otp2.isEmpty || otp3.isEmpty || otp4.isEmpty || otp5.isEmpty || otp6.isEmpty {
            displayAlertWith(message: strEnterValidOtp)
            return false
        }
        return true
    }
    
    // MARK: - Fetch Current User Data After OTP Verification Done
    func fetchCurrentUser() {
        userViewModel.fetchCurrentUserData(completion: { user in
            self.objLoggedInUser = user
            Singletion.shared.objLoggedInUser = user
            
            if user.usertype == "user" {
                UIApplication.shared.currentUIWindow()?.rootViewController = UIHostingController(rootView: UserTabView())
            } else {
                UIApplication.shared.currentUIWindow()?.rootViewController = UIHostingController(rootView: AstrologerTabView())
            }
        })
    }
    
    // MARK: - Firebase Otp Verification
    func firebaseOtpVerification() {
        UIApplication.shared.dismissKeyboard()
        Singletion.shared.showDefaultProgress()
        guard let verificationID = UserDefaults.standard.object(forKey: UserDefaultKey.strVerificationID) as? String else {
            Singletion.shared.hideProgress()
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otp1 + otp2 + otp3 + otp4 + otp5 + otp6)
        
        self.firebase.verifyOTP(credential: credential) { isCompleted, error, authResult  in
            if isCompleted {
                self.isValidationPass = true
                UserDefaults.standard.set(true, forKey: UserDefaultKey.isUserLoggedIn)
                
                // store data in object
                if let result = authResult {
                    objUser.uid = result.user.uid
                    objUser.token = result.user.refreshToken ?? ""
                }
                
                if !self.isFromLogin {
                    currentUserType == .user ? self.firebase.addUserData() : self.firebase.addAstrologerData()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.fetchCurrentUser()
                }
            } else {
                self.displayAlertWith(message: error?.localizedDescription ?? "")
                self.isValidationPass = false
            }
        }
    }
    
    // MARK: - Resend Otp
    func firebaseResendOTP() {
        UIApplication.shared.dismissKeyboard()
        Singletion.shared.showDefaultProgress()
        guard let phone = UserDefaults.standard.object(forKey: UserDefaultKey.strPhoneNumber) as? String else {
            return
        }
        
        self.firebase.verifyNumberAndSendOTP(phone: phone) { isCompleted, error, id in
            if isCompleted {
                self.id = id
                self.isResendOTP = false
                self.timeRemaining = 10
                self.displayAlertWith(message: strOtpSent)
            } else {
                self.displayAlertWith(message: error?.localizedDescription ?? "")
                self.isValidationPass = false
                self.isResendOTP = true
            }
        }
    }
    
    // MARK: - Set Alert Message
    func displayAlertWith(message: String) {
        strAlertMessage = message
        showToast.toggle()
    }
}
