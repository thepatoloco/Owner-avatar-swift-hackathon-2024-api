//
//  File.swift
//  
//
//  Created by Patricio Cantu on 15/03/24.
//

import Vapor

class TopicAiService {
    let client: Client
    let openai: OpenAiService
    let wikipedia: WikipediaService
    
    let tools: [String: Tool] = [
        "yes-no-answer": Tool(
            type: .function,
            function: Function(
                description: "Answer a yes or no question with a boolean",
                name: "yes-no-answer",
                parameters: [
                    "type": JSON(value: "object"),
                    "properties": JSON(value: [
                        "answer": JSON(value: [
                            "type": JSON(value: "boolean"),
                            "description": JSON(value: "true if the answer is yes, false is the answer is no, false if the answer isn't a yes or no question")
                        ])
                    ]),
                    "required": JSON(value: ["answer"])
                ]
            )
        ),
        "single-answer-string": Tool(
            type: .function,
            function: Function(
                description: "Give a single answer to the question",
                name: "single-answer",
                parameters: [
                    "type": JSON(value: "object"),
                    "properties": JSON(value: [
                        "answer": JSON(value: [
                            "type": JSON(value: "string"),
                            "description": JSON(value: "simple answer of the question")
                        ])
                    ]),
                    "required": JSON(value: ["answer"])
                ]
            )
        ),
        "single-answer-int": Tool(
            type: .function,
            function: Function(
                description: "Give a single answer to the question",
                name: "single-answer",
                parameters: [
                    "type": JSON(value: "object"),
                    "properties": JSON(value: [
                        "answer": JSON(value: [
                            "type": JSON(value: "integer"),
                            "description": JSON(value: "answer of the question")
                        ])
                    ]),
                    "required": JSON(value: ["answer"])
                ]
            )
        ),
        "multiple-answers": Tool(
            type: .function,
            function: Function(
                description: "Give an array of answers to the question",
                name: "multiple-answers",
                parameters: [
                    "type": JSON(value: "object"),
                    "properties": JSON(value: [
                        "answer": JSON(value: [
                            "type": JSON(value: "array"),
                            "items": JSON(value: [
                                "type": JSON(value: "string")
                            ]),
                            "description": JSON(value: "answers of the question")
                        ])
                    ]),
                    "required": JSON(value: ["answer"])
                ]
            )
        )
    ]
    
    init(client: Client) throws {
        self.client = client
        self.openai = OpenAiService(client: self.client)
        self.wikipedia = WikipediaService(client: self.client)
    }
    
    
    func generateTopics(topic: String) async throws -> [Topic] {
        let isHistorical = try await self.isTopicHistorical(topic: topic)
        if (!isHistorical) {
            return []
        }
        
        let pageid = try await self.getTopicPageId(topic: topic)
        let pageContent = try await self.wikipedia.pageSearch(pageid: pageid)
        let pageInfo = pageContent.query.pages[String(pageid)] ?? nil
        if (pageInfo == nil) {
            return []
        }
        
        let topic_1 = try await self.createTopic1(topic: topic, pageInfo: pageInfo!)
        let war_sides = topic_1.question.correct_options
        
        return [topic_1]
    }
    
