//
//  HelpAndFaqModel.swift
//  Astroyodha
//
//  Created by Tops on 06/12/22.
//

import Foundation

class HelpAndFaq: Identifiable {
    let id = UUID()
    var titleText: String
    var titleDescription: String
    var isExpanded: Bool
    
    init(title: String, description: String) {
        self.titleText = title
        self.titleDescription = description
        self.isExpanded = false
    }
}
