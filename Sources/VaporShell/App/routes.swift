import Vapor

func routes(_ app: Application) throws {
    var games : [Board] = []
    
    app.get { req in
        return "It works!"
    }

    app.post("games") { req -> Response in
        let inputDifficulty: String? = req.query["difficulty"]
        guard let inputDifficulty = inputDifficulty,
              inputDifficulty == "easy" || inputDifficulty == "medium" || inputDifficulty == "hard" || inputDifficulty == "hell",
              let setDifficulty = toDifficulty(inputDifficulty:inputDifficulty) else{
            throw Abort(.badRequest, reason:"difficulty specified doesn't match requirements")
        }
        print("[\(games.count)] Difficulty:\(setDifficulty). ", terminator:"")
        games.append(Board(difficulty:setDifficulty))
        let body = "{\"id\":\(games.count-1)}"
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value:"application/json")
        return Response(status:HTTPResponseStatus.created,
                        headers:headers,
                        body:Response.Body(string:body))
    }

    app.get("games", ":id", "cells") { req -> Response in
        let inputFilter : String? = req.query["filter"]
        guard let inputFilter = inputFilter,
              inputFilter == "all" || inputFilter == "repeated" || inputFilter == "incorrect",
              let setFilter = toFilter(inputFilter:inputFilter)
        else {
            throw Abort(.badRequest, reason:"filter specified doesn't match requirements")
        }
        guard let id : Int = req.parameters.get("id"),
              id < games.count && id >= 0 else {
            throw Abort(.badRequest, reason:"id specified doesn't match requirements")
        }
        print("[\(id)] Client is requsting board state.")
        let body = games[id].toJSON(filter:setFilter)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value:"application/json")
        return Response(status:HTTPResponseStatus.ok,
                        headers:headers,
                        body:Response.Body(string:body))
    }

    app.put("games", ":id", "cells", ":boxIndex", ":cellIndex") { req -> Response in
        guard let id : Int = req.parameters.get("id"),
              id < games.count && id >= 0 else {
            throw Abort(.badRequest, reason:"id specified doesn't match requirements")
        }
        guard let boxIndex : Int = req.parameters.get("boxIndex"),
              boxIndex >= 0 && boxIndex < 9 else {
            throw Abort(.badRequest, reason:"boxIndex is out of range 0 ... 8")
        }
        guard let cellIndex : Int = req.parameters.get("cellIndex"),
              cellIndex >= 0 && cellIndex < 9
        else {
            throw Abort(.badRequest, reason:"cellIndex is out of range 0 ... 8")
        }
        var input : Int? = nil
        let pos = BCtoXY(b:boxIndex, c:cellIndex)
        var validMove : Bool = games[id].removeNumber(xPos:pos.0, yPos:pos.1)
        if let inputValue = try req.content.decode(InputValue.self).value {
            guard inputValue >= 1 && inputValue <= 9 else {
                throw Abort(.badRequest, reason: "value is out of range 1 ... 9 or null")
            }
            validMove = games[id].insertNumber(xPos:pos.0, yPos:pos.1, number:inputValue)
            input = inputValue
        }
        if !validMove {print("[\(id)] Invalid move. no change to board state.")}
        else {print("[\(id)] Added \(String(describing:input)) at (\(pos.0),\(pos.1)).")}
        return Response(status:HTTPResponseStatus.noContent)
    }
}
