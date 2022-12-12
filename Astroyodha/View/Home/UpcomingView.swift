//
//  UpcomingView.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI
import Introspect

// MARK: - View
struct UpcomingView: View {
    @State var uiTabarController: UITabBarController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        contentView
            .padding(.horizontal, 26.6)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = true
                uiTabarController = UITabBarController
            }
            .onAppear {
                uiTabarController?.tabBar.isHidden = true
            }
    }
}

// MARK: - Preview
struct UpcomingView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingView()
    }
}

extension UpcomingView {
    // MARK: - Back Button View
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        },
               label: {
            Image("roundBack")
        })
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            Image("upcomingImage")
            
            Spacer()
                .frame(height: 33.33)
            
            Text("Launching soon")
                .font(appFont(type: .poppinsBold, size: 18))
                .foregroundColor(AppColor.c242424)
            
            Spacer()
                .frame(height: 3.3)
            
            // Description
            Text("Our engineers are polishing the app to make sure you will have a delightful experience...Hang in there!")
                .font(appFont(type: .poppinsRegular, size: 12))
                .foregroundColor(AppColor.c999999)
                .multilineTextAlignment(.center)
        }
    }
}
