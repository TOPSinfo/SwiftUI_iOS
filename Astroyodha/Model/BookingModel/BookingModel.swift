//
//  BookingModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation

struct BookingObject {
    let id = UUID()
    let date: String
    let titleMessage: String
    let timing: String
    let status: String
    var category: String = ""
    let rate: String
    
    
    init(date: String, message: String, timing: String, status: String, category: String, rate: String) {
        self.date = date
        self.titleMessage = message
        self.timing = timing
        self.status = status
        self.category = category
        self.rate = rate
    }
}
