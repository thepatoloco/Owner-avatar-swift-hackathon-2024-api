//
//  File.swift
//  
//
//  Created by Patricio Cantu on 16/03/24.
//

import Vapor


struct PageInfo: Codable {
    let pageid: Int
    let title: String
    let extract: String
}

struct QueryPage: Codable {
    let pages: [String: PageInfo]
}

struct WikipediaPageResponse: Content {
    let query: QueryPage
}
