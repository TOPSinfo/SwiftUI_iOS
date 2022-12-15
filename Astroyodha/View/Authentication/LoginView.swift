//
//  LoginView.swift
//  Astroyodha
//
//  Created by Tops on 02/12/22.
//

import SwiftUI
import Firebase
import AlertToast

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            backButtonViewForAuthentication(backButtonAction: {
                self.presentationMode.wrappedValue.dismiss()
            })
            
            VStack(alignment: .center, spacing: 5) {
                headerContentView
                countryCodeMenuView
                Spacer(minLength: 15)
                loginButtonView
                signUpButtonView
            }
            .padding()
            .toast(isPresenting: $loginViewModel.showToast) {
                AlertToast(displayMode: .banner(.pop),
                           type: .regular,
                           title: loginViewModel.strAlertMessage)
            }
        }
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

// MARK: - COMPONENTS
extension LoginView {
    // MARK: - Header Text content View
    private var headerContentView: some View {
        VStack {
            Image("imgLoginPhone")
                .resizable()
                .frame(width: 130, height: 130)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 6.6))
            
            Text(strLogin)
                .font(appFont(type: .poppinsRegular, size: 25))
                .bold()
                .padding()
            
            Text(strEnterMobileNumberToCreateAccountText)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 350, height: 50, alignment: .center)
                .padding(.bottom, 10)
        }
    }
    
    // MARK: - Country Code Menu View
    private var countryCodeMenuView: some View {
        HStack {
            Menu {
                ForEach(loginViewModel.dropDownList, id: \.self) { client in
                    Button {
                        loginViewModel.selectedCountry = client.name
                        loginViewModel.selectedCountryCode = client.phoneCode
                        loginViewModel.isTextFieldChange = true
                    } label: {
                        phoneCodeView(phoneCode: client.phoneCode, name: client.name, flag: client.flag)
                    }
                }
            }
        label: {
            HStack {
                Image("imgMobile")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(currentUserType.themeColor)
                    .frame(width: 10, height: 15)
                    .colorMultiply(loginViewModel.isTextFieldChange ? currentUserType.themeColor : AppColor.c999999)
                Text(loginViewModel.selectedCountryCode)
                    .font(appFont(type: .poppinsRegular, size: 18))
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(loginViewModel.isTextFieldChange ? currentUserType.themeColor : AppColor.c999999)
                
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(currentUserType.themeColor)
            }
        }
            phoneNumberView
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(loginViewModel.isTextFieldChange ?  currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(5)
    }
    
    // MARK: - Phone Number View
    private var phoneNumberView: some View {
        TextField("Phone Number", text: $loginViewModel.strPhoneNumber, onEditingChanged: { (editingChanged) in
            if editingChanged {
                loginViewModel.isTextFieldChange = true
            } else {
                loginViewModel.isTextFieldChange = false
            }
        }).font(appFont(type: .poppinsRegular, size: 18))
            .foregroundColor(currentUserType.themeColor)
            .frame(maxWidth: .infinity)
            .layoutPriority(1)
            .keyboardType(.phonePad)
    }
    
    // MARK: - Login Button View
    private var loginButtonView: some View {
        VStack(spacing: 0) {
            Button(action: {
                // Before processing the login action first check phone number validation
                if loginViewModel.isValidate() {
                    Singletion.shared.showDefaultProgress()
                    UIApplication.shared.dismissKeyboard()
                    loginViewModel.fireBaseSendOTPCode()
                }
            }, label: {
                commonTitleView(title: strLogin)
            })
                .padding(5)
            
            Spacer()
            
            NavigationLink(
                destination: OTPVerificationView(isFromLogin: true),
                isActive: self.$loginViewModel.isUserLoggedIn) {EmptyView()}
        }
    }
    
    // Sign Up
    private var signUpButtonView: some View {
        HStack {
            Text(strNotRegisteredYet)
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(.gray)
            NavigationLink(destination: SignupView()) {
                Text(strSignUpText).foregroundColor(currentUserType.themeColor)
                    .bold()
                    .font(appFont(type: .poppinsRegular, size: 18))
            }
        }
    }
}
