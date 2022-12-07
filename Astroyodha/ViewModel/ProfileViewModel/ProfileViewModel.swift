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
        ProfileOption.init(name: "Transaction History", image: "imgTransactionHistory"),
        ProfileOption.init(name: "Help / FAQ", image: "imgHelp"),
        ProfileOption.init(name: "Rate app", image: "imgRate"),
        ProfileOption.init(name: "Share app", image: "imgShare"),
        ProfileOption.init(name: "Logout", image: "imgLogout")
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
