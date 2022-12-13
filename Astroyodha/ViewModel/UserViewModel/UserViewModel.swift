//
//  UserViewModel.swift
//  Astroyodha
//
//  Created by Tops on 01/11/22.
//

import Foundation
import Firebase
import SwiftUI
import SVProgressHUD

class UserViewModel: ObservableObject {
    // Reference to the Database
    let db = Firestore.firestore()
    
    // MARK: - Get Current User Data
    func fetchCurrentUserData(completion: @escaping (_ user: UserModel) -> Void) {
        if let userUID = Auth.auth().currentUser?.uid {
            
           db.collection("user").document(userUID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let userData = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let objUser = UserModel(birthdate: userData["birthdate"] as? String ?? "",
                                            birthplace: userData["birthplace"] as? String ?? "",
                                            birthtime:  userData["birthtime"] as? String ?? "",
                                            createdat: userData["createdat"] as? Date ?? Foundation.Date(),
                                            devicedetails: userData["devicedetails"] as? String ?? "",
                                            email: userData["email"] as? String ?? "",
                                            fullname: userData["fullname"] as? String ?? "",
                                            imagepath: userData["imagepath"] as? String ?? "",
                                            isOnline: userData["isOnline"] as? Bool ?? false,
                                            lastupdatetime: userData["lastupdatetime"] as? Date ?? Foundation.Date(),
                                            phone: userData["phone"] as? String ?? "",
                                            price: userData["price"] as? Int ?? 0,
                                            profileimage: userData["profileimage"] as? String ?? "",
                                            rating: userData["rating"] as? Float ?? 0.0,
                                            socialid: userData["socialid"] as? String ?? "",
                                            socialtype: userData["socialtype"] as? String ?? "",
                                            speciality: userData["speciality"] as? [String] ?? [],
                                            languages: userData["languages"] as? [String] ?? [],
                                            aboutYou: userData["aboutyou"] as? String ?? "",
                                            experience: userData["experience"] as? Int ?? 0,
                                            token: userData["token"] as? String ?? "",
                                            uid: userData["uid"] as? String ?? "",
                                            usertype: userData["usertype"] as? String ?? "",
                                            walletbalance: userData["walletbalance"] as? Int ?? 0)
                    
                    print(objUser.fullname)
                    print(objUser.speciality)
                    LoginDataCache.save(objUser)
                    
                    completion(objUser)
                }
        }
    }
    
    // MARK: - Get Language Data
    func fetchLanguage() {
        db.collection("language").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        Singletion.shared.arrLanguage = snapshot.documents.map { languageData in
                            let objLanguage = LanguageObject(id: languageData["id"] as? String ?? "",
                                                             name: languageData["name"] as? String ?? "")
                            return objLanguage
                        }
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Get Astrology Data
    func fetchAstrology() {
        db.collection("speciality").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        Singletion.shared.arrAstrology = snapshot.documents.map { astrologyData in
                            let objAstrology = AstrologyObject(id: astrologyData["id"] as? String ?? "",
                                                               name: astrologyData["name"] as? String ?? "")
                            return objAstrology
                        }
                    }
                }
            } else {
                // Handle the error
                print(error!.localizedDescription)
            }
        }
    }
}
