//
//  HelpAndFaqView.swift
//  Astroyodha
//
//  Created by Tops on 01/11/22.
//

import SwiftUI
import Introspect

struct HelpAndFaqView: View {
    @StateObject private var viewModel = HelpAndFaqViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    init() { UITableView.appearance().backgroundColor = UIColor.clear }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            listView
                .listStyle(.plain)
                .listSectionSeparator(.visible)
                .listSectionSeparatorTint(.red)
                .background(.white)
            
            Text("")
                .navigationBarItems(leading: Text("Help / FAQ"))
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
        }
    }
}

struct HelpAndFaqView_Previews: PreviewProvider {
    static var previews: some View {
        HelpAndFaqView()
    }
}

extension HelpAndFaqView {
    //BACK BUTTON
    private var backButtonView: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "arrow.left")
                .renderingMode(.template)
                .foregroundColor(.white)
        })
    }
    
    //HELP AND FAQ LIST VIEW
    private var listView: some View {
        List(viewModel.arrHelpFaqData) { responseData in
            VStack (alignment: .leading) {
                HStack {
                    Text(responseData.titleText)
                        .font(appFont(type: .poppinsRegular, size: 17))
                        .foregroundColor(responseData.isExpanded ? currentUserType.themeColor : AppColor.c999999)
                        .padding(.vertical, 10)
                    Spacer()
                    
                    Image(responseData.isExpanded ? "imgCollapse": "imgExpand")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundColor(currentUserType.themeColor)
                }
                .onTapGesture {
                    viewModel.collapsAllHelpAndFaqSections()
                    responseData.isExpanded.toggle()
                    viewModel.objectWillChange.send()
                }
                
                if responseData.isExpanded {
                    Text(responseData.titleDescription)
                        .font(appFont(type: .poppinsRegular, size: 16))
                        .foregroundColor(AppColor.c999999)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 15)
                }
            }
        }
    }
}
