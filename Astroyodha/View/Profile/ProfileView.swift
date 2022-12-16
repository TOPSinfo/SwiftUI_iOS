//
//  UserProfileView.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI
import StoreKit
import Firebase
import SDWebImageSwiftUI
import Introspect

// MARK: - View
struct ProfileView: View {
    @State var uiTabarController: UITabBarController?
    @StateObject private var viewModel = ProfileViewModel()
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.bottom)
                
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            profilePhotoView
                                .padding(.vertical, 20)
                            
                            if currentUserType == .astrologer {
                                Singletion.shared.addDivider(color: AppColor.cF3F3F3,
                                                             opacityValue: 1.0,
                                                             height: 14)
                                ratingAndConsultView
                            } else {
                                if !(viewModel.objLoggedInUser?.birthdate.isEmpty ?? "-".isEmpty) {
                                    Singletion.shared.addDivider(color: AppColor.cF3F3F3,
                                                                 opacityValue: 1.0,
                                                                 height: 14)
                                    dateOfBirthView
                                }
                            }
                            
                            List {
                                OptionsFirstSectionView(arrOptions: $viewModel.arrOptions)
                                OptionsSecondSectionView(arrOptions: $viewModel.arrOptions)
                            }
                            .frame(width: geometry.size.width - 5,
                                   height: geometry.size.height - 270,
                                   alignment: .center)
                            
                            .shadow(color: AppColor.c999999.opacity(0.25), radius: 2, y: 1.5)
                            .background(AppColor.cF3F3F3)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationBarHidden(true)
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = false
                uiTabarController = UITabBarController
            }
            .onAppear {
                uiTabarController?.tabBar.isHidden = false
                viewModel.fetchCurrentUser()
            }
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// MARK: - FIRST OPTION VIEW
struct OptionsFirstSectionView: View {
    @Binding var arrOptions: [ProfileOption]
    @State var showTransactionHistoryView: Bool = false
    @State var showHelpAndFaqView: Bool = false
    
