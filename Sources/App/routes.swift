import Vapor

func routes(_ app: Application) throws {
    var games : [Board] = []
    
    app.get { req in
        return "It works!"
    }

    app.post("games") { req -> Response in
        games.append(Board(difficulty:Difficulty.medium))
        let body = "{\"boardID\":\(games.count-1)}"
        return Response(status:HTTPResponseStatus.created,
                        headers:HTTPHeaders(),
                        body:Response.Body(string:body))
    }

    app.get("games", ":id", "cells") { req -> Response in
        let body = games[Int(req.parameters.get("id")!)!].toJSON()
        return Response(status:HTTPResponseStatus.ok,
                        headers:HTTPHeaders(),
                        body:Response.Body(string:body))
    }

    app.put("games", ":id", "cells", ":boxIndex", ":cellIndex") { req -> Response in
        guard let id : Int = req.parameters.get("id"),
              let boxIndex : Int = req.parameters.get("boxIndex"),
              let cellIndex : Int = req.parameters.get("cellIndex")
        else {
            fatalError("theres probably a better way to handle this.")
        }
        let pos = BCtoXY(b:boxIndex, c:cellIndex)
        var validMove : Bool = games[id].removeNumber(xPos:pos.0, yPos:pos.1)
        (try req.content.decode(InputValue.self).inputValue)
        if let inputValue = try req.content.decode(InputValue.self).inputValue {
            validMove = games[id].insertNumber(xPos:pos.0, yPos:pos.1, number:inputValue)
        }
        if !validMove {print("Invalid move. no change to board state.")}
        return Response(status:HTTPResponseStatus.noContent,
                        headers:HTTPHeaders())
    }
}
