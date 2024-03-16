//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor


struct Choice: Codable {
    let index: Int
    let message: Message
    let finish_reason: String
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct OpenAiApiResponse: Content {
    let model: String
    let choices: [Choice]
    let usage: Usage
}
