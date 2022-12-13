//
//  Singleton.swift
//  Astroyodha
//
//  Created by Tops on 01/11/22.
//

import Foundation
import SwiftUI
import SVProgressHUD

class Singletion {
    static let shared = Singletion()
    
    private init() { }
    var userViewModel = UserViewModel()
    
    @Published var arrLanguage: [LanguageObject] = []
    @Published var arrAstrology: [AstrologyObject] = []
        
    var arrDays: [DayObject] = []
    var arrRepeat: [RepeatObject] = []
    var arrAppointments: [AppointmentTimeSlotModel] = []
    
    var arrBookingDates: [Date] = []
    
    var objLoggedInUser: UserModel = UserModel(birthdate: "", birthplace: "", birthtime: "", createdat: Date(), devicedetails: "", email: "", fullname: "", imagepath: "", isOnline: false, lastupdatetime: Date(), phone: "", price: 0, profileimage: "", rating: 0.0, socialid: "", socialtype: "", speciality: [], languages: [], aboutYou: "", experience: 0, token: "", uid: "", usertype: "", walletbalance: 0)
    
    // Days Data for Weekly TimeSlot
    func setDaysData() {
        arrDays = [
            DayObject.init(name: "SUNDAY"),
            DayObject.init(name: "MONDAY"),
            DayObject.init(name: "TUESDAY"),
            DayObject.init(name: "WEDNESDAY"),
            DayObject.init(name: "THURSDAY"),
            DayObject.init(name: "FRIDAY"),
            DayObject.init(name: "SATURDAY")
        ]
    }
    
    // Appointment TimeSlot Repeat Options
    func setRepeatData() {
        arrRepeat = [
            RepeatObject.init(id: "1", name: "Repeat"),
            RepeatObject.init(id: "2", name: "Weekly"),
            RepeatObject.init(id: "3", name: "Custom")
        ]
    }

    // Get Language Data
    func getLanguageData() {
        userViewModel.fetchLanguage()
    }
    
    // Get Astrology Data
    func getAstrologyData() {
        userViewModel.fetchAstrology()
    }
    
    /*
     I am giving Vastu, Tarot, Psychic services then we are converting custom model data to single string to display in user profile screen
     */
    // MARK: - Convert User Astrology into Single String
    func convertUserAstrologyIntoString(objLoggedInUser: UserModel) -> String {
        Singletion.shared.arrAstrology.indices.forEach { Singletion.shared.arrAstrology[$0].isSelected = false }
        var arrAstrology: [AstrologyObject] = []
        
        for item in objLoggedInUser.speciality {
            if let obj = Singletion.shared.arrAstrology.first(where: { $0.id == item}) {
                
                if let row = Singletion.shared.arrAstrology.firstIndex(where: {$0.id == obj.id}) {
                    Singletion.shared.arrAstrology[row].isSelected = true
                }
                
                arrAstrology.append(obj)
            }
        }
        
        let arrNames = arrAstrology.map({ (astrology: AstrologyObject) -> String in
            astrology.name
        })
        let strAstrology = (arrNames.map{String($0)}.joined(separator: ", "))
        return strAstrology
    }
    
    /*
     To show the astrologer astrology services in User Dashboard
     */
    // MARK: - Convert Astrologer Astrology into Single String
    func getAstrologerSpecialityIntoString(speciality: [String]) -> String {
        Singletion.shared.arrAstrology.indices.forEach { Singletion.shared.arrAstrology[$0].isSelected = false }
        var arrAstrology: [AstrologyObject] = []
        
        for item in speciality {
            if let obj = Singletion.shared.arrAstrology.first(where: { $0.id == item}) {
                arrAstrology.append(obj)
            }
        }
        
        let arrNames = arrAstrology.map({ (astrology: AstrologyObject) -> String in
            astrology.name
        })
        let strAstrology = (arrNames.map{String($0)}.joined(separator: ", "))
        return strAstrology
    }
    
    /*
     To show the astrologer languages in User Profile
     */
    // MARK: - Convert Astrologer Languages into Single String
    func convertUserLanguagesIntoString(objLoggedInUser: UserModel) -> String {
        Singletion.shared.arrLanguage.indices.forEach { Singletion.shared.arrLanguage[$0].isSelected = false }
        var arrLanguages: [LanguageObject] = []
        
        for item in objLoggedInUser.languages {
            if let obj = Singletion.shared.arrLanguage.first(where: { $0.id == item}) {
                
                if let row = Singletion.shared.arrLanguage.firstIndex(where: {$0.id == obj.id}) {
                    Singletion.shared.arrLanguage[row].isSelected = true
                }
                
                arrLanguages.append(obj)
            }
        }
        
        let arrLang = arrLanguages.map({ (language: LanguageObject) -> String in
            language.name
        })
        let strLanguage = arrLang.map{ String($0) }.joined(separator: ", ")
        return strLanguage
    }
    
