import Vapor

func routes(_ app: Application) throws {
    var games : [Board] = []
    
    app.get { req in
        return "It works!"
    }

    app.post("games") { req -> Response in
        games.append(Board(difficulty:Difficulty.medium))
        let body = "{\"boardID\":\(games.count-1)}"
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value:"application/json")
        return Response(status:HTTPResponseStatus.created,
                        headers:headers,
                        body:Response.Body(string:body))
    }

    app.get("games", ":id", "cells") { req -> Response in
        // there should probably be a handler here to check the game id but we didnt do that our bad
        let body = games[Int(req.parameters.get("id")!)!].toJSON()
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value:"application/json")
        return Response(status:HTTPResponseStatus.ok,
                        headers:headers,
                        body:Response.Body(string:body))
    }

    app.put("games", ":id", "cells", ":boxIndex", ":cellIndex") { req -> Response in
        guard let id : Int = req.parameters.get("id"),
              let boxIndex : Int = req.parameters.get("boxIndex"),
              let cellIndex : Int = req.parameters.get("cellIndex")
        else {
            return Response(status:HTTPResponseStatus.badRequest)
        }
        let pos = BCtoXY(b:boxIndex, c:cellIndex)
        var validMove : Bool = games[id].removeNumber(xPos:pos.0, yPos:pos.1)
        if let inputValue = try req.content.decode(InputValue.self).inputValue {
            validMove = games[id].insertNumber(xPos:pos.0, yPos:pos.1, number:inputValue)
        }
        if !validMove {print("Invalid move. no change to board state.")}
        return Response(status:HTTPResponseStatus.noContent)
    }
}
