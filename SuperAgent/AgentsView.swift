//
//  AgentsView.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 04/10/23.
//

import SwiftUI

import SwiftUI

struct AgentsView: View {
    @AppStorage("userToken") var userToken: String = ""
    @State private var agents: [Agent] = []

    var body: some View {
        NavigationStack {
        VStack {
            Button(action: {
                fetchAgents()
            }) {
                Text("Refresh")
            }

             List(agents, id: \.id) { agent in
                 NavigationLink(destination: AgentChat(AgentID: .constant(agent.id), AgentName: .constant(agent.name))) {
                        VStack(alignment: .leading) {
                            Text(agent.name)
                            Text(agent.description)
                            Text(agent.id)
                        }
                    }
                }
            }
            .onAppear(perform: fetchAgents)
        }
    }

    private func fetchAgents() {
        Functions.fetchAgents(token: self.userToken) { result in
            switch result {
            case .success(let data):
                self.agents = data
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
#Preview {
    AgentsView()
}
