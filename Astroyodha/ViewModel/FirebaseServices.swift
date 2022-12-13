//
//  FirebaseServices.swift
//  Astroyodha
//
//  Created by Tops on 02/12/22.
//

import Foundation
import Firebase
import SwiftUI
import SVProgressHUD

class FirebaseService: ObservableObject {
    let db = Firestore.firestore()
    
    var strPhotoURL: String = ""
    var strKundaliURL: String = ""
}

// MARK: - Login User
extension FirebaseService {
    func loginUser(strPhoneNumber: String,
                   completion: @escaping (_ isCompleted: Bool) -> Void) {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = isTestingModeOn // firebase testing
        PhoneAuthProvider.provider().verifyPhoneNumber(strPhoneNumber, uiDelegate: nil) { ID, err in
            Singletion.shared.hideProgress()
            if err != nil {
                completion(false)
            } else {
                defaults.set(ID, forKey: UserDefaultKey.strVerificationID)
                defaults.set(strPhoneNumber, forKey: UserDefaultKey.strPhoneNumber)
                completion(true)
            }
        }
    }
}

// MARK: - Verify Phone Number And Send Otp
extension FirebaseService {
    func verifyNumberAndSendOTP(phone: String,
                                completion: @escaping (_ isCompleted: Bool, _ error: Error?, _ id: String) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { ID, err in
            if err != nil {
                Singletion.shared.hideProgress()
                completion(false, err, "")
                return
            }
            
            Singletion.shared.hideProgress()
            defaults.set(ID, forKey: UserDefaultKey.strVerificationID)
            defaults.set(phone, forKey: UserDefaultKey.strPhoneNumber)
            
            completion(true, nil, (ID ?? ""))
        }
    }
}

// MARK: - Check For Mobile Number Exist Or Not While SignIn/SignUp
extension FirebaseService {
    func checkMobileNumberIsExistOrNot(strPhoneNumber: String,
                                       completion: @escaping (_ isCompleted: Bool) -> Void) {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = isTestingModeOn // firebase testing
        
        let collectionRef = db.collection("user")
        collectionRef.whereField("phone", isEqualTo: strPhoneNumber).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else if (snapshot?.isEmpty)! {
                completion(false)
            } else {
                for document in (snapshot?.documents)! {
                    if document.data()["phone"] != nil {
                        completion(true)
                    }
                }
            }
        }
    }
}

// MARK: - Verify User Entered Otp
extension FirebaseService {
    func verifyOTP(credential: PhoneAuthCredential,
                   completion: @escaping (_ isCompleted: Bool,
                                          _ error: Error?,
                                          _ authResult: AuthDataResult?) -> Void) {
        Auth.auth().signIn(with: credential) { (authResult, err) in
            if err != nil {
                Singletion.shared.hideProgress()
                completion(false, err, nil)
                return
            } else {
                defaults.set(true, forKey: UserDefaultKey.isUserLoggedIn)
                objUser.uid = authResult!.user.uid
                objUser.token = authResult!.user.refreshToken ?? ""
                completion(true, err, authResult)
            }
        }
    }
}

