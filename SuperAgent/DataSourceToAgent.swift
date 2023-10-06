//
//  AddDataSource.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 05/10/23.
//

import SwiftUI

struct AddDataSourceToAgent: View {
    @AppStorage("userToken") var userToken: String = ""
    @State private var datasources: [DataSource] = []
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
                    ForEach(datasources.filter { inputText.isEmpty || $0.name.contains(inputText) }, id: \.id) { datasource in
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
                }.padding(.bottom, 25)
            }
            .onAppear(perform: fetchDataSource)
        }
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
}


#Preview {
    AddDataSourceToAgent()
}
