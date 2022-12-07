//
//  CMSViewModel.swift
//  Astroyodha
//
//  Created by Tops on 07/11/22.
//

import Foundation
import UIKit
import Firebase

struct CmsModel {
    let type: String
    let title: String
    let content: String
    
    init(type: String, title: String, content: String) {
        self.type = type
        self.title = title
        self.content = content
    }
}

class CMSViewModel: ObservableObject {
    //    @Published var cmsDataList = [CmsModel]()
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    func fetchCMSData(completion: @escaping ([HelpAndFaq]) -> Void) {
        db.collection("cms").document("XJIoE8Wryag3niOkX0Gj").collection("questions")
            .addSnapshotListener { snapshot, error in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    if let snapshot = snapshot {
                        let arrData: [HelpAndFaq] = snapshot.documents.map { faqData in
                            print(faqData["title"] as! String)
                            print(faqData["answer"] as! String)
                            
                            let objFAQ = HelpAndFaq.init(
                                title: faqData["title"] as! String,
                                description: faqData["answer"] as! String
                            )
                            
                            return objFAQ
                        }
                        
//                        Singletion.shared.hideProgress()
                        completion(arrData)
                    }
                }
            }
    }
}
