//
//  SettingsView.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 05/10/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        VStack {
            TextField("Enter your token", text: $userToken)
                .padding()
                .border(Color.gray, width: 0.5)

            Button(action: {
                // Save the token when the button is pressed
                UserDefaults.standard.set(self.userToken, forKey: "userToken")
            }) {
                Text("Save Token")
            }
        }
    }
}

#Preview {
    SettingsView()
}
