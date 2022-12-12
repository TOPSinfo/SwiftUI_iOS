//
//  BookingAstrologerModel.swift
//  Astroyodha
//
//  Created by Tops on 02/11/22.
//

import Foundation

class BookingAstrologerModel {
    var allowextend: String
    var amount: Int
    var astrologercharge: Int
    var astrologerid: String
    var astrologername: String
    var birthdate: String
    var birthplace: String
    var birthtime: String
    var bookingid: String
    var createdat: Date
    var date: String
    var description: String
    var endtime: Date
    var extendtime: Int
    var fullName: String
    var kundali: String
    var kundalipath: String
    var month: String
    var notificationmin: String
    var notify: String
    var paymentstatus: String
    var paymenttype: String
    var photo: String
    var starttime: Date
    var status: String
    var transactionid: String
    var uid: String
    var userbirthdate: String
    var username: String
    var userprofileimage: String
    var year: String
    
    init(allowextend: String, amount: Int, astrologercharge: Int, astrologerid: String, astrologername: String, birthdate: String, birthplace: String, birthtime: String, bookingid: String, createdat: Date, date: String, description: String, endtime: Date, extendtime: Int, fullName: String, kundali: String, kundalipath: String, month: String, notificationmin: String, notify: String, paymentstatus: String, paymenttype: String, photo: String, starttime: Date, status: String, transactionid: String, uid: String, userbirthdate: String, username: String, userprofileimage: String, year: String) {
        self.allowextend = allowextend
        self.amount = amount
        self.astrologercharge = astrologercharge
        self.astrologerid = astrologerid
        self.astrologername = astrologername
        self.birthdate = birthdate
        self.birthplace = birthplace
        self.birthtime = birthtime
        self.bookingid = bookingid
        self.createdat = createdat
        self.date = date
        self.description = description
        self.endtime = endtime
        self.extendtime = extendtime
        self.fullName = fullName
        self.kundali = kundali
        self.kundalipath = kundalipath
        self.month = month
        self.notificationmin = notificationmin
        self.notify = notify
        self.paymentstatus = paymentstatus
        self.paymenttype = paymenttype
        self.photo = photo
        self.starttime = starttime
        self.status = status
        self.transactionid = transactionid
        self.uid = uid
        self.userbirthdate = userbirthdate
        self.username = username
        self.userprofileimage = userprofileimage
        self.year = year
    }
}
