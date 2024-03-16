//
//  File.swift
//  
//
//  Created by Patricio Cantu on 16/03/24.
//

import Vapor

class WikipediaService{
    let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func topicSearch(topic: String) async throws -> WikipediaSearchResponse {
        let wikipediaURL = "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srlimit=7&srsearch=\(topic)"
        
        let response = try await client.get(URI(string: wikipediaURL))
        guard response.status == .ok else {
            throw Abort(.internalServerError)
        }
        
        return try response.content.decode(WikipediaSearchResponse.self)
    }
    
    func pageSearch(pageid: Int) async throws -> WikipediaPageResponse {
        let wikipediaURL = "https://en.wikipedia.org/w/api.php?action=query&format=json&pageids=\(pageid)&prop=extracts&explaintext=True"
        
        let response = try await client.get(URI(string: wikipediaURL))
        guard response.status == .ok else {
            throw Abort(.internalServerError)
        }
        
        return try response.content.decode((WikipediaPageResponse.self))
    }
}
