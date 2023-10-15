//
//  AgentsView2.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 12/10/23.
//

import Foundation
import SwiftUI
import mySuperAgent

struct AgentsView2: View {
    @AppStorage("userToken") var userToken: String = ""
    @State private var agents: [ProjectAgent] = []
    @State private var isLoading: Bool = true
    @State private var error: Error? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Button(action: {
                    fetchAgents()
                }) {
                    Text("Refresh")
                }
                
                List(agents, id: \.id) { agent in
                    NavigationLink(destination: AgentChat(AgentID: .constant(agent.id), AgentName: .constant(agent.name))) {
                        AgentRow(agent: agent)
                    }
                }
                .onAppear {
                    fetchAgents()
                }
            }
            .padding(.horizontal)
        }
    }
    
    func fetchAgents() {
        MyAPI.fetchAgents(token: self.userToken) { result in
            isLoading = false
            
            switch result {
            case .success(let fetchedAgents):
                self.agents = fetchedAgents.map { ProjectAgent(id: $0.id, name: $0.name, description: $0.description) }
            case .failure(let apiError):
                self.error = apiError
            }
        }
    }
}

struct AgentRow: View {
    var agent: ProjectAgent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(agent.name)
                .font(.headline)
                .padding(.vertical, 2)
            
            Text(agent.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.vertical, 2)
            
            Text(agent.id)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 2)
        }
        .padding(.horizontal)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

