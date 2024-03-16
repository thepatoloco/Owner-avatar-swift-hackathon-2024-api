//
//  File.swift
//  
//
//  Created by Patricio Cantu on 16/03/24.
//

import Vapor


enum Role: String, Codable {
    case system
    case user
    case assistant
}

enum ToolType: String, Codable {
    case function
}


struct FunctionCall: Codable {
    let name: String
    let arguments: String
}

struct Function: Codable {
    let description: String?
    let name: String
    let parameters: [String: JSON]?
    
    init(description: String? = nil, name: String, parameters: [String : JSON]? = nil) {
        self.description = description
        self.name = name
        self.parameters = parameters
    }
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}


struct ToolCall: Codable {
    let id: String
    let type: ToolType
    let function: FunctionCall
}

struct Tool: Codable {
    let type: ToolType
    let function: Function
}


struct Message: Codable {
    let role: Role
    let content: String?
    let tool_calls: [ToolCall]?
    
    init(role: Role, content: String? = nil, tool_calls: [ToolCall]? = nil) {
        self.role = role
        self.content = content
        self.tool_calls = tool_calls
    }
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finish_reason: String
}

