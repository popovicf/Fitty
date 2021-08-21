//
//  UserProfileView.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI
import Firebase
import FirebaseStorage
import FBSDKLoginKit

struct UserProfileView: View {
    
    @StateObject var settingsData = SettingsViewModel()
    @State var navBarHidden: Bool = true
    @State var showingLoginView: Bool = false
    @State var selectedTab = "Profile"
    @Environment(\.presentationMode) var presentationMode
    let defaults = UserDefaults.standard
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            
            ZStack{
                
                ProfileView().opacity(selectedTab == "Profile" ? 1 : 0)
                
                InformationView().opacity(selectedTab == "Information" ? 1 : 0)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.top, 50)
            
        }
        .navigationBarHidden(self.navBarHidden)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.navBarHidden = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.navBarHidden = true
        }
        .background(Color(UIColor.systemOrange)
            .ignoresSafeArea(.all, edges: .all))
        .ignoresSafeArea(.all, edges: .top)
        .animation(.linear)
    }
    
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}

