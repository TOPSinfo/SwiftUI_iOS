//
//  Constants.swift
//  Astroyodha
//
//  Created by Tops on 05/09/22.
//

import UIKit

var userPhotoPath = "images/users/\(TimeInterval(timestamp)).jpg"
let device = UIDevice.modelName
let pathPhoto = "images/bookings/\(TimeInterval(timestamp))_photo.jpg"
let pathKundali = "images/bookings/\(TimeInterval(timestamp))_Kundali.jpg"

var isTestingModeOn = false

//MARK: - Date formate
let backendDateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"
let datePickerSelectedFormat: String = "yyyy-MM-dd HH:mm:ss Z"
let datePickerDateFormat: String = "dd-MMM-yyyy"
let datePickerDateFormatWithoutDash: String = "dd MMM yyyy"
let datePickertimeFormat: String = "hh:mm a"

//MARK: - Share Link
let shareLink: String = "Hi, Check out AstroYodha at: https://play.google.com/store/apps/details?id=com.astroyodha"

// MARK: - Type alias
typealias VoidCallBack = (()-> Void)

// MARK: - Constants
var currentUserType = UserType.astrologer
let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

let textBoxWidth = UIScreen.main.bounds.width / 8
let textBoxHeight = UIScreen.main.bounds.width / 8
let spaceBetweenBoxes: CGFloat = 10
let paddingOfBox: CGFloat = 1


let timestamp = Date().currentTimeMillis()
var objUser: UserModel = UserModel(birthdate: "",
                                   birthplace: "",
                                   birthtime: "",
                                   createdat: Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                   devicedetails: "",
                                   email: "",
                                   fullname: "",
                                   imagepath: "",
                                   isOnline: false,
                                   lastupdatetime: Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                   phone: "",
                                   profileimage: "",
                                   socialid: "",
                                   socialtype: "",
                                   token: "",
                                   uid: "",
                                   usertype: "",
                                   walletbalance: 0)

var objAddBooking: BookingAstrologerModel = BookingAstrologerModel(allowextend: "",
                                                                   amount: 0,
                                                                   astrologercharge: 0,
                                                                   astrologerid: "",
                                                                   astrologername: "",
                                                                   birthdate: "",
                                                                   birthplace: "",
                                                                   birthtime: "",
                                                                   bookingid: "",
                                                                   createdat: Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                                                   date: Date.getCurrentDate(dateFormate: "dd-MM-yyyy").description,
                                                                   description: "",
                                                                   endtime: Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                                                   extendtime: 0,
                                                                   fullName: "",
                                                                   kundali: "",
                                                                   kundalipath: "",
                                                                   month: "",
                                                                   notificationmin: "",
                                                                   notify: "",
                                                                   paymentstatus: "",
                                                                   paymenttype: "",
                                                                   photo: "",
                                                                   starttime: Date(timeIntervalSince1970: Double(timestamp) / 1000),
                                                                   status: "",
                                                                   transactionid: "",
                                                                   uid: "",
                                                                   userbirthdate: "",
                                                                   username: "",
                                                                   userprofileimage: "",
                                                                   year: "")
