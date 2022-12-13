//
//  AddEventView.swift
//  Astroyodha
//
//  Created by Tops on 17/10/22.
//

import SwiftUI
import AlertToast

enum CameraSheet: Identifiable {
    case first, second
    var id: Int {
        hashValue
    }
}

struct AddEventView: View {
    @State var uiTabarController: UITabBarController?
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = BookingAstrologerViewModel()
    var selectedAstrologer: AstrologerGridItmeVM?
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                    userNameView
                    bookingDetailSectionView
                    personDetailsView
                    paymentModeMenuView
                }
                .actionSheet(isPresented: $viewModel.actionSheet) {
                    viewModel.showActionSheet()
                }
                .sheet(isPresented: $viewModel.showImagePicker) {
                    viewModel.imagePickerView()
                }
            }
            .toast(isPresenting: $viewModel.showToast) {
                AlertToast(displayMode: .banner(.pop),
                           type: .regular,
                           title: viewModel.strAlertMessage)
            }
            Text("")
                .navigationBarItems(leading: Text("Add Event"))
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .navigationBarColor(backgroundColor: AppColor.cF06649,
                                    titleColor: .white)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancleButtonView
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        saveButtonView
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .introspectTabBarController { (UITabBarController) in
                    UITabBarController.tabBar.isHidden = true
                    uiTabarController = UITabBarController
                }
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}

