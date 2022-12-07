//
//  TimeSlotView.swift
//  Astroyodha
//
//  Created by Tops on 11/11/22.
//

import SwiftUI
import Firebase
import AlertToast

enum TimeSlot: String {
    case repeatOption = "Repeat"
    case weeklyOption = "Weekly"
    case customOption = "Custom"
}

struct TimeSlotView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = TimeSlotViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                repeatDropdownPopupView
                Divider()
                startEndDateView
                Divider()
                startEndTimeView
                Spacer()
            }
            .toast(isPresenting: $viewModel.showToast) {
                AlertToast(displayMode: .banner(.pop), type: .regular, title: viewModel.strAlertMessage)
            }
            
            Text("")
                .navigationBarItems(leading: Text("Time Slot"))
                .font(appFont(type: .poppinsRegular, size: 17))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .navigationBarColor(backgroundColor: currentUserType.themeColor, titleColor: .white)
            
                .toolbar {
                    //1 navigation cancel button
                    ToolbarItem(placement: .navigationBarLeading) {
                        backButtonView
                    }
                    //2 navigation save button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        saveButtonView
                    }
                }.navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            
            if (viewModel.isRepeatPopupShow) {
                repeatPopupView
            }
        }
    }
}

struct TimeSlotView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSlotView()
    }
}

//MARK: - COMPONENTS
extension TimeSlotView {
    //MARK: - Back Button View
    private var backButtonView: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "arrow.left")
                .renderingMode(.template)
                .foregroundColor(.white)
        })
    }
    
    //MARK: - Save Button View
    private var saveButtonView: some View {
        Button(action: {
            viewModel.isValideTimeSlot { isCompleted in
                if (isCompleted) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }, label: {
            Text("Save")
                .font(appFont(type: .poppinsRegular, size: 17))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        })
    }
    
    //MARK: - Repeat Options Popup View
    private var repeatPopupView: some View {
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
            VStack (alignment: .leading) {
                ForEach(0..<viewModel.arrRepeat.count, id: \.self) { index in
                    let objRepeat = viewModel.arrRepeat[index]
                    
                    HStack {
                        Image(objRepeat.isSelected ? "imgRadioSelected": "imgRadioUnselected")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.horizontal)
                        
                        Text(objRepeat.name)
                            .font(appFont(type: .poppinsRegular, size: 16))
                            .foregroundColor(AppColor.c242424)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(width: UIScreen.main.bounds.width - 60)
                    
                    .onTapGesture {
                        viewModel.changeTimeSlotRepeatSelection(index: index)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.vertical)
            .background(.white)
            .cornerRadius(10)
            .padding()
        }
        .onTapGesture {
            viewModel.isRepeatPopupShow.toggle()
        }
    }
    
    //MARK: - Start Date View
    private var startDateView: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(viewModel.strStartDateTitle)
                .font(appFont(type: .poppinsMedium, size: 17))
                .foregroundColor(AppColor.c999999)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack (alignment: .leading) {
                DatePicker("", selection: $viewModel.datePickerStartDate, in: Date()..., displayedComponents: .date)
                    .labelsHidden()
                    .clipped()
                    .id(viewModel.datePickerStartDate)
            }
        }
    }
    //MARK: - End Date View
    private var endDateView: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(viewModel.strEndDateTitle)
                .font(appFont(type: .poppinsMedium, size: 17))
                .foregroundColor(AppColor.c999999)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                DatePicker("", selection: $viewModel.datePickerEndDate, in: Date()..., displayedComponents: .date)
                    .labelsHidden()
                    .clipped()
                    .id(viewModel.datePickerEndDate)
            }
        }
    }
    
    //MARK: - Start Time View
    private var startTimeView: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(viewModel.strStartTimeTitle)
                .font(appFont(type: .poppinsMedium, size: 17))
                .foregroundColor(AppColor.c999999)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                DatePicker("", selection: $viewModel.timePickerStartTime, in: Date()..., displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .clipped()
                    .id(viewModel.timePickerStartTime)
            }
        }
    }
    
    //MARK: - End Time View
    private var endTimeView: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(viewModel.strEndTimeTitle)
                .font(appFont(type: .poppinsMedium, size: 17))
                .foregroundColor(AppColor.c999999)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                DatePicker("", selection: $viewModel.timePickerEndTime, in: Date()..., displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .clipped()
                    .id(viewModel.timePickerEndTime)
            }
        }
    }
    
    //MARK: - Week Days View
    private var weekDaysView: some View {
        HStack {
            ForEach(0..<viewModel.arrDays.count, id: \.self) { index in
                let objDay = viewModel.arrDays[index]
                
                Button {
                    viewModel.arrDays[index].isSelected.toggle()
                    viewModel.objectWillChange.send()
                } label: {
                    Text(objDay.name.stringAt(0))
                        .font(appFont(type: .poppinsRegular, size: 19))
                        .foregroundColor(objDay.isSelected ? .white : AppColor.c999999)
                        .frame(width: UIScreen.main.bounds.width / 8.5, height: UIScreen.main.bounds.width / 8.5)
                        .background(objDay.isSelected ? currentUserType.themeColor : .white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 70)
    }
    
    //MARK: -  Repeat Dropdown Popup View
    private var repeatDropdownPopupView: some View {
        Button {
            viewModel.isRepeatPopupShow.toggle()
        } label: {
            HStack {
                Image("imgCalendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26)
                    .padding(.horizontal, 5)
                
                Text(viewModel.currentTimeSlot.rawValue)
                    .font(appFont(type: .poppinsMedium, size: 17))
                    .foregroundColor(AppColor.c999999)
                
                Spacer()
                
                Image("imgExpand")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundColor(AppColor.c999999)
                    .padding(.horizontal, 5)
            }
            .padding()
        }
    }
    
    //MARK: - Start/End Date View
    private var startEndDateView: some View {
        HStack {
            if (viewModel.currentTimeSlot == .repeatOption || viewModel.currentTimeSlot == .customOption) {
                Image("imgCalendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26)
                    .padding(.horizontal, 5)
                startDateView
            }
            
            if (viewModel.currentTimeSlot == .weeklyOption) {
                weekDaysView
            }
            
            if (viewModel.currentTimeSlot == .repeatOption) {
                endDateView
            }
            else  if (viewModel.currentTimeSlot == .customOption) {
                VStack (alignment: .leading, spacing: 5) {
                    HStack {
                        Text("")
                    }
                    
                    ZStack {
                        Button {
                        } label: {
                            Text("")
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 52)
            }
        }
        .padding()
    }
    
    //MARK: - Start/End Time View
    private var startEndTimeView: some View {
        HStack {
            Image("imgBirthTime")
                .resizable()
                .scaledToFit()
                .frame(width: 26)
                .padding(.horizontal, 5)
            startTimeView
            endTimeView
        }
        .padding()
    }
}
