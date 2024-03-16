//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor

enum QuestionType: String, Codable {
    case winner_selection
    case single_selection
    case multiple_selection
}

struct TopicQuestion: Codable {
    let question_type: QuestionType
    let content: String
    let correct_options: [String]
    let incorrect_options: [String]
    let clue: String
    
}

struct FinalQuestion: Codable{
    let content: String
    let answer: String
    let clue: String
}

struct Topic: Codable {
    let title: String
    let content: String
    let question: TopicQuestion
}

struct TopicResponse: Content {
    let title: String
    let topics: [Topic]
    let questions: [FinalQuestion]
    let error: Bool
}
