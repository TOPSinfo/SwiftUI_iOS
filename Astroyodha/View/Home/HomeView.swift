//
//  HomeView.swift
//  Astroyodha
//
//  Created by Tops on 05/09/22.
//

import SwiftUI
import Introspect
import SDWebImageSwiftUI

// MARK: - View
struct HomeView: View {
    @State var uiTabarController: UITabBarController?
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                backgroundView
                    .ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            headerView(notificationTap: {
                            }, objLoggedInUser: vm.objLoggedInUser)
                            Spacer()
                                .frame(height: 29)
                            homeGridView(astrologerGridVMs: Array(vm.arrAstrologers.prefix(4)))
                            Spacer()
                                .frame(height: 26)
                            homeBannerView(bannerVM: vm.bannerVM,
                                           bookAppointmentTap: {
                            })
                            
                            if currentUserType == .user {
                                Spacer()
                                    .frame(height: 27.3)
                                UserHomeUpcomingView(vms: vm.upcomingVMs)
                            }
                            
                            Spacer()
                                .frame(height: 70)
                        }
                        .padding(.horizontal, 26)
                    }
                    .frame(width: geometry.size.width,
                           height: geometry.size.height + 49,
                           alignment: .center)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = false
                uiTabarController = UITabBarController
            }
            .onAppear {
                uiTabarController?.tabBar.isHidden = false
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

// MARK: - COMPONENTS
extension HomeView {
    private var backgroundView: some View {
        VStack {
            Image((currentUserType == .user) ? "userHomeBack" : "astrologerHomeBack")
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
    
    // MARK: - Welcome View
    private func headerView(notificationTap: VoidCallBack, objLoggedInUser: UserModel?) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Namaste, \(objLoggedInUser?.fullname ?? "") 🖐")
                    .font(appFont(type: .poppinsRegular, size: 12))
                    .foregroundColor(AppColor.c242424)
                Spacer()
            }.padding(.top, 10)
            
            Text("Welcome!!")
                .font(appFont(type: .poppinsBold, size: 26))
                .foregroundColor(AppColor.c242424)
            
            Text(Singletion.shared.convertToday(outputFormatter: "dd MMMM yyyy"))
                .font(appFont(type: .poppinsRegular, size: 12))
                .foregroundColor(AppColor.c242424)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Grid View
    private func homeGridView(astrologerGridVMs: [AstrologerGridItmeVM]?) -> some View {
        VStack(spacing: 13) {
            HStack(spacing: 0) {
                Text(currentUserType == .user ? "Astrologers" : "Users")
                    .font(appFont(type: .poppinsMedium, size: 18))
                    .foregroundColor(AppColor.c242424)
                Spacer()
                NavigationLink(destination: {
                    UserGridView()
                },
                               label: {
                    if (astrologerGridVMs ?? []).count > 4 {
                        Text("View All")
                            .font(appFont(type: .poppinsRegular, size: 12))
                            .foregroundColor(AppColor.c242424)
                    }
                })
            }
            LazyVGrid(columns: vm.gridColumns,
                      spacing: 14,
                      content: {
                if currentUserType == .user,
                   let vms = astrologerGridVMs {
                    ForEach(vms) { element in
                        AstrologerGridItemView(vm: element, bookNowTap: {
                            vm.selectAstrologer = element
                            vm.isAddEvent = true
                        })
                    }
                } else {
                    Text("Something went wrong..")
                }
            })
            NavigationLink(
                destination: AddEventView(selectedAstrologer: vm.selectAstrologer),
                isActive: $vm.isAddEvent) {EmptyView()}
        }
    }
    
    // MARK: - Banner View
    private func homeBannerView(bannerVM: HomeBannerVM, bookAppointmentTap: VoidCallBack) -> some View {
        ZStack(alignment: .bottom) {
            // Orange view
            RoundedRectangle(cornerRadius: 6.6)
                .fill(bannerVM.backColor)
                .frame(height: 129.3)
            
            GeometryReader { geometry in
                HStack {
                    // Information
                    VStack(alignment: .leading, spacing: 6.6) {
                        Spacer()
                            .frame(minHeight: 31, maxHeight: 57.3)
                        Text(bannerVM.title)
                            .font(appFont(type: .poppinsRegular, size: 12))
                            .foregroundColor(AppColor.white)
                            .lineLimit(1)
                        Text(bannerVM.description)
                            .font(appFont(type: .poppinsBold, size: 12))
                            .foregroundColor(AppColor.white)
                            .lineLimit(2)
                        Button(action: {
                            vm.isBookAppointmentTapped = true
                        },
                               label: {
                            Text("Book Appointment")
                                .font(appFont(type: .poppinsRegular, size: 9))
                                .foregroundColor(bannerVM.backColor)
                                .frame(width: 106.6, height: 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 6.6)
                                        .fill(AppColor.white)
                                )
                        })
                        
                        NavigationLink(
                            destination: UserGridView(),
                            isActive: $vm.isBookAppointmentTapped) {EmptyView()}
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 13.3,
                                        leading: 13.3,
                                        bottom: 16,
                                        trailing: 0))
                    
                    // Image
                    Image(bannerVM.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.4,
                               height: 190.3)
                        .clipped()
                }
            }
        }
        .frame(height: 173.3)
    }
    
    // MARK: - Upcoming Content View
    private func UserHomeUpcomingView(vms: [HomeUserUpcomingItemVM]) -> some View {
        VStack(alignment: .leading, spacing: 13.3) {
            Text("Upcoming")
                .font(appFont(type: .poppinsMedium, size: 18))
                .foregroundColor(AppColor.c242424)
                .multilineTextAlignment(.leading)
            
            LazyVGrid(columns: vm.columns,
                      content: {
                ForEach(vms,
                        content: { vm in
                    userHomeUpcomingItemView(vm: vm)
                })
            })
        }
    }
    
    // MARK: - Upcoming Item View
    private func userHomeUpcomingItemView(vm: HomeUserUpcomingItemVM) -> some View {
        NavigationLink(destination: {
            UpcomingView()
        },
                       label: {
            VStack(spacing: 11.3) {
                Image(vm.imageName)
                Text(vm.title)
                    .font(appFont(type: .poppinsBold, size: 8))
                    .foregroundColor(vm.color)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 83.3)
            .background(
                RoundedRectangle(cornerRadius: 6.6)
                    .strokeBorder(vm.color, lineWidth: 1)
            )
        })
    }
}

