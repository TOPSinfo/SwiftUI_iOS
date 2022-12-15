//
//  SignupView.swift
//  Astroyodha
//
//  Created by Lazy Batman on 12/09/22.
//

import SwiftUI
import Firebase
import AlertToast

struct SignupView: View {
    @StateObject private var signUpViewModel = SignupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            Group {
                VStack(spacing: 5) {
                    backButtonViewForAuthentication(backButtonAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    Spacer()
                    createAccountTitleView
                    
                    Group {
                        firstNameView
                        Spacer(minLength: 15)
                        countryCodeMenuView
                        Spacer(minLength: 15)
                        emailView
                        agreementView
                        createAccountView
                        Spacer()
                        alreadyHaveAnAccountView
                    }
                }
                .padding(5)
                .toast(isPresenting: $signUpViewModel.showToast) {
                    AlertToast(displayMode: .banner(.pop),
                               type: .regular,
                               title: signUpViewModel.strAlertMessage)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - CREATE ANIMATED CHECK BOX
struct SetCheckBox: View {
    @Binding var trimVal: CGFloat
    @Binding var isCheckBoxTrue: Bool
    
    var animatableData: CGFloat {
        get {trimVal}
        set {trimVal = newValue }
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .trim(from: 0, to: trimVal)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .frame(width: 20, height: 20)
                .border(isCheckBoxTrue ? currentUserType.themeColor : Color.gray)
            RoundedRectangle(cornerRadius: 2)
                .trim(from: 0, to: trimVal)
                .fill(isCheckBoxTrue ?currentUserType.themeColor : Color.gray)
                .frame(width: 19, height: 19)
            if isCheckBoxTrue {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.white)
            }}
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}

// MARK: - COMPONENTS
extension SignupView {
    // MARK: - Create Account Title View
    private var createAccountTitleView: some View {
        Text(strCreateAnAccount)
            .font(.title)
            .bold()
            .font(appFont(type: .poppinsRegular, size: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all)
    }
    
    // MARK: - First Name View
    private var firstNameView: some View {
        HStack {
            Image("imgUser")
                .resizable()
                .frame(width: 15, height: 15)
                .colorMultiply(signUpViewModel.isFirstNameChange
                               ? currentUserType.themeColor : AppColor.c999999)
            
            TextField("First Name", text: $signUpViewModel.strFirstName,
                      onEditingChanged: { (editingChanged) in
                if editingChanged {
                    signUpViewModel.isFirstNameChange = true
                } else {
                    signUpViewModel.isFirstNameChange = false
                }
                
            }).font(appFont(type: .poppinsRegular, size: 18))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(signUpViewModel.isFirstNameChange
                                ? currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
        
    }
    
    // MARK: - Country Code Menu View
    private var countryCodeMenuView: some View {
        HStack {
            Menu {
                ForEach(signUpViewModel.dropDownList, id: \.self) { client in
                    Button {
                        signUpViewModel.selectedCountry = client.name
                        signUpViewModel.selectedCountryCode = client.phoneCode
                        signUpViewModel.isPhoneNumberChange = true
                    } label: {
                        phoneCodeView(phoneCode: client.phoneCode, name: client.name, flag: client.flag)
                    }
                }
            }
        label: {
            HStack {
                Image("imgMobile")
                    .resizable()
                    .frame(width: 10, height: 15)
                    .colorMultiply(signUpViewModel.isPhoneNumberChange
                                   ? currentUserType.themeColor : AppColor.c999999)
                Text(signUpViewModel.selectedCountryCode)
                    .font(appFont(type: .poppinsRegular, size: 18))
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(signUpViewModel.isPhoneNumberChange
                                     ? currentUserType.themeColor : AppColor.c999999)
                
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
        }
            phoneNumberView
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(signUpViewModel.isPhoneNumberChange
                                ? currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Phone Number View
    private var phoneNumberView: some View {
        TextField("Phone Number", text: $signUpViewModel.strPhoneNumber,
                  onEditingChanged: { (editingChanged) in
            if editingChanged {
                signUpViewModel.isPhoneNumberChange = true
            } else {
                signUpViewModel.isPhoneNumberChange = false
            }
        })
            .font(appFont(type: .poppinsRegular, size: 18))
            .frame(maxWidth: .infinity)
            .layoutPriority(1)
            .keyboardType(.phonePad)
    }
    
    // MARK: - Email View
    private var emailView: some View {
        HStack {
            Image("imgMail")
                .resizable()
                .frame(width: 15, height: 13)
                .colorMultiply(signUpViewModel.isChangeEmail
                               ? currentUserType.themeColor : AppColor.c999999)
            
            TextField("Email", text: $signUpViewModel.strEmail,
                      onEditingChanged: { (editingChanged) in
                if editingChanged {
                    signUpViewModel.isChangeEmail = true
                } else {
                    signUpViewModel.isChangeEmail = false
                }
                
            }).keyboardType(.emailAddress)
                .font(appFont(type: .poppinsRegular, size: 18))
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(signUpViewModel.isChangeEmail
                                ? currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Agreement View
    private var agreementView: some View {
        HStack {
            Button {
                if !signUpViewModel.isChecked {
                    withAnimation(Animation.easeIn(duration: 0.6)) {
                        signUpViewModel.trimVal = 1
                        signUpViewModel.isChecked.toggle()
                    }
                } else {
                    withAnimation {
                        signUpViewModel.trimVal = 0
                        signUpViewModel.isChecked.toggle()
                    }
                }
            } label: {
                SetCheckBox(trimVal: $signUpViewModel.trimVal,
                            isCheckBoxTrue: $signUpViewModel.isChecked)
            }
            Text("I agree to the [terms & conditions](https://online-testing.com/Terms) and [Privacy policy](https://online-testing.com/Privacy)")
                .tint(currentUserType.themeColor)
                .foregroundColor(AppColor.c999999)
                .padding(15)
        }
    }
    
    // MARK: - Create Account Button View
    private var createAccountView: some View {
        HStack {
            Button(action: {
                // Before processing the Signup action first check for the validation
                if signUpViewModel.isValidate() {
                    Singletion.shared.showDefaultProgress()
                    UIApplication.shared.dismissKeyboard()
                    signUpViewModel.fireBaseSendOTPCode()
                } else {
                    signUpViewModel.isUserSignUp = false
                    signUpViewModel.showToast = true
                }
            }, label: {
                commonTitleView(title: strCreateAccount)
            }).padding()
            NavigationLink(
                destination: OTPVerificationView(isFromLogin: false),
                isActive: $signUpViewModel.isUserSignUp) {EmptyView()}
        }
    }
    
    // MARK: - Already Have An Account View
    private var alreadyHaveAnAccountView: some View {
        HStack {
            Text(strAlreadyAccount)
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(.gray)
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(strLogin).foregroundColor(currentUserType.themeColor)
                    .bold()
                    .font(appFont(type: .poppinsRegular, size: 18))
            })
        }
    }
}
