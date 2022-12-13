//
//  InitialView.swift
//  Astroyodha
//
//  Created by Tops on 02/12/22.
//

import SwiftUI

struct InitialView: View {
    
    @State var isAstro: Bool = false
    @State var isUser: Bool = false
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 5) {
            Image("hand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.all, 40)
                .scaledToFit()
            
            Group {
                Text(strCreateAccount)
                    .bold()
                    .font(.system(size: 30))
                    .padding()
                
                Text(strAstroYodha)
                    .multilineTextAlignment(.center)
                    .frame(width: 350, height: 50, alignment: .center)
                    .padding(.bottom, 10)
                
                VStack {
                    Button(action: {
                        btnAstrologerClicked()
                    }, label: {
                        Text(strLoginToAstrologer)
                    })
                    .buttonStyle(ButtonAstrologerStyle())
                    .padding(.bottom, 10)
                    NavigationLink(
                        destination: LoginView(),
                        isActive: $isAstro) {EmptyView()}
                }
                VStack {
                    Button(action: {
                        btnUserLoginClicked()
                    }, label: {
                        Text(strLoginToUser)
                    })
                    .buttonStyle(ButtonLoginUserStyle())
                    NavigationLink(
                        destination: LoginView(),
                        isActive: $isUser) {EmptyView()}
                }
            }
            .padding(.horizontal, 60)
        }
        .background(
            Image("backgroud")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center))
    }
    
    // MARK: - BUTTON ACTION
    func btnAstrologerClicked() {
        currentUserType = UserType.astrologer
        isAstro = true
    }
    
    func btnUserLoginClicked() {
        currentUserType = UserType.user
        isUser = true
    }
}

// MARK: - BUTTON STYLE
struct ButtonAstrologerStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(AppColor.c27AAE1)
            .cornerRadius(8)
    }
}
struct ButtonLoginUserStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(AppColor.cF06649)
            .cornerRadius(8)
    }
}

struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
            .environmentObject(UserViewModel())
    }
}
