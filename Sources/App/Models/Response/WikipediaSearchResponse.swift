//
//  File.swift
//
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor


struct SearchResult: Codable {
    let ns: Int
    let title: String
    let pageid: Int
    let size: Int
    let wordcount: Int
    let snippet: String
    let timestamp: String
}

struct QuerySearch: Codable {
    let search: [SearchResult]
}

struct WikipediaSearchResponse: Content {
    let query: QuerySearch
}
