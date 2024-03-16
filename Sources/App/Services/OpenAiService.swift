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
    
    func simpleQuestion(messages: [Message]) async throws -> String {
        let request = try OpenAiApiRequest(messages: messages)
        let response = try await self.callApi(input: request)
        
        return response.choices[0].message.content ?? "No response"
    }
    
    func callApi(input: OpenAiApiRequest) async throws -> OpenAiApiResponse {
        let apiUrl = "https://api.openai.com/v1/chat/completions"
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(openaiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        
        print("OpenAI Request: \(String(describing: String(data: try JSONEncoder().encode(input), encoding: .utf8)))")
        
        let response = try await client.post(URI(string: apiUrl), headers: headers) { request in
            try request.content.encode(input)
        }
        print("OpenAI Response: \(response)")
        
        return try response.content.decode(OpenAiApiResponse.self)
    }
}
