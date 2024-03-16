//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor

enum Role: String, Codable {
    case system
    case user
    case assistant
}

struct Message: Codable {
    let role: Role
    let content: String
}

struct OpenAiApiRequest: Content {
    let model: String
    let messages: [Message]
}
