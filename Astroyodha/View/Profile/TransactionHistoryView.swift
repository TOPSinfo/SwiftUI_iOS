//
//  TransactionHistoryView.swift
//  Astroyodha
//
//  Created by Tops on 01/11/22.
//

import SwiftUI
import Introspect

struct TransactionHistoryView: View {
    @State var uiTabarController: UITabBarController?
    @Environment(\.presentationMode) var presentationMode
    init() { UITableView.appearance().backgroundColor = UIColor.clear }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            Text("No Data Found")
                .font(appFont(type: .poppinsRegular, size: 17))
                .foregroundColor(AppColor.c242424)
                .navigationBarItems(leading: Text("Transaction History"))
                .font(appFont(type: .poppinsRegular, size: 18))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .navigationBarColor(backgroundColor: currentUserType.themeColor, titleColor: .white)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        backButtonView
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
        }
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
        }
    }
}

struct TransactionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionHistoryView()
    }
}

// MARK: - COMPONENTS
extension TransactionHistoryView {
    private var backButtonView: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "arrow.left")
                .renderingMode(.template)
                .foregroundColor(.white)
        })
    }
}
