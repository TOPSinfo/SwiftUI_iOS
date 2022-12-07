//
//  LanguageModel.swift
//  Astroyodha
//
//  Created by Tops on 06/12/22.
//

import Foundation

struct LanguageObject: Identifiable {
    let id: String
    let name: String
    var isSelected: Bool
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.isSelected = false
    }
}
