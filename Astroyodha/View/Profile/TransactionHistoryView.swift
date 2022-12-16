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
            Text(strNoDataFound)
                .font(appFont(type: .poppinsRegular, size: 17))
                .foregroundColor(AppColor.c242424)
            
            appBar(title: strTransactionHistory) {
                self.presentationMode.wrappedValue.dismiss()
            }
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