// MARK: - Astrologer Grid Item
struct AstrologerGridItemView: View {
    
    let vm: AstrologerGridItmeVM
    let bookNowTap: VoidCallBack
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {}) {
                VStack {
                    // Image
                    WebImage(url: URL(string: vm.imageAstro))
                        .resizable()
                        .placeholder {
                            Image("imgPlaceHolder1")
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 6.6))
                                .cornerRadius(10)
                        }
                        .indicator(.activity)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 6.6))
                        .frame(width: ((UIScreen.main.bounds.width / 2) - 50),
                               height: ((UIScreen.main.bounds.width / 2) - 110))
                        .cornerRadius(10)
                    
                    Spacer()
                        .frame(height: 6.6)
                    
                    // Name & rating
                    HStack(alignment: .center, spacing: 0) {
                        Text(vm.name)
                            .font(appFont(type: .poppinsMedium, size: 12))
                            .foregroundColor(AppColor.c333333)
                            .lineLimit(1)
                        Spacer()
                            .frame(width: 3.3)
                        Image("verified")
                            .scaledToFit()
                        Spacer()
                        Image("rating")
                            .scaledToFit()
                        Spacer()
                            .frame(width: 3.3)
                        Text(String(format: "%.1f", vm.ratting))
                            .font(appFont(type: .poppinsRegular, size: 9))
                            .foregroundColor(AppColor.c999999)
                    }
                    
                }
            }
            Spacer()
                .frame(height: 3.3)
            
            // Address
            Text(Singletion.shared.getAstrologerSpecialityIntoString(speciality: vm.speciality))
                .font(appFont(type: .poppinsRegular, size: 9))
                .foregroundColor(AppColor.c999999)
                .lineLimit(1)
            
            Spacer()
                .frame(height: 6.6)
            
            // Book button
            Button(action: bookNowTap,
                   label: {
                Text("Book Now")
                    .font(appFont(type: .poppinsRegular, size: 12))
                    .foregroundColor(AppColor.cF06649)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 3.3)
                            .strokeBorder(AppColor.cF06649, lineWidth: 1)
                    )
            })
                .frame(height: 23.3)
            
        }.padding(.all, 10)
            .background(
                RoundedRectangle(cornerRadius: 6.6)
                    .strokeBorder(AppColor.cCCCCCC, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 6.6)
                                    .fill(AppColor.cFFFFFF))
            )
        
    }
}
