//
//  CustomTabBar.swift
//  TriLive
//
//  Created by Anthony Qin on 6/25/25.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    
    let tabs: [TabBarItem]
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
            }
        }
    }
   
}

#Preview{
    //CustomTabBar()
}

extension CustomTabBar {
    
    private func tabView(tab: TabBarItem) -> some View {
        VStack{
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundColor(tab.color)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(tab.color.opacity(0.2))
        .cornerRadius(10)
    }
    
}

struct TabBarItem: Hashable {
    let iconName: String
    let title: String
    let color: Color
}
