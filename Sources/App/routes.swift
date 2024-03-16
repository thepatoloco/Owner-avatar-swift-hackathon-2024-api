import Vapor

func routes(_ app: Application) throws {
app.get { req async in
        "It works!"
    }
    
    app.get("wiki") { req -> WikipediaSearchResponse in
        guard let query = req.query[String.self, at: "query"] else {
            throw Abort(.badRequest)
        }
        
        let wikipediaURL = "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srlimit=7&srsearch=\(query)"
        
        let response = try await req.client.get(URI(string: wikipediaURL))
        guard response.status == .ok else {
            throw Abort(.internalServerError)
        }
        
        return try response.content.decode(WikipediaSearchResponse.self)
    }
    
    app.get("openai") { req -> String in
        guard let message = req.query[String.self, at: "message"] else {
            throw Abort(.badRequest)
        }
        let openai = OpenAiService(client: req.client)
        return try await openai.simpleQuestion(message: message)
    }
    
    app.get("search-fake") { req -> TopicResponse in
        guard let query = req.query[String.self, at: "query"] else {
            throw Abort(.badRequest)
        }
        return TopicResponse(
            title: query,
            topics: [
                Topic(title: "Tema 1", content: "Lore Ipsum", question: TopicQuestion(question_type: QuestionType.winner_selection, content: "¿Quíen ganó la guerra?", correct_options: ["Bando Ganador"], incorrect_optinos: ["Bando Perdedor", "Empate"], clue: "Esto es una pista")),
                Topic(title: "Tema 2", content: "Lore Ipsum", question: TopicQuestion(question_type: QuestionType.multiple_selection, content: "¿Qué bandos participaron en la guerra?", correct_options: ["Bando 1", "Bando 2"], incorrect_optinos: ["Mentira 1", "Mentira 2", "Mentira 3"], clue: "Esto es una pista.")),
                Topic(title: "Tema 3", content: "Lore Ipsum", question: TopicQuestion(question_type: QuestionType.single_selection, content: "¿Por qué?", correct_options: ["Correcto"], incorrect_optinos: ["Incorrecto", "Incorrecto"], clue: "Esto es una pista."))
            ],
            questions: [
                FinalQuestion(content: "¿La respuesta es pizza?", answer: "Pizza", clue: "Si, esa es la respuesta."),
                FinalQuestion(content: "No hay respuesta.", answer: "Si hay respuesta.", clue: "Te esta mintiendo, si la hay.")
            ]
        )
    }
    
}
