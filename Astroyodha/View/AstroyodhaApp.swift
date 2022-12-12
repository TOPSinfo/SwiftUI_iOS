//
//  AstroyodhaApp.swift
//  Astroyodha
//
//  Created by Lazy Batman on 30/08/22.
//

import SwiftUI
import Firebase
import IQKeyboardManagerSwift

@main
struct AstroyodhaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            //Fetching common data on initial app launch
            let _ = Singletion.shared.getLanguageData()
            let _ = Singletion.shared.getAstrologyData()
            let _ = Singletion.shared.setDaysData()
            let _ = Singletion.shared.setRepeatData()
            
            // Code to check wether user is already logged in or not. If loggedin then directly redirect to dashboard screen otherwise redirect to Initial screen
            let isLogin : Bool = UserDefaults.standard.bool(forKey: userDefault.isUserLoggedIn)
            if isLogin {
                let objLoginDataCache = LoginDataCache.get()
                
                if objLoginDataCache != nil {
                    if objLoginDataCache?.usertype == UserType.user.rawValue {
                        let _ = configure(isUser: true)
                        UserTabView()
                            .environmentObject(userViewModel)
                    } else {
                        let _ = configure(isUser: false)
                        AstrologerTabView()
                            .environmentObject(userViewModel)
                    }
                } else {
                    NavigationView {
                        InitialView()
                            .environmentObject(userViewModel)
                    }
                }
            } else {
                NavigationView {
                    InitialView()
                        .environmentObject(userViewModel)
                }
            }
        }
    }
}

// MARK: - Functions
extension AstroyodhaApp {
    //Global variable to identify wether user is Astrologer or User
    private func configure(isUser: Bool) {
        if isUser {
            currentUserType = .user
        } else {
            currentUserType = .astrologer
        }
    }
}

// MARK: - APP DELEGATE
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true
        Singletion.shared.customizationSVProgressHUD()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
}
