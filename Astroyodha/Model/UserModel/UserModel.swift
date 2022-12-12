//
//  UserModel.swift
//  Astroyodha
//
//  Created by Tops on 01/11/22.
//

import Foundation

class UserModel: Codable {
    var birthdate: String
    var birthplace: String
    var birthtime: String
    var createdat: Date
    var devicedetails: String
    var email: String
    var fullname: String
    var imagepath: String
    var isOnline: Bool
    var lastupdatetime: Date
    var phone: String
    var price: Int
    var profileimage: String
    var rating: Float
    var socialid: String
    var socialtype: String
    var speciality: [String]
    var languages: [String]
    var aboutYou: String
    var experience: Int
    var token: String
    var uid: String
    var usertype: String
    var walletbalance: Int
    
    init(birthdate: String, birthplace: String, birthtime: String, createdat: Date, devicedetails: String, email: String, fullname: String, imagepath: String, isOnline: Bool, lastupdatetime: Date, phone: String, price: Int? = 0, profileimage: String, rating: Float? = 0.0, socialid: String, socialtype: String, speciality: [String] = [], languages: [String] = [], aboutYou: String? = "", experience: Int? = 0, token: String, uid: String, usertype: String, walletbalance: Int) {
        self.birthdate = birthdate
        self.birthplace = birthplace
        self.birthtime = birthtime
        self.createdat = createdat
        self.devicedetails = devicedetails
        self.email = email
        self.fullname = fullname
        self.imagepath = imagepath
        self.isOnline = isOnline
        self.lastupdatetime = lastupdatetime
        self.phone = phone
        self.price = price ?? 0
        self.profileimage = profileimage
        self.rating = rating ?? 0
        self.socialid = socialid
        self.socialtype = socialtype
        self.speciality = speciality
        self.languages = languages
        self.aboutYou = aboutYou ?? ""
        self.experience = experience ?? 0
        self.token = token
        self.uid = uid
        self.usertype = usertype
        self.walletbalance = walletbalance
    }
}

struct LoginDataCache {
    static let key = "loginDataCache"
    static func save(_ value: UserModel!) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    static func get() -> UserModel! {
        var loginData: UserModel!
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            loginData = try? PropertyListDecoder().decode(UserModel.self, from: data)
            return loginData!
        } else {
            return loginData
        }
    }
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct AppointmentTimeSlotModel {
    var startDate: String
    var startTime: String
    var endDate: String
    var endTime: String
    var repeatDays: [String]
    var timeslotid: String
    var type: String
    var uid: String
    
    init(startDate: String, startTime: String, endDate: String, endTime: String, repeatDays: [String], timeslotid: String, type: String, uid: String) {
        self.startDate = startDate
        self.startTime = startTime
        self.endDate = endDate
        self.endTime = endTime
        self.repeatDays = repeatDays
        self.timeslotid = timeslotid
        self.type = type
        self.uid = uid
    }
}
