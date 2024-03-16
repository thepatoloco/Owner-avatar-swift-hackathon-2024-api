import Vapor

func routes(_ app: Application) throws {
app.get { req async in
        "It works!"
    }
    
    app.get("search-fake") { req -> TopicResponse in
        guard let query = req.query[String.self, at: "query"] else {
            throw Abort(.badRequest)
        }
        return TopicResponse(
            title: query,
            topics: [
                Topic(title: "Tema 1", content: "Lore Ipsum", question: TopicQuestion(question_type: QuestionType.winner_selection, content: "¿Quíen ganó la guerra?", correct_options: ["Bando Ganador"], incorrect_options: ["Bando Perdedor", "Empate"], clue: "Esto es una pista")),
                Topic(title: "Tema 2", content: "Lore Ipsum", question: TopicQuestion(question_type: QuestionType.multiple_selection, content: "¿Qué bandos participaron en la guerra?", correct_options: ["Bando 1", "Bando 2"], incorrect_options: ["Mentira 1", "Mentira 2", "Mentira 3"], clue: "Esto es una pista.")),
                Topic(title: "Tema 3", content: "Lore Ipsum", question: TopicQuestion(question_type: QuestionType.single_selection, content: "¿Por qué?", correct_options: ["Correcto"], incorrect_options: ["Incorrecto", "Incorrecto"], clue: "Esto es una pista."))
            ],
            questions: [
                FinalQuestion(content: "¿La respuesta es pizza?", answer: "Pizza", clue: "Si, esa es la respuesta."),
                FinalQuestion(content: "No hay respuesta.", answer: "Si hay respuesta.", clue: "Te esta mintiendo, si la hay.")
            ],
            error: false
        )
    }
    
    app.get("search") { req -> TopicResponse in
        guard let query = req.query[String.self, at: "query"] else {
            throw Abort(.badRequest)
        }
        
        
        let topicai = try TopicAiService(client: req.client)
        let topics = try await topicai.generateTopics(topic: query)
        
        guard topics.count > 0 else {
            return TopicResponse(
                title: "No se encontro una guerra relacionada con su busqueda.",
                topics: [],
                questions: [],
                error: true
            )
        }
        
        return TopicResponse(
            title: query.uppercased(),
            topics: topics,
            questions: [],
            error: false
        )
    }
    
    app.get("is-historic") { req -> Bool in
        guard let topic = req.query[String.self, at: "topic"] else {
            throw Abort(.badRequest)
        }
        
        let topicai = try TopicAiService(client: req.client)
        return try await topicai.isTopicHistorical(topic: topic)
    }
    
    app.get("page-id") { req -> Int in
        guard let topic = req.query[String.self, at: "topic"] else {
            throw Abort(.badRequest)
        }
        
        let topicai = try TopicAiService(client: req.client)
        return try await topicai.getTopicPageId(topic: topic)
    }
    
    
    app.get("multiple-answers") { req -> [String] in
        guard let question = req.query[String.self, at: "question"] else {
            throw Abort(.badRequest)
        }
        
        let topicai = try TopicAiService(client: req.client)
        return try await topicai.multipleAnswerQuestion(messages: [
            Message(role: .user, content: question)
        ])
    }
}