// MARK: - Add User Data
extension FirebaseService {
    func addUserData() {
        let newUserReference = self.db.collection("user").document(objUser.uid)
        newUserReference.setData(["birthdate": objUser.birthdate,
                                  "birthplace": objUser.birthplace,
                                  "birthtime": objUser.birthtime,
                                  "createdat": Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                  "devicedetails": device,
                                  "email": objUser.email,
                                  "fullname": objUser.fullname,
                                  "isOnline": objUser.isOnline,
                                  "lastupdatetime": Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                  "phone": objUser.phone,
                                  "profileimage": objUser.profileimage,
                                  "socialid": objUser.socialid,
                                  "socialtype": objUser.socialtype,
                                  "token": objUser.token,
                                  "uid": objUser.uid,
                                  "usertype": currentUserType.rawValue,
                                  "walletbalance": objUser.walletbalance
                                 ]) { error in
            // Check for errors
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

// MARK: - Add Astrologer Data
extension FirebaseService {
    func addAstrologerData() {
        let objDefaultAstrology = Singletion.shared.arrAstrology.first { $0.name == "Vedic" }
        print(objDefaultAstrology?.id ?? "")
        
        let newUserReference = self.db.collection("user").document(objUser.uid)
        newUserReference.setData(["birthdate": objUser.birthdate,
                                  "createdat": Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                  "devicedetails": device,
                                  "email": objUser.email,
                                  "fullname": objUser.fullname,
                                  "isOnline": objUser.isOnline,
                                  "lastupdatetime": Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                  "phone": objUser.phone,
                                  "price": 0,
                                  "rating": 0,
                                  "socialid": objUser.socialid,
                                  "socialtype": objUser.socialtype,
                                  "speciality": [(objDefaultAstrology?.id ?? "")],
                                  "token": objUser.token,
                                  "uid": objUser.uid,
                                  "usertype": currentUserType.rawValue,
                                  "walletbalance": objUser.walletbalance
                                 ]) { error in
            // Check for errors
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

// MARK: - Update User/Astrologer Profile Photo
extension FirebaseService {
    func uploadProfileImage(imgPhoto: UIImage,
                            dict: [String: Any],
                            isUser: Bool,
                            completion: @escaping (_ isCompleted: Bool) -> Void) {
        guard (Auth.auth().currentUser?.uid) != nil else{ return }
        
        userPhotoPath = Singletion.shared.objLoggedInUser.imagepath.isEmpty
        ? userPhotoPath
        : Singletion.shared.objLoggedInUser.imagepath
        
        let storageRefrance = Storage.storage().reference()
        guard let imageDataProfile = imgPhoto.jpegData(compressionQuality: 0.5) else { return }
        let fileRefProfile = storageRefrance.child(userPhotoPath)
        
        _ = fileRefProfile.putData(imageDataProfile, metadata: nil) { metaData, error in
            if error == nil && metaData != nil {
                let storageRefrance = Storage.storage().reference().child(userPhotoPath)
                storageRefrance.downloadURL { url, err in
                    if err == nil && url != nil {
                        print("URL ==> \(url!.absoluteString)")
                        
                        if isUser {
                            var dictUser: [String: Any] = dict
                            dictUser["imagepath"] = userPhotoPath
                            dictUser["profileimage"] = url?.absoluteString ?? ""
                            
                            self.updateUserData(dict: dictUser) { isCompleted in
                                if isCompleted {
                                    completion(true)
                                }
                            }
                        } else {
                            var dictAstrologer: [String: Any] = dict
                            dictAstrologer["imagepath"] = userPhotoPath
                            dictAstrologer["profileimage"] = url?.absoluteString ?? ""
                            
                            self.updateAstrologerData(dict: dictAstrologer) { isCompleted in
                                if isCompleted {
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Update Astroloer Profile Data
extension FirebaseService {
    func updateAstrologerData(dict: [String: Any],
                              completion: @escaping (_ isCompleted: Bool) -> Void) {
        let userUID = Auth.auth().currentUser?.uid ?? ""
        db.collection("user").whereField("uid", isEqualTo: userUID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else if querySnapshot!.documents.count != 1 {
                // Perhaps this is an error for you?
            } else {
                let document = querySnapshot!.documents.first
                document?.reference.updateData([
                    "fullname": (dict["fullname"] as? String ?? ""),
                    "phone": (dict["phone"] as? String ?? ""),
                    "email": (dict["email"] as? String ?? ""),
                    "birthdate": (dict["birthdate"] as? String ?? ""),
                    "languages": (dict["languages"] as? [String] ?? []),
                    "speciality": (dict["speciality"] as? [String] ?? []),
                    "price": (dict["price"] as? Int ?? 0),
                    "experience": (dict["experience"] as? Int ?? 0),
                    "aboutyou": (dict["aboutyou"] as? String ?? ""),
                    "imagepath": (dict["imagepath"] as? String ?? ""),
                    "profileimage": (dict["profileimage"] as? String ?? "")
                ], completion: { error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            completion(true)
                        }
                    }
                })
            }
        }
    }
}

// MARK: - Update User Profile Data
extension FirebaseService {
    func updateUserData(dict: [String: Any],
                        completion: @escaping (_ isCompleted: Bool) -> Void) {
        let userUID = Auth.auth().currentUser?.uid ?? ""
        db.collection("user").whereField("uid", isEqualTo: userUID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else if querySnapshot!.documents.count != 1 {
                // Perhaps this is an error for you?
            } else {
                let document = querySnapshot!.documents.first
                document?.reference.updateData([
                    "fullname": (dict["fullname"] as? String ?? "") ,
                    "phone": (dict["phone"] as? String ?? "") ,
                    "email": (dict["email"] as? String ?? "") ,
                    "birthdate": (dict["birthdate"] as? String ?? "") ,
                    "birthtime": (dict["birthtime"] as? String ?? "") ,
                    "birthplace": (dict["birthplace"] as? String ?? ""),
                    "imagepath": (dict["imagepath"] as? String ?? ""),
                    "profileimage": (dict["profileimage"] as? String ?? "")
                ], completion: { error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            completion(true)
                        }
                    }
                })
            }
        }
    }
}

extension FirebaseService {
    // MARK: - Add Astrologer Timeslot Data
    func addAstrologerTimeSlotData(objSlot: AppointmentTimeSlotModel,
                                   completion: @escaping (_ isCompleted: Bool) -> Void) {
        let timeSlotReference = self.db.collection("user").document(objSlot.uid).collection("timeslot").document(objSlot.timeslotid)
        
        timeSlotReference.setData(["createdat": Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                   "enddate": objSlot.endDate,
                                   "endtime": objSlot.endTime,
                                   "repeatdays": objSlot.repeatDays,
                                   "startdate": objSlot.startDate,
                                   "starttime": objSlot.startTime,
                                   "timeslotid": objSlot.timeslotid,
                                   "type": objSlot.type,
                                   "uid": objSlot.uid,
                                  ]) { error in
            // Check for errors
            if error != nil {
                print(error!.localizedDescription)
                completion(false)
            } else {
                Singletion.shared.arrAppointments.append(objSlot)
                completion(true)
            }
        }
    }
    
    // MARK: - Get User TimeSlot Data
    func getUserTimeSlots(completion: @escaping (_ appointments: [AppointmentTimeSlotModel]) -> Void) {
        if let userUID = Auth.auth().currentUser?.uid {
            db.collection("user").document(userUID).collection("timeslot").getDocuments { timeslotSnapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    if let snapshot = timeslotSnapshot {
                        DispatchQueue.main.async {
                            Singletion.shared.arrAppointments = snapshot.documents.map { timeSlotData in
                                let objAppointmentSlot = AppointmentTimeSlotModel.init(startDate: timeSlotData["startdate"] as? String ?? "",
                                                                                       startTime: timeSlotData["starttime"] as? String ?? "",
                                                                                       endDate: timeSlotData["enddate"] as? String ?? "",
                                                                                       endTime: timeSlotData["endtime"] as? String ?? "",
                                                                                       repeatDays: timeSlotData["repeatdays"] as? [String] ?? [],
                                                                                       timeslotid: timeSlotData["timeslotid"] as? String ?? "",
                                                                                       type: timeSlotData["type"] as? String ?? "",
                                                                                       uid: timeSlotData["uid"] as? String ?? "")
                                return objAppointmentSlot
                            }
                            completion(Singletion.shared.arrAppointments)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Astrologer TimeSlot Data
    func deleteAstrologerTimeSlotData(objSlot: AppointmentTimeSlotModel,
                                      completion: @escaping (_ isCompleted: Bool) -> Void) {
        let timeSlotReference = self.db.collection("user").document(objSlot.uid).collection("timeslot")
        timeSlotReference.document(objSlot.timeslotid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(false)
            } else {
                print("Document successfully removed!")
                completion(true)
            }
        }
    }
}

// MARK: - Get All Astrologers
extension FirebaseService {
    func fetchAllAstrologer(completion: @escaping (_ arrData: [AstrologerGridItmeVM]) -> Void) {
        db.collection("user").whereField("usertype", isEqualTo: "astrologer")
            .addSnapshotListener { querySnapshot, error in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    if let snapshot = querySnapshot {
                        let arrUsers: [AstrologerGridItmeVM] = snapshot.documents.map { userData in
                            let astroUser = AstrologerGridItmeVM(name: userData["fullname"] as? String ?? "",
                                                                 price: userData["price"] as? Int ?? 0,
                                                                 uid: userData["uid"] as? String ?? "",
                                                                 ratting: Float(userData["rating"] as? Int ?? 0),
                                                                 address: userData["phone"] as? String ?? "",
                                                                 imageAstro: userData["profileimage"] as? String ?? "",
                                                                 speciality: userData["speciality"] as? [String] ?? [])
                            
                            return astroUser
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            completion(arrUsers)
                        }
                    }
                }
            }
    }
}

// MARK: - Add Booking Data
extension FirebaseService {
    func addBooking(timeSloat: String,
                    completion: @escaping (_ isCompleted: Bool) -> Void) {
        // Add a data to a collection
        let timeSlotReference = self.db.collection("bookinghistory").document(timeSloat)
        timeSlotReference.setData(["allowextend": objAddBooking.allowextend,
                                   "amount": objAddBooking.amount,
                                   "astrologercharge": objAddBooking.astrologercharge,
                                   "astrologerid": objAddBooking.astrologerid,
                                   "astrologername": objAddBooking.astrologername,
                                   "birthdate": objAddBooking.birthdate,
                                   "birthplace": objAddBooking.birthplace,
                                   "birthtime": objAddBooking.birthtime,
                                   "bookingid": objAddBooking.bookingid,
                                   "createdat": Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                   "date": objAddBooking.date,
                                   "description": objAddBooking.description,
                                   "endtime": objAddBooking.endtime,
                                   "extendtime": objAddBooking.extendtime,
                                   "fullName": objAddBooking.fullName,
                                   "kundali": strKundaliURL,
                                   "kundalipath": pathKundali,
                                   "month": objAddBooking.month,
                                   "notificationmin": objAddBooking.notificationmin,
                                   "notify": objAddBooking.notify,
                                   "paymentstatus": objAddBooking.paymentstatus,
                                   "paymenttype": objAddBooking.paymenttype,
                                   "photo": strPhotoURL,
                                   "photopath": pathPhoto,
                                   "starttime": objAddBooking.starttime,
                                   "status": objAddBooking.status,
                                   "transactionid": objAddBooking.transactionid,
                                   "uid": objAddBooking.uid,
                                   "userbirthdate": objAddBooking.userbirthdate,
                                   "username": objAddBooking.username,
                                   "userprofileimage": objAddBooking.userprofileimage,
                                   "year": objAddBooking.year
                                  ]) { error in
            // Check for errors
            if error != nil {
                print(error!.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

// MARK: - Fetch Booking Data
extension FirebaseService {
    func fetchBookingsData(completion: @escaping (_ upcomingData: [BookingAstrologerModel],
                                                  _ ongoingData: [BookingAstrologerModel],
                                                  _ pastData: [BookingAstrologerModel]) -> Void) {
        var comparingFieldKey = ""
        if let userUID = Auth.auth().currentUser?.uid {
            
            if currentUserType == .user {
                comparingFieldKey = "uid"
            } else {
                comparingFieldKey = "astrologerid"
            }
            
            db.collection("bookinghistory").whereField(comparingFieldKey, isEqualTo: userUID)
                .addSnapshotListener { querySnapshot, error in
                    if let err = error {
                        print("Error getting documents: \(err)")
                    } else {
                        if let snapshot = querySnapshot {
                            let arrAllBookings: [BookingAstrologerModel] = snapshot.documents.map { userData in
                                var createdAt: Date?
                                var endTime: Date?
                                var startTime: Date?
                                
                                if let createAtTimestamp: Timestamp = userData.get("createdat") as? Timestamp {
                                    createdAt = createAtTimestamp.dateValue()
                                }
                                
                                if let endTimeStamp: Timestamp = userData.get("endtime") as? Timestamp {
                                    endTime = endTimeStamp.dateValue()
                                }
                                
                                if let startTimeStamp: Timestamp = userData.get("starttime") as? Timestamp {
                                    startTime = startTimeStamp.dateValue()
                                }
                                
                                let booking = BookingAstrologerModel.init(
                                                                          allowextend: userData["allowextend"] as? String ?? "",
                                                                          amount: userData["amount"] as? Int ?? 0,
                                                                          astrologercharge: userData["astrologercharge"] as? Int ?? 0,
                                                                          astrologerid: userData["astrologerid"] as? String ?? "",
                                                                          astrologername: userData["astrologername"] as? String ?? "",
                                                                          birthdate: userData["birthdate"] as? String ?? "",
                                                                          birthplace: userData["birthplace"] as? String ?? "",
                                                                          birthtime: userData["birthtime"] as? String ?? "",
                                                                          bookingid: userData["bookingid"] as? String ?? "",
                                                                          createdat: createdAt ?? Date(),
                                                                          date: userData["date"] as? String ?? "",
                                                                          description: userData["description"] as? String ?? "",
                                                                          endtime: endTime ?? Date(),
                                                                          extendtime: userData["extendtime"] as? Int ?? 0,
                                                                          fullName: userData["fullName"] as? String ?? "",
                                                                          kundali: userData["kundali"] as? String ?? "",
                                                                          kundalipath: userData["kundalipath"] as? String ?? "",
                                                                          month: userData["month"] as? String ?? "",
                                                                          notificationmin: userData["notificationmin"] as? String ?? "",
                                                                          notify: userData["notify"] as? String ?? "",
                                                                          paymentstatus: userData["paymentstatus"] as? String ?? "",
                                                                          paymenttype: userData["paymenttype"] as? String ?? "",
                                                                          photo: userData["photo"] as? String ?? "",
                                                                          starttime: startTime ?? Date(),
                                                                          status: userData["status"] as? String ?? "",
                                                                          transactionid: userData["transactionid"] as? String ?? "",
                                                                          uid: userData["uid"] as? String ?? "",
                                                                          userbirthdate: userData["userbirthdate"] as? String ?? "",
                                                                          username: userData["username"] as? String ?? "",
                                                                          userprofileimage: userData["userprofileimage"] as? String ?? "",
                                                                          year: userData["year"] as? String ?? "")
                                
                                return booking
                            }
                            
                            var arrUpcomingBookings: [BookingAstrologerModel] = []
                            var arrOnGoingBookings: [BookingAstrologerModel] = []
                            var arrPastBookings: [BookingAstrologerModel] = []
                            
                            for booking in arrAllBookings {
                                print(booking.starttime)
                                
                                let endDate = Singletion.shared.convertStringToDate(strDate: booking.date,
                                                                                    outputFormate: datePickerDateFormat)
                                let status = Singletion.shared.compareDate(date: endDate)
                                
                                if status == .upcoming {
                                    arrUpcomingBookings.append(booking)
                                } else if status == .ongoing {
                                    arrOnGoingBookings.append(booking)
                                } else if status == .past {
                                    arrPastBookings.append(booking)
                                }
                            }
                            completion(arrUpcomingBookings, arrOnGoingBookings, arrPastBookings)
                        }
                    }
                }
        }
    }
}

// MARK: - Fetch Particular Date Booking Data
extension FirebaseService {
    func fetchSelectedDateBookings(selectedDate: Date,
                                   completion: @escaping (_ bookingsData: [BookingAstrologerModel]) -> Void) {
        var comparingFieldKey = ""
        if let userUID = Auth.auth().currentUser?.uid {
            
            if currentUserType == .user {
                comparingFieldKey = "uid"
            } else {
                comparingFieldKey = "astrologerid"
            }
            
            db.collection("bookinghistory").whereField(comparingFieldKey, isEqualTo: userUID)
                .addSnapshotListener { querySnapshot, error in
                    if let err = error {
                        print("Error getting documents: \(err)")
                    } else {
                        if let snapshot = querySnapshot {
                            let arrAllBookings: [BookingAstrologerModel] = snapshot.documents.map { userData in
                                var createdAt: Date?
                                var endTime: Date?
                                var startTime: Date?
                                
                                if let createAtTimestamp: Timestamp = userData.get("createdat") as? Timestamp {
                                    createdAt = createAtTimestamp.dateValue()
                                }
                                
                                if let endTimeStamp: Timestamp = userData.get("endtime") as? Timestamp {
                                    endTime = endTimeStamp.dateValue()
                                }
                                
                                if let startTimeStamp: Timestamp = userData.get("starttime") as? Timestamp {
                                    startTime = startTimeStamp.dateValue()
                                }
                                
                                let booking = BookingAstrologerModel.init(
                                                                          allowextend: userData["allowextend"] as? String ?? "",
                                                                          amount: userData["amount"] as? Int ?? 0,
                                                                          astrologercharge: userData["astrologercharge"] as? Int ?? 0,
                                                                          astrologerid: userData["astrologerid"] as? String ?? "",
                                                                          astrologername: userData["astrologername"] as? String ?? "",
                                                                          birthdate: userData["birthdate"] as? String ?? "",
                                                                          birthplace: userData["birthplace"] as? String ?? "",
                                                                          birthtime: userData["birthtime"] as? String ?? "",
                                                                          bookingid: userData["bookingid"] as? String ?? "",
                                                                          createdat: createdAt ?? Date(),
                                                                          date: userData["date"] as? String ?? "",
                                                                          description: userData["description"] as? String ?? "",
                                                                          endtime: endTime ?? Date(),
                                                                          extendtime: userData["extendtime"] as? Int ?? 0,
                                                                          fullName: userData["fullName"] as? String ?? "",
                                                                          kundali: userData["kundali"] as? String ?? "",
                                                                          kundalipath: userData["kundalipath"] as? String ?? "",
                                                                          month: userData["month"] as? String ?? "",
                                                                          notificationmin: userData["notificationmin"] as? String ?? "",
                                                                          notify: userData["notify"] as? String ?? "",
                                                                          paymentstatus: userData["paymentstatus"] as? String ?? "",
                                                                          paymenttype: userData["paymenttype"] as? String ?? "",
                                                                          photo: userData["photo"] as? String ?? "",
                                                                          starttime: startTime ?? Date(),
                                                                          status: userData["status"] as? String ?? "",
                                                                          transactionid: userData["transactionid"] as? String ?? "",
                                                                          uid: userData["uid"] as? String ?? "",
                                                                          userbirthdate: userData["userbirthdate"] as? String ?? "",
                                                                          username: userData["username"] as? String ?? "",
                                                                          userprofileimage: userData["userprofileimage"] as? String ?? "",
                                                                          year: userData["year"] as? String ?? "")
                                
                                return booking
                            }
                            
                            var arrSelectedDayBookings: [BookingAstrologerModel] = []
                            for booking in arrAllBookings {
                                print(booking.starttime)
                                
                                let endDate = Singletion.shared.convertStringToDate(strDate: booking.date,
                                                                                    outputFormate: datePickerDateFormat)
                                
                                let currentDate = Singletion.shared.convertStringToDate(
                                    strDate: Singletion.shared.convertDateFormate(date: selectedDate,
                                                                                  currentFormate: datePickerSelectedFormat,
                                                                                  outputFormat: datePickerDateFormatWithoutDash),
                                    outputFormate: datePickerDateFormatWithoutDash)
                                
                                let bookingDate = Singletion.shared.convertStringToDate(
                                    strDate: Singletion.shared.convertDateFormate(date: endDate,
                                                                                  currentFormate: datePickerSelectedFormat,
                                                                                  outputFormat: datePickerDateFormatWithoutDash),
                                    outputFormate: datePickerDateFormatWithoutDash)
                                
                                if bookingDate == currentDate {
                                    arrSelectedDayBookings.append(booking)
                                }
                            }
                            
                            self.fetchDayBooking(selectedDate: selectedDate,
                                                 arrAllBookings: arrAllBookings) { bookingsData in
                                arrSelectedDayBookings = bookingsData
                            }
                            completion(arrSelectedDayBookings)
                        }
                    }
                }
        }
    }
    
    // MARK: - Filter data
    func fetchDayBooking(selectedDate: Date,
                         arrAllBookings: [BookingAstrologerModel],
                         completion: @escaping (_ bookingsData: [BookingAstrologerModel]) -> Void) {
        var arrSelectedDayBookings: [BookingAstrologerModel] = []
        for booking in arrAllBookings {
            print(booking.starttime)
            
            let endDate = Singletion.shared.convertStringToDate(strDate: booking.date,
                                                                outputFormate: datePickerDateFormat)
            
            let currentDate = Singletion.shared.convertStringToDate(
                strDate: Singletion.shared.convertDateFormate(date: selectedDate,
                                                              currentFormate: datePickerSelectedFormat,
                                                              outputFormat: datePickerDateFormatWithoutDash),
                outputFormate: datePickerDateFormatWithoutDash)
            
            let bookingDate = Singletion.shared.convertStringToDate(
                strDate: Singletion.shared.convertDateFormate(date: endDate,
                                                              currentFormate: datePickerSelectedFormat,
                                                              outputFormat: datePickerDateFormatWithoutDash),
                outputFormate: datePickerDateFormatWithoutDash)
            
            if bookingDate == currentDate {
                arrSelectedDayBookings.append(booking)
            }
            
            completion(arrSelectedDayBookings)
        }
    }
}

// MARK: - Upload Add Event Attachment
extension FirebaseService {
    func uploadImage(imageProfile: UIImage,
                     imageKundali: UIImage,
                     timeslotid: String,
                     completion: @escaping (_ isCompleted: Bool) -> Void)  {
        
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        let storageRefrance = Storage.storage().reference()
        
        guard let imageDataProfile = imageProfile.jpegData(compressionQuality: 0.5) else { return }
        guard let imageDataKundali = imageKundali.jpegData(compressionQuality: 0.5) else { return }
        
        let fileRefProfile = storageRefrance.child(pathPhoto)
        let fileRefKundali = storageRefrance.child(pathKundali)
        
        _ = fileRefProfile.putData(imageDataProfile, metadata: nil) { metaData, error in
            if error == nil && metaData != nil {
                _ = fileRefKundali.putData(imageDataKundali, metadata: nil) { metaData, error in
                    if error == nil && metaData != nil {
                        let storageRefrance = Storage.storage().reference().child(pathPhoto)
                        storageRefrance.downloadURL { url, err in
                            if err == nil && url != nil {
                                self.strPhotoURL = url!.absoluteString // Get photo url
                                
                                let storageRefrance = Storage.storage().reference().child(pathKundali)
                                storageRefrance.downloadURL { url, err in
                                    if err == nil && url != nil {
                                        self.strKundaliURL = url!.absoluteString // Get photo url
                                        self.addBooking(timeSloat: timeslotid) { isComplet in
                                            completion(isComplet)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
