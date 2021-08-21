//
//  CustomTabBar.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 80){
            
            TabButton(title: "Profile", selectedTab: $selectedTab)
            TabButton(title: "Information", selectedTab: $selectedTab)
            
        }
        .padding(.horizontal)
        .background(Color(UIColor.white))
        .clipShape(Capsule())
    }
}

struct TabButton: View {
    
    var title: String
    @Binding var selectedTab: String
    
    var body: some View {
        
        Button(action: {selectedTab = title}) {
            
            VStack(spacing: 5) {
                if title == "Profile" {
                    Image(systemName: "person").renderingMode(.template)
                } else {
                    Image(systemName: "info.circle").renderingMode(.template)
                }
                
                Text(title).font(.caption).fontWeight(.bold)
                
            }
            .foregroundColor(selectedTab == title ? Color.orange : .gray)
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }
}