// MARK: - COMPONENTS
extension AddEventView {
    // MARK: - Save Button View
    private var saveButtonView: some View {
        Button(action: {
            viewModel.addBookingData(selectedAstrologer: selectedAstrologer) { isCompleted in
                if isCompleted {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }, label: {
            Text("Save")
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        })
    }
    
    // MARK: - Cancle Button View
    var cancleButtonView: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .foregroundColor(.white)
        })
    }
    
    // MARK: - User Name View
    private var userNameView: some View {
        VStack(spacing: 5) {
            Text(strAstrologerName)
                .foregroundColor(AppColor.c999999)
                .font(appFont(type: .poppinsRegular, size: 18))
                .padding(.horizontal, 10)
            Text(selectedAstrologer!.name)
                .bold()
                .font(appFont(type: .poppinsRegular, size: 18))
                .padding(.trailing, 50)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - BOOKING DETAIL SECTION COMPONENTS
extension AddEventView {
    private var bookingDetailSectionView: some View {
        VStack(spacing: 0) {
            addDetailTextFieldView
            bookingDatePickerView
            bookingTimeAndDurationView
            bookingNotificationDurationView
        }
    }
    
    // MARK: - Add Details View
    private var addDetailTextFieldView: some View {
        HStack {
            Image(systemName: "text.alignleft").foregroundColor(.gray).padding(10)
            TextField("Add details", text: $viewModel.strDetails)
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
    
    // MARK: - Booking Date Picker
    private var bookingDatePickerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar").foregroundColor(.gray).padding(10)
            DatePicker(selection: $viewModel.datePicker,
                       in: viewModel.dateRange,
                       displayedComponents: .date) {
            }.id(viewModel.datePicker)
                .labelsHidden()
            Spacer()
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
    
    private var bookingTimeAndDurationView: some View {
        HStack {
            bookingTimePickerView
            bookingTimeDropdownView
        }
    }
    
    // MARK: - Booking Time Picker
    private var bookingTimePickerView: some View {
        HStack {
            Image(systemName: "clock").foregroundColor(.gray).padding(10)
            DatePicker(selection: $viewModel.timePicker, displayedComponents: .hourAndMinute) {
            }
            .onAppear {
                UIDatePicker.appearance().minuteInterval = 15
            }
            .id(viewModel.timePicker)
                .labelsHidden()
            Spacer()
        }
        .frame(height: 50)
    }
    
    // MARK: - Booking Time Dropdown View
    private var bookingTimeDropdownView: some View {
        HStack {
            Picker("Event Duration", selection: $viewModel.strDurationSelection) {
                ForEach(arrDuration, id: \.self) {
                    Text($0)
                }
            }
            .accentColor(AppColor.c242424)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
    }
    
    // MARK: - Booking Notification Duration
    private var bookingNotificationDurationView: some View {
        HStack {
            Image(systemName: "bell").foregroundColor(.gray).padding(10)
            Picker("No notification", selection: $viewModel.strNotificationSelection) {
                ForEach(arrNotification, id: \.self) {
                    Text($0)
                }
            }
            .accentColor(AppColor.c242424)
            Spacer()
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
}

// MARK: - PERSON DETAIL COMPONENTS
extension AddEventView {
    private var personDetailsView: some View {
        VStack(spacing: 0) {
            personDetailTitleView
            uploadPhotoView
            fullNameView
            personBirthDateAndBirthTimeView
            personBirthPlaceView
            uploadKundaliView
            paymentModeDetailTitleView
        }
    }
    
    // MARK: - Person Detail Title View
    private var personDetailTitleView: some View {
        HStack {
            Text("Person Details")
                .bold()
                .font(appFont(type: .poppinsRegular, size: 18))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accentColor(Color.black)
        .background(AppColor.cFAFAFA)
    }
    
    // MARK: - Upload Photo View
    private var uploadPhotoView: some View {
        HStack {
            Image(uiImage: viewModel.pickedImage)
                .resizable()
                .frame(width: 15, height: 15)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.gray).padding(10)
            Button {
                viewModel.changePhotoSelection(isKundaliPhoto: false)
            } label: {
                Text("Upload your photo")
            }
            .foregroundColor(AppColor.cF06649)
            Spacer()
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
    
    // MARK: - Full Name View
    private var fullNameView: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.gray)
                .padding(10)
            TextField("Full Name", text: $viewModel.strFullName)
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
    
    // MARK: - Birth Date and Time View
    private var personBirthDateAndBirthTimeView: some View {
        HStack(spacing: 10) {
            personBirthDateView
            personBirthTimeView
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
    
    // MARK: - Person BirthDate View
    private var personBirthDateView: some View {
        HStack {
            Image(systemName: "gift").foregroundColor(.gray).padding(10)
            DatePicker(selection: $viewModel.datePickerBirthDate,
                       in: ...Date(),
                       displayedComponents: .date) {
            }
            .id(viewModel.datePickerBirthDate)
                .labelsHidden()
            Spacer()
        }
    }
    
    // MARK: - Person BirthTime View
    private var personBirthTimeView: some View {
        HStack {
            Image(systemName: "clock").foregroundColor(.gray).padding(10)
            DatePicker(selection: $viewModel.timePickerBirth, displayedComponents: .hourAndMinute) {
            }.id(viewModel.timePickerBirth)
                .labelsHidden()
            Spacer()
        }
    }
    
    // MARK: - Person BirthPlace View
    private var personBirthPlaceView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse").foregroundColor(.gray).padding(10)
            TextField("Place Of Birth", text: $viewModel.strPlaceOfBirth)
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
    
    // MARK: - Upload Kundali View
    private var uploadKundaliView: some View {
        HStack {
            Image(uiImage: viewModel.pickedImageKundali)
                .resizable()
                .frame(width: 15, height: 15)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.gray).padding(10)
            Button {
                viewModel.changePhotoSelection(isKundaliPhoto: true)
            } label: {
                Text("Upload Kundali")
            }
            .foregroundColor(AppColor.cF06649)
            Spacer()
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
}

// MARK: - PAYMENT MODE COMPONENTS
extension AddEventView {
    // MARK: - Payment Mode Title View
    private var paymentModeDetailTitleView: some View {
        HStack {
            Text("Payment Mode Details")
                .bold()
                .font(appFont(type: .poppinsRegular, size: 18))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accentColor(Color.black)
        .background(AppColor.cFAFAFA)
    }
    
    // MARK: - Payment Mode Menu View
    private var paymentModeMenuView: some View {
        HStack {
            Image("tabWallet").foregroundColor(.gray).padding(10)
            Picker("Select payment mode", selection: $viewModel.strPaymentModeSelection) {
                ForEach(arrPaymentOption, id: \.self) {
                    Text($0)
                }
            }
            .accentColor(AppColor.c242424)
            Spacer()
            Text("\u{20B9}\(viewModel.getPaymentAmount(selectedAstrologer: selectedAstrologer))")
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(currentUserType.themeColor)
                .padding(.trailing)
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 1)
                        .stroke(AppColor.cDCDCDC,
                                lineWidth: 1))
    }
}
