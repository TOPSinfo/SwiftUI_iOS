//
//  Common+Extension.swift
//  Astroyodha
//
//  Created by Tops on 18/11/22.
//

import SwiftUI

// MARK: - NOTIFICATION CENTER EXTENSION
extension NSNotification {
    static let dateSelection = Notification.Name.init("dateSelection")
}

// MARK: - UIAPPLICATION EXTENSION
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        
        return window
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.currentUIWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

// MARK: - VIEW EXTENSION
extension View {
    func navigationBarColor(backgroundColor: Color, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
    
    public func appBar(title: String, backButtonAction: @escaping() -> Void) -> some View {
        Text("")
            .navigationBarItems(leading: Text(title))
            .font(appFont(type: .poppinsRegular, size: 18))
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .navigationBarColor(backgroundColor: currentUserType.themeColor,
                                titleColor: .white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButtonView {
                        backButtonAction()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - ACTION SHEET
    func showActionSheet(actionSheetOption: ActionSheetOption,
                         completion: @escaping (_ isCamera: Bool,
                                                _ showPicker: Bool) -> Void) -> ActionSheet {
        let cameraButton: ActionSheet.Button = .default(Text(strCamera)) {
            completion(true, true)
        }
        
        let gallaryButton: ActionSheet.Button = .default(Text(strGallery)) {
            completion(false, true)
        }
        
        let cancelButton: ActionSheet.Button = .cancel()
        switch actionSheetOption {
        case .camera:
            return ActionSheet(title: Text(""),
                               message: Text("Select Option"),
                               buttons: [cameraButton, gallaryButton, cancelButton])
        case .gallery:
            return ActionSheet(title: Text(""),
                               message: Text("Select Option"),
                               buttons: [cameraButton, gallaryButton, cancelButton])
        }
    }
    
    public func backButtonView(backButtonAction: @escaping() -> Void) -> some View {
        Button(action: {
            backButtonAction()
        }, label: {
            Image(systemName: "arrow.left")
                .renderingMode(.template)
                .foregroundColor(.white)
        })
    }
    
    public func backButtonViewForAuthentication(backButtonAction: @escaping() -> Void) -> some View {
        VStack {
            Button(action: {
                backButtonAction()
            }, label: {
                Image(currentUserType == .user ? "imgBack" : "imgBackAstro")
                    .resizable()
                    .frame(width: 40, height: 40)
            })
                .padding(.top, 15)
        }
        .padding(.trailing, UIScreen.main.bounds.width - 60)
    }
    
    public func commonTitleView(title: String) -> some View {
        Text(title)
            .font(appFont(type: .poppinsRegular, size: 18))
            .font(.title3)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 5)
                            .fill(currentUserType.themeColor))
    }
    
    public func commonButtonTitleView(title: String) -> some View {
        Text(title)
            .font(appFont(type: .poppinsRegular, size: 17))
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
    }
    
    public func commonActionButtonTitleView(title: String) -> some View {
        Text(title)
            .font(appFont(type: .poppinsSemiBold, size: 17))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
    }
}

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor?
    var titleColor: UIColor?
    
    init(backgroundColor: Color, titleColor: UIColor?) {
        self.backgroundColor = UIColor(backgroundColor)
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear // The key is here. Change the actual bar to clear.
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = titleColor
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

// MARK: - DATE EXTENSION
extension Date {
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
    
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    static func getCurrentDate(dateFormate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormate
        return dateFormatter.string(from: Date())
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    
    func dateFormatWithSuffix() -> String {
            return "dd'\(self.daySuffix())' MMMM"
        }

        func daySuffix() -> String {
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components(.day, from: self)
            let dayOfMonth = components.day
            switch dayOfMonth {
            case 1, 21, 31:
                return "st"
            case 2, 22:
                return "nd"
            case 3, 23:
                return "rd"
            default:
                return "th"
            }
        }
}

// MARK: - DOUBLE EXTENSION
extension Double {
    var threeDigits: Double {
        return (self * 1000).rounded(.toNearestOrEven) / 1000
    }
    
    var twoDigits: Double {
        return (self * 100).rounded(.toNearestOrEven) / 100
    }
    
    var oneDigit: Double {
        return (self * 10).rounded(.toNearestOrEven) / 10
    }
}

// MARK: - STRING EXTENSION
extension String {
    func stringAt(_ index: Int) -> String {
        return String(Array(self)[index])
    }
    
    func charAt(_ index: Int) -> Character {
        return Array(self)[index]
    }
}
