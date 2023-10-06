//
//  Functions.swift
//  SuperAgent
//
//  Created by Mattia Da Campo on 04/10/23.
//

import Foundation
import SwiftUI

struct Functions {
    
    var createdAgentID: String = ""
    
   
    //build a function to invoke an agent using a POST API request
    static func invokeAgent(agentID: String, token: String, input: String, enableStreaming: Bool, messages: [Message], isLoading: Binding<Bool>, completion: @escaping (Result<(Data, [Message]), Error>) -> Void) {
        var newMessages = messages
        let urlString = "https://api.beta.superagent.sh/api/v1/agents/\(agentID)/invoke"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
      
        isLoading.wrappedValue = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = ["input": input, "enableStreaming": enableStreaming]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData
            
        } catch {
            completion(.failure(error))
            return
        }

        var fullResponse = ""
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data, var jsonString = String(data: data, encoding: .utf8) {
                jsonString = jsonString.replacingOccurrences(of: "data: ", with: "")
                jsonString = jsonString.replacingOccurrences(of: "\n", with: "")
                fullResponse += jsonString
                print(fullResponse)
                
                // On successful data retrieval
                newMessages.append(Message(content: jsonString, isFromUser: false))
                completion(.success((data, newMessages)))
                isLoading.wrappedValue = false
            }
          
        }
        task.resume()
    }
    
    
    static func fetchAgents(token: String, completion: @escaping (Result<[Agent], Error>) -> Void) {
    let url = URL(string: "https://api.beta.superagent.sh/api/v1/agents")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
        } else if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    
                    var agents: [Agent] = []
                    
                    for item in dataArray {
                        if let id = item["id"] as? String,
                           let name = item["name"] as? String,
                           let description = item["description"] as? String {
                            let agent = Agent(id: id, name: name, description: description)
                            agents.append(agent)
                        }
                    }
                    
                    completion(.success(agents))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    task.resume()
}
    

    static func fetchDataSources(token: String, completion: @escaping (Result<[DataSource], Error>) -> Void) {
        let url = URL(string: "https://api.beta.superagent.sh/api/v1/datasources")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]] {
                        
                        var datasources: [DataSource] = []
                        
                        for item in dataArray {
                            if let id = item["id"] as? String,
                               let name = item["name"] as? String,
                               let description = item["description"] as? String {
                                let datasource = DataSource(id: id, name: name, description: description)
                                datasources.append(datasource)
                            }
                        }
                        
                        completion(.success(datasources))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }


    //create a LLM, associate the LLMID
    static func createLLM(OpenAIKey: String, SuperAgentKey: String) {
        createMyLLM(provider: "OPENAI", apiKey: OpenAIKey, token: SuperAgentKey) { result in
            switch result {
            case .success:
                print("Successfully created LLM.")
            case .failure(let error):
                print("Failed to create LLM: \(error)")
            }
        }
    }
    static func createMyLLM(provider: String, apiKey: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Create URL
        guard let url = URL(string: "https://api.beta.superagent.sh/api/v1/llms") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create JSON payload
        let payload: [String: Any] = [
            "provider": provider,
            "apiKey": apiKey
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        // Perform API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])))
                return
            }
            
            completion(.success(()))
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataDict = json["data"] as? [String: Any],
                       let LLMID = dataDict["id"] as? String {
//                        myLLMID = LLMID
//                        print(myLLMID)
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        
        
        
        task.resume()
    }
    
    //func to create a new agent, if agent already created, it just retrieves the agent ID.
    static func createAgent() {
        //create LLM
        createLLM(OpenAIKey: "", SuperAgentKey: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            createNewAgent(name: "", llmModel: "GPT_4_0613", description: "Basketball Agent for user ", prompt: "", token: "")
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                LLMtoAgent()
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    addTool()
//                }
//            }
            
        }
        
    }
    //API post request for creating agent, if called, uploads agent ID into firebase.
    static func createNewAgent(name: String, llmModel: String, description: String, prompt: String, token: String) {
        let url = URL(string: "https://api.beta.superagent.sh/api/v1/agents")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "llmModel": llmModel,
            "description": description,
            "prompt": prompt
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print("Error: \(error)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(Response.self, from: data)
                        let createdAgentID = response.data.id
                        print("Agent Added Succesfully")
                        print("Created Agent ID: \(createdAgentID)")
                        
                        
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            task.resume()
    }
   
    //doc id to agent ID
    static func addDocToAgent(agentId: String, datasourceId: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Create URL
        guard let url = URL(string: "https://api.beta.superagent.sh/api/v1/agents/\(agentId)/datasources") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        // Create Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Create JSON payload
        let payload: [String: Any] = [
            "datasourceId": datasourceId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        // Perform API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])))
                return
            }

            completion(.success(()))
        }

        task.resume()
    }
    
    //retrieve docID associated with agentID
    static func fetchAgentSources(forAgentID agentID: String, token: String, completion: @escaping (Result<[DataSource], Error>) -> Void) {
        // Create URL
        guard let url = URL(string: "https://api.beta.superagent.sh/api/v1/agents/\(agentID)/datasources") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create Request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Perform API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])))
                return
            }
            
            if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let dataArray = json["data"] as? [[String: Any]] {
                                                                
                                var datasources: [DataSource] = []
                                
                                for item in dataArray {
                                    if let id = item["datasourceId"] as? String,
                                       let name = item["name"] as? String,
                                       let description = item["description"] as? String {
                                        let datasource = DataSource(id: id, name: name, description: description)
                                        
                                        datasources.append(datasource)
                                
                                    }
                                }
                                
                                completion(.success(datasources))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
    }
    
    
}


struct Response: Codable {
    let data: AgentData
    let success: Bool
}

struct AgentData: Codable {
    let id: String
}

struct AgentResponse: Codable {
    let data: [Agent]
}

struct Agent: Codable {
    let id: String
    let name: String
    let description: String
}

struct DataSource: Codable, Hashable, Equatable {
    let id: String
    let name: String
    let description: String
}

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isFromUser: Bool
}

struct ChatBubble: View {
    @State private var displayText: String = ""
    let message: Message
    let typingSpeed = 0.03 // change speed to your liking
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                HStack() {
                    Text(message.content)
                        .font(.callout)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    avatar(initials: "C")
                    
                }
            } else {
                HStack() {
                    avatar(initials: "🥷")
                    Text(displayText)
                        .font(.callout)
                        .padding(10)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .onAppear(perform: typeText)
    }
    
    private func typeText() {
        let _ = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if displayText.count < message.content.count {
                let index = message.content.index(message.content.startIndex, offsetBy: displayText.count)
                displayText.append(message.content[index])
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func avatar(initials: String) -> some View {
           Text(initials)
               .fontWeight(.bold)
               .foregroundColor(.white)
               .frame(width: 35, height: 35)
               .background(Color.gray)
               .clipShape(Circle())
       }
}