    func createTopic1(topic: String, pageInfo: PageInfo) async throws -> Topic {
        let topic_1_content = try await self.openai.simpleQuestion(messages: [
            Message(role: .system, content: String(describing: pageInfo)),
            Message(role: .system, content: "En base a lo anterior, explica brevemente en no mas de un parrafo de 200 carácteres los principales bandos que hubo en la guerra '\(topic)'.")
        ])
        let war_sides = try await self.multipleAnswerQuestion(messages: [
            Message(role: .system, content: String(describing: pageInfo)),
            Message(role: .system, content: "En base a lo anterior escribe los principales bandos que hubo en la guerra '\(topic)'.")
        ])
        let incorrect_options = try await self.multipleAnswerQuestion(messages: [
            Message(role: .system, content: String(describing: pageInfo)),
            Message(role: .system, content: "Para la pregunta '¿Cuáles fueron los bandos que participaron en la guerra?' las respuestas correctas son: \(String(describing: war_sides)).\nCrea UNICAMENTE respuestas INCORRECTAS hasta que haya un total de 4 respuestas (entre correctas e incorrectas).")
        ])
        let clue = try await self.openai.simpleQuestion(messages: [
            Message(role: .system, content: String(describing: pageInfo)),
            Message(role: .system, content: "Para la pregunta '¿Cuáles fueron los bandos que participaron en la guerra?' las respuestas correctas son: \(String(describing: war_sides)).Y las respuestas incorrectas son: \(String(describing: incorrect_options)).\nCrea una oración corta que sea una pista para ayudar a los lectores a descubrir las respuestas correctas.")
        ])
        let topic_1 = Topic(
            title: "Los bandos de la guerra.",
            content: topic_1_content,
            question: TopicQuestion(
                question_type: .multiple_selection,
                content: "¿Cuáles fueron los bandos que participaron en la guerra?",
                correct_options: war_sides,
                incorrect_options: incorrect_options,
                clue: clue
            )
        )
        
        return topic_1
    }
    
    
    func isTopicHistorical(topic: String) async throws -> Bool {
        let wikiData = try await self.wikipedia.topicSearch(topic: topic)
        if wikiData.query.search.count <= 0 {
            return false
        }
        
        let isHistorical = try await self.booleanQuestion(messages: [
            Message(role: .system, content: String(describing: wikiData)),
            Message(role: .system, content: "Basado en la información anterior, ¿crees qué el tema '\(topic)' esta relacionado con alguna guerra historica verdadera específica? (si el usuario simplemente escribe 'guerra' regresa falso)")
        ])
        
        return isHistorical
    }
    
    func getTopicPageId(topic: String) async throws -> Int {
        let wikiData = try await self.wikipedia.topicSearch(topic: topic)
        
        let pageId = try await self.singleIntegerQuestion(messages: [
            Message(role: .system, content: String(describing: wikiData)),
            Message(role: .system, content: "Basado en la información anterior, escribe el pageid del tema que describe mejor la guerra historica de '\(topic)'.")
        ])
        
        return pageId
    }
    
    
    func booleanQuestion(messages: [Message]) async throws -> Bool {
        let response = try await self.openai.callApi(input: OpenAiApiRequest(
            messages: messages,
            tools: [
                self.tools["yes-no-answer"]!
            ],
            tool_choice: .dict([
                "type": JSON(value: "function"),
                "function": JSON(value: [
                    "name": JSON(value: "yes-no-answer")
                ])
            ])
        ))
        
        let jsonString = response.choices[0].message.tool_calls![0].function.arguments
        let jsonData = jsonString.data(using: .utf8)
        let json = try JSONSerialization.jsonObject(with: (jsonData ?? "".data(using: .utf8))!, options: []) as? [String: Any]
        
        return json?["answer"] as? Bool ?? false
    }
    
    func singleIntegerQuestion(messages: [Message]) async throws -> Int {
        let response = try await self.openai.callApi(input: OpenAiApiRequest(
            messages: messages,
            tools: [
                self.tools["single-answer-int"]!
            ],
            tool_choice: .dict([
                "type": JSON(value: "function"),
                "function": JSON(value: [
                    "name": JSON(value: "single-answer")
                ])
            ])
        ))
        
        let jsonString = response.choices[0].message.tool_calls![0].function.arguments
        let jsonData = jsonString.data(using: .utf8)
        let json = try JSONSerialization.jsonObject(with: (jsonData ?? "".data(using: .utf8))!, options: []) as? [String: Any]
        
        return json?["answer"] as? Int ?? 0
    }
    
    func multipleAnswerQuestion(messages: [Message]) async throws -> [String] {
        let response = try await self.openai.callApi(input: OpenAiApiRequest(
            messages: messages,
            tools: [
                self.tools["multiple-answers"]!
            ],
            tool_choice: .dict([
                "type": JSON(value: "function"),
                "function": JSON(value: [
                    "name": JSON(value: "multiple-answers")
                ])
            ])
        ))
        
        let jsonString = response.choices[0].message.tool_calls![0].function.arguments
        let jsonData = jsonString.data(using: .utf8)
        let json = try JSONSerialization.jsonObject(with: (jsonData ?? "".data(using: .utf8))!, options: []) as? [String: Any]
        
        return json?["answer"] as? [String] ?? []
    }
}
