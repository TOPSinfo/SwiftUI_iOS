//
//  HelpAndFaqViewModel.swift
//  Astroyodha
//
//  Created by Tops on 06/12/22.
//

import Foundation

class HelpAndFaqViewModel: ObservableObject {
    @Published private(set) var arrHelpFaqData: [HelpAndFaq] = []
    
    init() {
        fetchHelpAndFaqData()
    }
    
    // MARK: - Fetch Help And Faq Data
    func fetchHelpAndFaqData() {
        let viewModel = CMSViewModel()
        viewModel.fetchCMSData(completion: { arrData in
            self.arrHelpFaqData = arrData
        })
    }
    
    // MARK: - Collaps All Section Before Expanding The Selected Section
    func collapsAllHelpAndFaqSections() {
        self.arrHelpFaqData.forEach { $0.isExpanded = false }
    }
}
