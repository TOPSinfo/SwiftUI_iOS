//
//  UserEditProfileView.swift
//  Astroyodha
//
//  Created by Tops on 03/11/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Introspect
import AlertToast

enum ActionSheetOption {
    case camera
    case gallery
}

struct EditProfileView: View {
    @State var uiTabarController: UITabBarController?
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        UIDatePicker.appearance().backgroundColor = UIColor.init(.white) // changes bg color
        UIDatePicker.appearance().tintColor = currentUserType.themeUIColor // changes font color
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                Group {
                    VStack(spacing: 5) {
                        profilePhotoView
                        
                        if currentUserType == .user {
                            VStack(spacing: 20) {
                                fullNameTextFieldView
                                mobileNumberTextFieldView
                                emailTextFieldView
                                dateOfBirthTextView
                                timeOfBirthTextView
                                birthPlaceTextView
                                userEditProfileSubmitView
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Basic Details")
                                        .font(appFont(type: .poppinsMedium, size: 20))
                                        .foregroundColor(AppColor.c242424)
                                        .padding(.horizontal)
                                    
                                    fullNameTextFieldView
                                    mobileNumberTextFieldView
                                    emailTextFieldView
                                    dateOfBirthTextView
                                }
                                
                                Text("Other Details")
                                    .font(appFont(type: .poppinsMedium, size: 20))
                                    .foregroundColor(AppColor.c242424)
                                    .padding(.horizontal)
                                    .padding(.vertical, 25)
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    languageTextView
                                    astrologyTextView
                                    priceTextFieldView
                                    experienceTextFieldView
                                    aboutYouTextView
                                }
                                
                                VStack {
                                    appointmentTitleView
                                    if viewModel.arrAppointments.isEmpty {
                                        noAppointmentSlotView
                                    } else {
                                        appointmentSlotListView
                                    }
                                    atrologerEditProfileSubmitView
                                }
                            }
                        }
                    }
                    .padding(5)
                    .toast(isPresenting: $viewModel.showToast) {
                        AlertToast(displayMode: .banner(.pop),
                                   type: .regular,
                                   title: viewModel.strAlertMessage)
                    }
                }
            }
            
            Text("")
                .navigationBarItems(leading: Text("Profile"))
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .navigationBarColor(backgroundColor: currentUserType.themeColor,
                                    titleColor: .white)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        backButtonView
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            
            if viewModel.isLanguageVisible {
                languagePopupView
            }
            
            if viewModel.isAstrologyVisible {
                astrologyPopupView
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.setUserData()
            viewModel.getTimeslotList()
        }
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
        }
    }
}

struct UserEditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}

// MARK: - COMPONENTS
extension EditProfileView {
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
    
