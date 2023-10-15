//
//  SuperAgentApp.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 04/10/23.
//

import SwiftUI
import SwiftData

@main
struct SuperAgentApp: App {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            MyTabView()
                .environment(\.colorScheme, isDarkMode ? .dark : .light)
        }
    }
}
