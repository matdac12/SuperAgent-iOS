//
//  SettingsView.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 05/10/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            TextField("Enter your token", text: $userToken)
                .padding()
                .frame(width: 300) // Set specific frame width
                .border(Color.gray, width: 0.5)
            
            Button(action: {
                // Save the token when the button is pressed
                UserDefaults.standard.set(self.userToken, forKey: "userToken")
                
                // Show 'Key Saved!' alert
                showingAlert = true
            }) {
                Text("Save Token")
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Key Saved!"), message: Text("Your token has been saved."), dismissButton: .default(Text("OK")))
            }
            
            Toggle("Dark Mode", isOn: $isDarkMode)
                .padding()
        }
    }
}


#Preview {
    SettingsView()
}
