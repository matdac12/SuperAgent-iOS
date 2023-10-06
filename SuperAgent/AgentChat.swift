//
//  AgentChat.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 05/10/23.
//

import SwiftUI

struct AgentChat: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("userToken") var userToken: String = ""
    @Binding var AgentID: String
    @Binding var AgentName: String
    @State private var userMessage: String = ""
    @State private var messages: [Message] = [] // To store both user and AI responses
    @State private var isMessageSent: Bool = false
    @State private var isLoading: Bool = false
    
    
    var body: some View {
        VStack {
            
            Text(AgentName)
                .font(.title)
                .bold()
            
            NavigationLink(destination: AddDataSourceToAgent(AgentID: $AgentID)) {
                    Text("Add Data Source")
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
        
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
        }
        
        Spacer()
        
        HStack {
            TextField("Type your message...", text: $userMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .background(Color(.systemGray6))
        
    }
    
    
    func sendMessage() {
        messages.append(Message(content: userMessage, isFromUser: true))
        makePrediction()
        userMessage = ""
        isMessageSent = true
    }
    
    //calls for invokeAgent
    func makePrediction() {
        
        Functions.invokeAgent(agentID: AgentID, token: userToken, input: userMessage, enableStreaming: true, messages: messages, isLoading: $isLoading) { result in
            switch result {
            case .success(let (data, newMessages)):
                // Handle successful response
                print("Data received: \(data)")
                messages = newMessages // Update your messages array with the modified one
                print("Updated Messages: \(messages)")
            case .failure(let error):
                // Handle error
                print("Error occurred: \(error)")
            }
        }
        
    }
    
}

