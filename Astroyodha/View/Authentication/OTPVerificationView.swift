//
//  OTPVerificationView.swift
//  Astroyodha
//
//  Created by Lazy Batman on 12/09/22.
//

import SwiftUI
import Firebase
import AlertToast

struct OTPVerificationView: View {
    @StateObject private var otpViewModel = OTPVerificationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State var isFromLogin = false
    
    var textFieldOriginalWidth: CGFloat {
        (textBoxWidth*6)+(spaceBetweenBoxes*3)+((paddingOfBox*2)*3)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 5) {
                backButtonViewForAuthentication(backButtonAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
                headerView
                oTPTextField
                verifyAndResentOTPView
                Spacer()
                if !otpViewModel.isResendOTP {
                    timerLabelView
                }
            }
            .toast(isPresenting: $otpViewModel.showToast) {
                AlertToast(displayMode: .banner(.pop),
                           type: .regular,
                           title: otpViewModel.strAlertMessage)
            }
        }
        .onAppear(perform: {
            otpViewModel.isFromLogin = isFromLogin
        })
        .navigationBarHidden(true)
    }
}

struct OTPVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationView()
    }
}

// MARK: - COMPONENTS
extension OTPVerificationView {
    // MARK: - Header Content View
    private var headerView: some View {
        VStack {
            Image("imgLoginPhone")
                .resizable()
                .frame(width: 130, height: 130)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 6.6))
            
            Text(strOtpVerification)
                .font(appFont(type: .poppinsRegular, size: 25))
                .bold()
                .padding()
            
            Text(strEnterOTP + objUser.phone)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 350, height: 50, alignment: .center)
                .padding(.bottom, 10)
        }
    }
    
    // MARK: - OTP Field View
    private var oTPTextField: some View {
        VStack {
            ZStack {
                HStack(spacing: spaceBetweenBoxes) {
                    otpText(text: otpViewModel.otp1)
                    otpText(text: otpViewModel.otp2)
                    otpText(text: otpViewModel.otp3)
                    otpText(text: otpViewModel.otp4)
                    otpText(text: otpViewModel.otp5)
                    otpText(text: otpViewModel.otp6)
                }
                TextField("", text: $otpViewModel.otpField)
                    .frame(width: otpViewModel.isFocused ? 0 : textFieldOriginalWidth, height: textBoxHeight)
                    .disabled(otpViewModel.isTextFieldDisabled)
                    .textContentType(.oneTimeCode)
                    .foregroundColor(.clear)
                    .accentColor(.clear)
                    .background(Color.clear)
                    .keyboardType(.numberPad)
            }
        }
    }
    
    // MARK: - OTP Text
    private func otpText(text: String) -> some View {
        return Text(text)
            .font(.title)
            .frame(width: textBoxWidth, height: textBoxHeight)
            .background(
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 1)
                        .frame(height: 0.5)
                })
            .padding(paddingOfBox)
    }
    
    // MARK: - Verify/Resend Buttton View
    private var verifyAndResentOTPView: some View {
        VStack {
            HStack {
                Button(action: {
                    if otpViewModel.isValidate() {
                        otpViewModel.firebaseOtpVerification()
                    }
                }, label: {
                    commonTitleView(title: strVerify)
                }).padding()
            }
            
            if otpViewModel.isResendOTP {
                Button(action: {
                    otpViewModel.firebaseResendOTP()
                }, label: {
                    commonTitleView(title: strResendOTP)
                }).padding()
            }
        }
    }
    
    // MARK: - Timer Label View
    private var timerLabelView: some View {
        Text("Resend OTP available in \(otpViewModel.timeRemaining)")
            .foregroundColor(AppColor.c80C181)
            .bold()
            .font(appFont(type: .poppinsRegular, size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all)
            .onReceive(timer) { _ in
                if otpViewModel.timeRemaining > 0 {
                    otpViewModel.timeRemaining -= 1
                } else {
                    otpViewModel.isResendOTP = true
                }
            }
    }
}
