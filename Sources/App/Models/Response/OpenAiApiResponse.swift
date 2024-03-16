//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor


struct OpenAiApiResponse: Content {
    let model: String
    let choices: [Choice]
    let usage: Usage
}
