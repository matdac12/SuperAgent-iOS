//
//  TabView.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 04/10/23.
//

import SwiftUI

struct MyTabView: View {
    var body: some View {
        TabView {
            AgentsView()
                .tabItem {
                    Label("Agents", systemImage: "1.square.fill")
                }
            
            DataSourceView()
                .tabItem {
                    Label("Docs", systemImage: "2.square.fill")
                }
//            
//            ContentView()
//                .tabItem {
//                    Label("Tab 3", systemImage: "3.square.fill")
//                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MyTabView()

}
