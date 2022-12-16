//
//  ProfileViewModel.swift
//  Astroyodha
//
//  Created by Tops on 05/12/22.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var objLoggedInUser: UserModel?
    @Published var arrOptions: [ProfileOption] = [
        ProfileOption.init(name: strTransactionHistory, image: "imgTransactionHistory"),
        ProfileOption.init(name: strHelpFaq, image: "imgHelp"),
        ProfileOption.init(name: strRateApp, image: "imgRate"),
        ProfileOption.init(name: strShareApp, image: "imgShare"),
        ProfileOption.init(name: strLogout, image: "imgLogout")
    ]
    @Published var showEditProfile: Bool = false
    let userViewModel = UserViewModel()

    func fetchCurrentUser() {
        userViewModel.fetchCurrentUserData(completion: { user in
            self.objLoggedInUser = user
            Singletion.shared.objLoggedInUser = user
        })
    }
}