    // MARK: - Profile Photo view
    private var profilePhotoView: some View {
        VStack {
            if viewModel.isImageChanged {
                Image(uiImage: viewModel.pickedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .cornerRadius(60)
                    .overlay(alignment: .bottomTrailing) {
                        editProfilePhotoView
                    }
                    .padding(.bottom, 5)
            } else {
                WebImage(url: URL(string: Singletion.shared.objLoggedInUser.profileimage))
                    .resizable()
                    .placeholder {
                        Image(uiImage: viewModel.pickedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .cornerRadius(60)
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .cornerRadius(60)
                    .overlay(alignment: .bottomTrailing) {
                        editProfilePhotoView
                    }
                    .padding(.bottom, 5)
            }
            
            Text(viewModel.objLoggedInUser?.fullname ?? "-")
                .font(appFont(type: .poppinsBold, size: 20))
                .bold()
            
            if currentUserType == .user {
                Text((viewModel.objLoggedInUser?.birthplace ?? "").isEmpty
                     ? "-"
                     : (viewModel.objLoggedInUser?.birthplace ?? "-"))
                    .font(appFont(type: .poppinsRegular, size: 16))
                    .foregroundColor(AppColor.c999999)
            }
        }
        .padding(.vertical, 30)
        .actionSheet(isPresented: $viewModel.actionSheet) {
            viewModel.showActionSheet()
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            viewModel.imagePickerview()
        }
    }
    
    // MARK: - Edit Profile Icon View
    private var editProfilePhotoView: some View {
        Button {
            viewModel.actionSheet.toggle()
        } label: {
            Image(currentUserType == .astrologer ? "imgEditAstrologer" : "imgEditUser")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(6)
        }
    }
    
    // MARK: - Full name View
    private var fullNameTextFieldView: some View {
        HStack {
            Image("imgFullname")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(viewModel.isFullNameChange ? currentUserType.themeColor : AppColor.c999999)
                .padding(.trailing, 5)
            
            TextField("Full Name", text: $viewModel.strFullName, onEditingChanged: { (editingChanged) in
                viewModel.isFullNameChanging(editingChanged: editingChanged)
            })
                .font(appFont(type: .poppinsRegular, size: 17))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isFullNameChange ? currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Mobile Number View
    private var mobileNumberTextFieldView: some View {
        HStack {
            Image("imgMobileNumber")
                .resizable()
                .scaledToFit()
                .frame(width: 14)
                .colorMultiply(AppColor.c999999)
                .padding(.trailing, 10)
            
            TextField("Mobile Number", text: $viewModel.strPhoneNumber)
                .allowsHitTesting(false)
                .font(appFont(type: .poppinsRegular, size: 17))
                .frame(maxWidth: .infinity)
                .layoutPriority(1)
                .keyboardType(.phonePad)
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Email Address View
    private var emailTextFieldView: some View {
        HStack {
            Image("imgEmailAddress")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(viewModel.isEmailChange ? currentUserType.themeColor : AppColor.c999999)
                .padding(.trailing, 10)
            
            TextField("Email Address", text: $viewModel.strEmail, onEditingChanged: { (editingChanged) in
                if editingChanged {
                    viewModel.isEmailChange = true
                } else {
                    viewModel.isEmailChange = false
                }
            })
                .font(appFont(type: .poppinsRegular, size: 17))
                .keyboardType(.emailAddress)
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isEmailChange ? currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Date of Birth View
    private var dateOfBirthTextView: some View {
        HStack {
            Image("imgDOB")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(AppColor.c999999)
                .padding(.trailing, 10)
            
            VStack {
                DatePicker("", selection: $viewModel.datePickerBirthDate,
                           in: ...Date(),
                           displayedComponents: .date)
                    .labelsHidden()
                    .clipped()
                    .id(viewModel.datePickerBirthDate)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Time of Birth view
    private var timeOfBirthTextView: some View {
        HStack {
            Image("imgBirthTime")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(AppColor.c999999)
                .padding(.trailing, 10)
            
            VStack {
                DatePicker("", selection: $viewModel.datePickerTime,
                           in: ...Date(),
                           displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .clipped()
                    .id(viewModel.datePickerTime)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Place of Birth view
    private var birthPlaceTextView: some View {
        HStack {
            Image("imgBirthPlace")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(viewModel.isBirthPlaceChange ? currentUserType.themeColor : AppColor.c999999)
                .padding(.trailing, 5)
            
            TextField("Place of Birth", text: $viewModel.strBirthPlace, onEditingChanged: { (editingChanged) in
                if editingChanged {
                    viewModel.isBirthPlaceChange = true
                } else {
                    viewModel.isBirthPlaceChange = false
                }})
                .font(appFont(type: .poppinsRegular, size: 17))
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isBirthPlaceChange ? currentUserType.themeColor : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    // MARK: - User Submit Button View
    private var userEditProfileSubmitView: some View {
        Button(action: {
            let strBirthDate = convert(date: viewModel.datePickerBirthDate,
                                           fromFormat: datePickerSelectedFormat,
                                           toFormat: datePickerDateFormatWithoutDash)
            let strBirthTime = convert(date: viewModel.datePickerTime,
                                           fromFormat: datePickerSelectedFormat,
                                           toFormat: datePickertimeFormat)
            
            if viewModel.isUserValidate() {
                UIApplication.shared.dismissKeyboard()
                var dictUser: [String: Any] = [:]
                
                dictUser["fullname"] = viewModel.strFullName
                dictUser["phone"] = viewModel.strPhoneNumber
                dictUser["email"] = viewModel.strEmail.lowercased()
                dictUser["birthdate"] = strBirthDate
                dictUser["birthtime"] = strBirthTime
                dictUser["birthplace"] = viewModel.strBirthPlace
                dictUser["lastupdatetime"] = Date(timeIntervalSince1970: Double(timestamp) / 1000)
                dictUser["imagepath"] =  Singletion.shared.objLoggedInUser.imagepath
                dictUser["profileimage"] = Singletion.shared.objLoggedInUser.profileimage
                
                Singletion.shared.showDefaultProgress()
                
                if viewModel.isImageChanged {
                    viewModel.uploadProfileImage(dictUser: dictUser) { isCompleted in
                        if isCompleted {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    viewModel.updateUserData(dictUser: dictUser) { isCompleted in
                        if isCompleted {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }, label: {
            Text("Submit")
                .font(appFont(type: .poppinsRegular, size: 18))
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 8)
                                .fill(currentUserType.themeColor))
        })
            .padding(.horizontal, 15)
    }
    
    // MARK: - Language View
    private var languageTextView: some View {
        HStack {
            Image("imgLanguage")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(AppColor.c999999)
                .padding(.trailing, 10)
            
            ZStack(alignment: .topLeading) {
                Button {
                    viewModel.isLanguageVisible = true
                } label: {
                    Text(viewModel.strLanguage)
                        .multilineTextAlignment(.leading)
                        .font(appFont(type: .poppinsRegular, size: 17))
                        .foregroundColor((viewModel.strLanguage == "Language") ? AppColor.c3C3C43 : AppColor.c242424)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Astrology View
    private var astrologyTextView: some View {
        HStack {
            Image("imgAstrologyType")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .colorMultiply(AppColor.c999999)
                .padding(.trailing, 10)
            
            ZStack(alignment: .topLeading) {
                Button {
                    viewModel.isAstrologyVisible = true
                } label: {
                    Text(viewModel.strAstrology)
                        .multilineTextAlignment(.leading)
                        .font(appFont(type: .poppinsRegular, size: 17))
                        .foregroundColor((viewModel.strAstrology == "Astrology Type")
                                         ? AppColor.c3C3C43
                                         : AppColor.c242424)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 50)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Price View
    private var priceTextFieldView: some View {
        HStack {
            Image("imgPrice")
                .resizable()
                .scaledToFit()
                .frame(width: 12)
                .colorMultiply(viewModel.isPriceChange
                               ? currentUserType.themeColor
                               : AppColor.c999999)
                .padding(.trailing, 5)
            
            TextField("Price per 15 min", text: $viewModel.strPrice,
                      onEditingChanged: { (editingChanged) in
                if editingChanged {
                    viewModel.isPriceChange = true
                } else {
                    viewModel.isPriceChange = false
                }})
                .font(appFont(type: .poppinsRegular, size: 17))
                .keyboardType(.numberPad)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isPriceChange
                                ? currentUserType.themeColor
                                : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Experience View
    private var experienceTextFieldView: some View {
        HStack {
            Image("imgExperience")
                .resizable()
                .scaledToFit()
                .frame(width: 12)
                .colorMultiply(viewModel.isExperienceChange
                               ? currentUserType.themeColor
                               : AppColor.c999999)
                .padding(.trailing, 5)
            
            TextField("Experience", text: $viewModel.strExperience,
                      onEditingChanged: { (editingChanged) in
                if editingChanged {
                    viewModel.isExperienceChange = true
                } else {
                    viewModel.isExperienceChange = false
                }})
                .font(appFont(type: .poppinsRegular, size: 17))
                .keyboardType(.numberPad)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isExperienceChange
                                ? currentUserType.themeColor
                                : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - About You View
    private var aboutYouTextView: some View {
        HStack(alignment: .top) {
            Image("imgAboutYou")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .colorMultiply(viewModel.isAboutChange
                               ? currentUserType.themeColor
                               : AppColor.c999999)
                .padding(.top, 15)
            
            TextView(
                text: $viewModel.strAbout,
                isEditing: $viewModel.isAboutChange,
                placeholder: "About You",
                textVerticalPadding: 0,
                placeholderHorizontalPadding: 3.0,
                placeholderVerticalPadding: 0,
                font: UIFont.init(name: AppFont.poppinsRegular.rawValue,
                                  size: 17)!
            )
                .padding(.vertical, 2)
                .padding(.vertical, 10)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isAboutChange
                                ? currentUserType.themeColor
                                : AppColor.cDCDCDC,
                                lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - Language Popup View
    private var languagePopupView: some View {
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                ForEach(0..<viewModel.arrLanguages.count) { index in
                    let objLanguage = viewModel.arrLanguages[index]
                    
                    HStack {
                        Image(objLanguage.isSelected ? "imgRadioSelected": "imgRadioUnselected")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 5)
                        
                        Text(objLanguage.name)
                            .font(appFont(type: .poppinsRegular, size: 16))
                            .foregroundColor(AppColor.c242424)
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.arrLanguages[index].isSelected.toggle()
                    }
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 12) {
                    Button {
                        viewModel.isLanguageVisible.toggle()
                    } label: {
                        Text("Cancel")
                            .font(appFont(type: .poppinsSemiBold, size: 17))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                    }
                    .background(AppColor.cE1F3FF)
                    .cornerRadius(8)
                    
                    Button {
                        let arrUpdateNames = viewModel.arrLanguages.filter({ return $0.isSelected == true })
                        let arrName = arrUpdateNames.map({ (language: LanguageObject) -> String in
                            language.name
                        })
                        
                        viewModel.strLanguage = arrName.map { String($0) }.joined(separator: ", ")
                        print(viewModel.strLanguage)
                        viewModel.isLanguageVisible.toggle()
                    } label: {
                        Text("Submit")
                            .font(appFont(type: .poppinsSemiBold, size: 17))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                    }
                    .background(AppColor.c27AAE1)
                    .cornerRadius(8)
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
            }
            .padding(.top)
            .background(.white)
            .cornerRadius(10)
            .padding()
        }
        .onTapGesture {
            viewModel.isLanguageVisible.toggle()
        }
    }
    
    // MARK: - Astrology Popup View
    private var astrologyPopupView: some View {
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                ForEach(0..<viewModel.arrAstrology.count) { index in
                    let objAstrology = viewModel.arrAstrology[index]
                    
                    HStack {
                        Image(objAstrology.isSelected ? "imgRadioSelected": "imgRadioUnselected")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 5)
                        
                        Text(objAstrology.name)
                            .font(appFont(type: .poppinsRegular, size: 16))
                            .foregroundColor(AppColor.c242424)
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.arrAstrology[index].isSelected.toggle()
                    }
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 12) {
                    Button {
                        viewModel.isAstrologyVisible.toggle()
                    } label: {
                        Text("Cancel")
                            .font(appFont(type: .poppinsSemiBold, size: 17))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                    }
                    .background(AppColor.cE1F3FF)
                    .cornerRadius(8)
                    
                    Button {
                        let arrUpdateNames = viewModel.arrAstrology.filter({ return $0.isSelected == true })
                        let arrName = arrUpdateNames.map({ (astrology: AstrologyObject) -> String in
                            astrology.name
                        })
                        
                        viewModel.strAstrology = arrName.map { String($0) }.joined(separator: ", ")
                        print(viewModel.strAstrology)
                        viewModel.isAstrologyVisible.toggle()
                    } label: {
                        Text("Submit")
                            .font(appFont(type: .poppinsSemiBold, size: 17))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                    }
                    .background(AppColor.c27AAE1)
                    .cornerRadius(8)
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
            }
            .padding(.top)
            .background(.white)
            .cornerRadius(10)
            .padding()
        }
        .navigationBarHidden(true)
        .onTapGesture {
            viewModel.isAstrologyVisible.toggle()
        }
    }
    
    // MARK: - Astrologer Submit View
    private var atrologerEditProfileSubmitView: some View {
        Button(action: {
            let strBirthDate = convert(date: viewModel.datePickerBirthDate,
                                       fromFormat: datePickerSelectedFormat,
                                       toFormat: datePickerDateFormatWithoutDash)
            
            if viewModel.isAstrologerValidate() {
                UIApplication.shared.dismissKeyboard()
                
                var dictAstrologer: [String: Any] = [:]
                
                let arrSelectedLanguageNames = viewModel.arrLanguages.filter({ return $0.isSelected == true })
                let arrSelectedLanguagesIDs = arrSelectedLanguageNames.map({ (language: LanguageObject) -> String in
                    language.id
                })
                
                let arrSelectedAstrologyNames = viewModel.arrAstrology.filter({ return $0.isSelected == true })
                let arrSelectedAstrologyIDs = arrSelectedAstrologyNames.map({ (astrology: AstrologyObject) -> String in
                    astrology.id
                })
                
                dictAstrologer["fullname"] = viewModel.strFullName
                dictAstrologer["phone"] = viewModel.strPhoneNumber
                dictAstrologer["email"] = viewModel.strEmail.lowercased()
                dictAstrologer["birthdate"] = strBirthDate
                dictAstrologer["languages"] = arrSelectedLanguagesIDs
                dictAstrologer["speciality"] = arrSelectedAstrologyIDs
                dictAstrologer["price"] = viewModel.strPrice.isEmpty ? 0 : Int(viewModel.strPrice)
                dictAstrologer["experience"] = viewModel.strExperience.isEmpty ? 0 : Int(viewModel.strExperience)
                dictAstrologer["aboutyou"] = viewModel.strAbout
                dictAstrologer["lastupdatetime"] = Date(timeIntervalSince1970: Double(timestamp) / 1000)
                dictAstrologer["imagepath"] =  Singletion.shared.objLoggedInUser.imagepath
                dictAstrologer["profileimage"] = Singletion.shared.objLoggedInUser.profileimage
                Singletion.shared.showDefaultProgress()
                
                if viewModel.isImageChanged {
                    viewModel.uploadProfileImage(dictUser: dictAstrologer) { isCompleted in
                        if isCompleted {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    viewModel.updateAstrologerData(dictAstrologer: dictAstrologer) { isCompleted in
                        if isCompleted {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }, label: {
            Text("Save")
                .font(appFont(type: .poppinsRegular, size: 18))
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 8)
                                .fill(currentUserType.themeColor))
        })
            .padding(.horizontal, 15)
            .padding(.top, 30)
    }
    
    // MARK: - Appointment Title View
    private var appointmentTitleView: some View {
        HStack {
            Text("Appointment Slot")
                .font(appFont(type: .poppinsMedium, size: 20))
                .foregroundColor(AppColor.c242424)
                .padding(.horizontal)
                .padding(.vertical, 25)
            
            Spacer()
            
            Button {
                viewModel.isAppointmentTapped.toggle()
            } label: {
                Image("imgAdd")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .padding(.horizontal)
            }
            NavigationLink(
                destination: TimeSlotView(),
                isActive: $viewModel.isAppointmentTapped) { EmptyView()}
        }
    }
    
    // MARK: - No TimeSlot View
    private var noAppointmentSlotView: some View {
        Text("Time slot not added.")
            .font(appFont(type: .poppinsMedium, size: 18))
            .foregroundColor(AppColor.c999999)
    }
    
    // MARK: - Appointment Slot List View
    private var appointmentSlotListView: some View {
        ForEach(viewModel.arrAppointments.indices, id: \.self) { index in
            let objAppointment: AppointmentTimeSlotModel = viewModel.arrAppointments[index]
            
            ZStack {
                Rectangle()
                    .fill(AppColor.cFAFAFA)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    .padding(.vertical, 2)
                
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .center, spacing: 2) {
                        Text(objAppointment.startTime)
                        Text("To")
                        Text(objAppointment.endTime)
                    }
                    .font(appFont(type: .poppinsRegular, size: 15))
                    .foregroundColor(AppColor.c999999)
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Appointment Slot \(index + 1)")
                            .font(appFont(type: .poppinsMedium, size: 17))
                            .foregroundColor(AppColor.c999999)
                        Text(objAppointment.repeatDays.isEmpty
                             ? Singletion.shared.convertDateStringInSpecificFormat(startDate: objAppointment.startDate,
                                                                                   endDate: objAppointment.endDate) : (objAppointment.repeatDays.map { String($0) }.joined(separator: ", ")))
                            .font(appFont(type: .poppinsRegular, size: 15))
                            .foregroundColor(AppColor.c999999)
                    }
                    .padding(.vertical)
                    
                    Spacer()
                    
                    Button {
                        // DELETE PARTICULAR TIMESLOT
                        viewModel.deleteTimeSlotData(objAppointment: objAppointment)
                    } label: {
                        Image("imgDelete")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22)
                    }
                    .padding()
                }
            }
        }
        .padding(.horizontal)
    }
}
