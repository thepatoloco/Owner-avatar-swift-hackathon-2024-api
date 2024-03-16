//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor


struct OpenAiApiRequest: Content {
    let model: String
    let messages: [Message]
    let tools: [Tool]?
    
    enum ToolChoiceOptions: Codable {
        case string(String)
        case dict([String: JSON])
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .dict(let value):
                try container.encode(value)
            }
        }
    }
    var tool_choice: ToolChoiceOptions?
    
    init(model: String = "gpt-3.5-turbo", messages: [Message], tools: [Tool]? = nil, tool_choice: ToolChoiceOptions? = nil) throws {
        self.model = model
        self.messages = messages
        self.tools = tools
        self.tool_choice = tool_choice
    }
}
