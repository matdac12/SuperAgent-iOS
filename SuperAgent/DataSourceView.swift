//
//  DataSourceView.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 05/10/23.
//

import SwiftUI

struct DataSourceView: View {
    @AppStorage("userToken") var userToken: String = ""
    @State private var datasources: [DataSource] = []

    var body: some View {
        NavigationStack {
        VStack {
            Button(action: {
                fetchDataSource()
            }) {
                Text("Refresh")
            }

             List(datasources, id: \.id) { datasource in
                    NavigationLink(destination: EmptyView()) {
                        VStack(alignment: .leading) {
                            Text(datasource.name)
                            Text(datasource.description)
                            Text(datasource.id)
                        }
                    }
                }
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
    DataSourceView()
}
