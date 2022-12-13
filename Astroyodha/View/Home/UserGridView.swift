//
//  AstrologerListView.swift
//  Astroyodha
//
//  Created by Tops on 06/09/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserGridView: View {
    @State var uiTabarController: UITabBarController?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            AppColor.cF2F2F7
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack {
                        LazyVGrid(columns: viewModel.gridColumns, spacing: 14.66) {
                            if currentUserType == .user {
                                ForEach((viewModel.arrAstrologers),
                                        content: { element in
                                    AstrologerGridItemView(vm: element,
                                                           bookNowTap: {
                                        viewModel.selectAstrologer = element
                                        viewModel.isAddEvent = true
                                    })
                                        .frame(maxWidth: .infinity)
                                })
                            }
                        }
                        .padding(.all, 26.6)
                        
                        NavigationLink(
                            destination: AddEventView(selectedAstrologer: viewModel.selectAstrologer),
                            isActive: $viewModel.isAddEvent) {EmptyView()}
                    }
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.height + 49,
                       alignment: .center)
            }
            .navigationTitle(currentUserType == .user ? "Select Astrologers" : "Caht with Astrologer")
            .navigationBarColor(backgroundColor: currentUserType.themeColor,
                                titleColor: .white)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    },
                           label: {
                        Image("back")
                    })
                }
            }
        }
        .onAppear(perform: {
            if currentUserType == .user {
                viewModel.fetchAllAstrologers()
            }
        })
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
        }
    }
}

struct UserGridView_Previews: PreviewProvider {
    static var previews: some View {
        UserGridView()
    }
}

extension NSNotification {
    static let ImageClick = Notification.Name.init("ImageClick")
}
