import Vapor

func routes(_ app: Application) throws {
app.get { req async in
        "It works!"
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
    
}
