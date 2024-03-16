//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor

class OpenAiService{
    let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func simpleQuestion(message: String) async throws -> String {
        let request = OpenAiApiRequest(model: "gpt-3.5-turbo", messages: [
            Message(role: .system, content: "You are a helpfull assistant."),
            Message(role: .user, content: message)
        ])
        let response = try await self.callApi(input: request)
        
        return response.choices[0].message.content
    }
    
    func callApi(input: OpenAiApiRequest) async throws -> OpenAiApiResponse {
        let apiUrl = "https://api.openai.com/v1/chat/completions"
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(openaiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        
        let response = try await client.post(URI(string: apiUrl), headers: headers) { request in
            try request.content.encode(input)
        }
        
        return try response.content.decode(OpenAiApiResponse.self)
    }
}