    // MARK: - Share Dialog
    func showActivityPopup() {
        let shareActivity = UIActivityViewController(activityItems: [shareLink],
                                                     applicationActivities: nil)
        if let vc = UIApplication.shared.currentUIWindow()?.rootViewController {
            shareActivity.popoverPresentationController?.sourceView = vc.view
            shareActivity.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2,
                                                                             y: UIScreen.main.bounds.height,
                                                                             width: 0,
                                                                             height: 0)
            shareActivity.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            vc.present(shareActivity, animated: true, completion: nil)
        }
    }
    
    // MARK: - Divider
    func addDivider(color: Color,
                    opacityValue: Double,
                    height: CGFloat) -> some View {
        return color.opacity(opacityValue)
            .frame(height: height / UIScreen.main.scale)
    }
    
    // MARK: - Date Fuctions
    /*
     Convert string date to any format. You just need to pass the 3 Params
     1. String Date
     2. String Date Format
     3. Output Date Format
     */
    
    func convertStringDateToRequestedFormated(strDate: String,
                                              inputFormat: String,
                                              outputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = backendDateFormat
        
        if let date = dateFormatter.date(from: strDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let strDate = outputFormatter.string(from: date)
            let outputDate = outputFormatter.date(from: strDate)
            outputFormatter.dateFormat = outputFormat
            let strOutputDate = outputFormatter.string(from: outputDate!)
            
            return strOutputDate
        } else {
            return "-"
        }
    }
    
    /*
     Convert Date to string format. You just need to pass the 3 Params
     1. Date
     2. Input Date Format
     3. Output Date Format
     */
    func convertDateFormate(date: Date,
                            currentFormate: String,
                            outputFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormate
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = outputFormat
        let myStringDate = formatter.string(from: yourDate!)
        return myStringDate
    }
    
    /*
     Convert Current date into String Date
     */
    func convertToday(outputFormatter: String) -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = outputFormatter
        let strOutput = formatter3.string(from: Date.now)
        return strOutput
    }
    
    func getDateMonthYearFromDate(birthDate: String,
                                  inputFormat: String) -> Date {
        var outPutDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        if  let date = dateFormatter.date(from: birthDate) {
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "MM"
            let month = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "HH"
            let hour = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "mm"
            let minute = dateFormatter.string(from: date)
            
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: Int(year),
                                            month: Int(month),
                                            day: Int(day),
                                            hour: Int(hour),
                                            minute: Int(minute))
            if let customDate = calendar.date(from: components) {
                outPutDate = customDate
            }
        }
        
        return outPutDate
    }
    
    /*
     Date Comparision to Check the Booking Status wether it's Upcoming, Ongoing or Past
     */
    func compareDate(date: Date) -> BookingFilter {
        var currentBooking: BookingFilter = .upcoming
        
        let startDate = convertStringToDate(
            strDate: self.convertDateFormate(date: date, currentFormate: datePickerSelectedFormat,
                                             outputFormat: datePickerDateFormatWithoutDash),
            outputFormate: datePickerDateFormatWithoutDash)
        
        let currentDate = convertStringToDate(
            strDate: self.convertDateFormate(date: Date(),
                                             currentFormate: datePickerSelectedFormat,
                                             outputFormat: datePickerDateFormatWithoutDash),
            outputFormate: datePickerDateFormatWithoutDash)
        
        if startDate > currentDate {
            currentBooking = .upcoming
        } else if startDate < currentDate {
            currentBooking = .past
        } else {
            currentBooking = .ongoing
        }
        
        return currentBooking
    }
    
    func convertStringToDate(strDate: String,
                             outputFormate: String) -> Date {
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = outputFormate
        if let date = dateFormatter.date(from: strDate) {
           return date
        }
        return Date()
    }
    
    func convertDateStringInSpecificFormat(startDate: String,
                                           endDate: String) -> String {
        let startDateWords = startDate.components(separatedBy: ["-"])
        let endDateWords = endDate.components(separatedBy: ["-"])
        
        if endDate.isEmpty {
            let strStart = startDateWords[0] + " " + startDateWords[1]
            return strStart
        } else {
            let strStart = startDateWords[0] + " " + startDateWords[1]
            let strEnd = endDateWords[0] + " " + endDateWords[1]
            
            return strStart + " to " + strEnd
        }
    }
    
    // MARK: - Email Validation
    func isValidEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    // MARK: - Phone Number Validation
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if(phone.count >= 4 && phone.count <= 12) {
            return phoneTest.evaluate(with: phone)
        } else {
            return false
        }
    }
    
    // MARK: - SVProgressHUD -
    func customizationSVProgressHUD() {
        SVProgressHUD.setDefaultMaskType(.black)
    }
    
    func showDefaultProgress() {
        SVProgressHUD.show()
    }
    
    func showProgressWithTitle(title: String) {
        SVProgressHUD.show(withStatus: title)
    }
    
    func hideProgress() {
        SVProgressHUD.dismiss()
    }
    
    // MARK: - Clear User Object
    func clearUserObject() {
        objUser = UserModel.init(birthdate: "", birthplace: "",
                                 birthtime: "", createdat: Date(),
                                 devicedetails: "", email: "",
                                 fullname: "", imagepath: "",
                                 isOnline: false, lastupdatetime: Date(),
                                 phone: "", profileimage: "",
                                 socialid: "", socialtype: "",
                                 token: "", uid: "", usertype: "", walletbalance: 0)
    }
    
    // MARK: - Generate Random Alpha Numeric String Id For Firebase Document Id
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0 ..< length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex,
                                                 offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }

        return randomString
    }
}

struct DayObject: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
    
    init(name: String) {
        self.name = name
        self.isSelected = false
    }
}
