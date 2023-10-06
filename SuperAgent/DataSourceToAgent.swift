//
//  AddDataSource.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 05/10/23.
//

import SwiftUI

struct AddDataSourceToAgent: View {
    @AppStorage("userToken") var userToken: String = ""
    @Binding var AgentID: String
    @State private var datasources: [DataSource] = []
    @State private var agentsources: [DataSource] = []
    @State private var selectedDataSource: DataSource? = nil
    @State private var selectedDataSources: [DataSource] = []
    @State private var inputText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Select a data source", text: $inputText)
                    .onTapGesture {
                        self.fetchDataSource()
                    }
                
                List {
                    ForEach(datasources.filter { inputText.isEmpty || $0.name.contains(inputText) && !agentsources.contains($0) }, id: \.id) { datasource in
                        Text(datasource.name)
                            .onTapGesture {
                                selectedDataSources.append(datasource)
                                
                            }
                    }
                }
                
                VStack {
                    ForEach(selectedDataSources, id: \.id) { datasource in
                        HStack {
                            Text(datasource.name)
                            Spacer()
                            Button(action: {
                                selectedDataSources.removeAll { $0.id == datasource.id }
                                
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                        }
                    }
                }.padding(.bottom, 10)
                
                Button(action: {
                    Functions.fetchAgentSources(forAgentID: AgentID, token: userToken) { result in
                    switch result {
                    case .success(let data):
                            print("success")
                        self.agentsources = data
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                }) {
                    Text("debug").padding(.bottom, 25)
                }
                
                Button(action: {
                    allDocs()
                }) {
                    Text("Update Agent").padding(.bottom, 25)
                }
            }
            .onAppear(perform: fetchAll)
        }
    }
    
    private func fetchAll() {
        fetchDataSource()
        fetchAgentSource()
    }
    
    private func fetchDataSource() {
        Functions.fetchDataSources(token: self.userToken) { result in
            switch result {
            case .success(let data):
                self.datasources = data
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    //given Document IDs, add to an AgentID
    func DocToAgent(docID: String) {
        Functions.addDocToAgent(agentId: AgentID, datasourceId: docID, token: userToken) { result in
            switch result {
            case .success:
                print("Successfully added the datasource to the agent.")
            case .failure(let error):
                print("Failed to add the datasource to the agent: \(error)")
            }
        }
    }
    //add all new agents
    func allDocs() {
        selectedDataSources.forEach { dataSource in
            if !agentsources.contains(dataSource) {
                DocToAgent(docID: dataSource.id)
            }
        }
    }
    
    private func fetchAgentSource() {
        Functions.fetchAgentSources(forAgentID: AgentID, token: userToken) { result in
            switch result {
            case .success(let data):
                self.agentsources = data
                    print(agentsources.count)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    
}