    var body: some View {
        Section {
            ForEach(0..<3) { index in
                let option = arrOptions[index]
                
                Button {
                    if arrOptions[index].name == strTransactionHistory {
                        showTransactionHistoryView = true
                    } else if arrOptions[index].name == strHelpFaq {
                        showHelpAndFaqView = true
                    } else if arrOptions[index].name == strRateApp {
                        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                            print("UNABLE TO GET CURRENT SCENE")
                            return
                        }
                        
                        SKStoreReviewController.requestReview(in: currentScene)
                    }
                    print("Tapped at \(index)")
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        optionView(image: option.image, name: option.name)
                            .padding(.vertical, 8)
                            .background(
                                NavigationLink(
                                    destination: TransactionHistoryView(),
                                    isActive: $showTransactionHistoryView) {EmptyView()}
                                    .frame(width: 0, height: 0)
                                    .hidden()
                            )
                            .background(
                                NavigationLink(
                                    destination: HelpAndFaqView(),
                                    isActive: $showHelpAndFaqView) {EmptyView()}
                                    .frame(width: 0, height: 0)
                                    .hidden()
                            )
                    }
                }
                .foregroundColor(.black)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Option View
public func optionView(image: String,
                       name: String) -> some View {
    HStack {
        Image(image)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(currentUserType.themeColor)
            .frame(width: 20, height: 20)
            .padding(.trailing, 10)
        
        Text(name)
            .font(appFont(type: .poppinsRegular, size: 16))
    }
}

// MARK: - SECOND OPTION VIEW
struct OptionsSecondSectionView: View {
    @Binding var arrOptions: [ProfileOption]
    
    @State var showLogin: Bool = false
    @State var isAlertShow: Bool = false
    
    var body: some View {
        Section {
            ForEach(3..<arrOptions.count) { index in
                let option = arrOptions[index]
                
                VStack {
                    Button {
                        if arrOptions[index].name == strShareApp {
                            Singletion.shared.showActivityPopup()
                        } else if arrOptions[index].name == strLogout {
                            isAlertShow.toggle()
                        }
                        print("Tapped at \(index)")
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            optionView(image: option.image, name: option.name)
                                .padding(.vertical, 8)
                                .background(
                                    NavigationLink(
                                        destination: InitialView(),
                                        isActive: $showLogin) { EmptyView() }
                                        .frame(width: 0, height: 0)
                                        .hidden()
                                )
                        }
                    }
                    .foregroundColor(.black)
                }
                .alert(isPresented: $isAlertShow) {
                    showAlert()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Logout Confirmation Alert
    func showAlert() -> Alert {
        return Alert(
            title: Text(""),
            message: Text(strLogoutConfirmation),
            primaryButton: .default(Text("Yes"), action: {
                    removeLocallyStoredDataAndLogoutFromFirebaseAndRedirectToIntroScreen()
                    showLogin = true
            }),
            secondaryButton: .default(Text("No"), action: {
                print("NO")
            })
        )
    }
    
    // MARK: - Logout user. Remove stored data and redirect user to Initial Screen
    func removeLocallyStoredDataAndLogoutFromFirebaseAndRedirectToIntroScreen() {
        LoginDataCache.remove()
        defaults.set(false, forKey: UserDefaultKey.isUserLoggedIn)
        Singletion.shared.clearUserObject()
        
        Singletion.shared.arrLanguage.indices.forEach {
            Singletion.shared.arrLanguage[$0].isSelected = false
        }
        
        Singletion.shared.arrAstrology.indices.forEach {
            Singletion.shared.arrAstrology[$0].isSelected = false
        }
        
        // Logout from Firebase
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UIApplication.shared.currentUIWindow()?.rootViewController = UIHostingController(
                rootView: NavigationView { InitialView() }
            )
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// MARK: - COMPONENTS
extension ProfileView {
    private var placeHolderImageView: some View {
        Image("imgProfile")
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .cornerRadius(60)
    }
    
    // Profile Photo View
    private var profilePhotoView: some View {
        VStack {
            WebImage(url: URL(string: viewModel.objLoggedInUser?.profileimage ?? ""))
                .resizable()
                .placeholder {
                    placeHolderImageView
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: 120, height: 120)
                .cornerRadius(60)
                .overlay(alignment: .bottomTrailing) {
                    editProfilePhotoView
                }
                .padding(.bottom, 5)
            Text(viewModel.objLoggedInUser?.fullname ?? "-")
                .font(appFont(type: .poppinsBold, size: 20))
                .bold()
        }
    }
    
    // Edit Profile Icon View
    private var editProfilePhotoView: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.showEditProfile = true
            } label: {
                Image(currentUserType == .astrologer ? "imgEditAstrologer" : "imgEditUser")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(6)
            }
            NavigationLink(
                destination: EditProfileView(),
                isActive: $viewModel.showEditProfile) { EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
    }
    
    // MARK: - Rating And Consult View
    private var ratingAndConsultView: some View {
        HStack {
            VStack(spacing: 4) {
                Text(String(format: "%.1f", viewModel.objLoggedInUser?.rating ?? 0.0))
                    .font(appFont(type: .poppinsRegular, size: 20))
                Text(strRating)
                    .font(.subheadline)
                    .foregroundColor(AppColor.c999999)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            
            AppColor.cF3F3F3.opacity(1.0).frame(width: 8 / UIScreen.main.scale)
            
            VStack(spacing: 5) {
                Text("0")
                    .font(.title3)
                Text(strConsults)
                    .font(.subheadline)
                    .foregroundColor(AppColor.c999999)
            }
            .frame(maxWidth: .infinity)
        }
        .background(.white)
    }
    
    // Date of Birth
    private var dateOfBirthView: some View {
        VStack(spacing: 4) {
            Image("imgDOB")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(currentUserType.themeColor)
                .frame(width: 16, height: 16)
            Text(strDateOfBirth)
                .font(appFont(type: .poppinsRegular, size: 14))
                .foregroundColor(AppColor.c999999)
            Text(viewModel.objLoggedInUser?.birthdate ?? "-")
                .font(appFont(type: .poppinsRegular, size: 16))
                .foregroundColor(AppColor.c242424)
        }
        .padding(.vertical, 12)
    }
}
