import Vapor

func routes(_ app: Application) throws {
    var games : [Board] = []
    
    app.get { req in
        return "It works!"
    }

    app.post("games") { req -> Response in
        var setDifficulty = Difficulty.medium
        do{
            if let inputDifficulty = try req.content.decode(InputDifficulty.self).inputDifficulty { 
                guard inputDifficulty == "easy" || inputDifficulty == "medium" || inputDifficulty == "hard" || inputDifficulty == "hell" else{
                    return Response(status:.badRequest)
                }
                setDifficulty = toDifficulty(inputDifficulty:inputDifficulty)
            }
            
        }catch{
            print("[\(games.count)] No inputDifficulty received: Setting difficulty to medium (default)")
        }
        print("[\(games.count)] Difficulty:\(setDifficulty). ", terminator:"")
        games.append(Board(difficulty:setDifficulty))
        let body = "{\"boardID\":\(games.count-1)}"
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value:"application/json")
        return Response(status:HTTPResponseStatus.created,
                        headers:headers,
                        body:Response.Body(string:body))
    }

    app.get("games", ":id", "cells") { req -> Response in
        guard let id : Int = req.parameters.get("id"),
              id < games.count && id >= 0
        else {
            return Response(status:HTTPResponseStatus.badRequest)
        }
        print("[\(id)] Client is requsting board state.")
        let body = games[id].toJSON()
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value:"application/json")
        return Response(status:HTTPResponseStatus.ok,
                        headers:headers,
                        body:Response.Body(string:body))
    }

    app.put("games", ":id", "cells", ":boxIndex", ":cellIndex") { req -> Response in
        guard let id : Int = req.parameters.get("id"),
              let boxIndex : Int = req.parameters.get("boxIndex"),
              let cellIndex : Int = req.parameters.get("cellIndex"),
              id < games.count && id >= 0,
              boxIndex >= 0 && boxIndex < 9,
              cellIndex >= 0 && cellIndex < 9
        else {
            return Response(status:HTTPResponseStatus.badRequest)
        }
        var input : Int? = nil
        let pos = BCtoXY(b:boxIndex, c:cellIndex)
        var validMove : Bool = games[id].removeNumber(xPos:pos.0, yPos:pos.1)
        if let inputValue = try req.content.decode(InputValue.self).inputValue {
            guard inputValue >= 1 && inputValue <= 9 else {
                return Response(status:.badRequest)
            }
            validMove = games[id].insertNumber(xPos:pos.0, yPos:pos.1, number:inputValue)
            input = inputValue
        }
        if !validMove {print("[\(id)] Invalid move. no change to board state.")}
        else {print("[\(id)] Added \(String(describing:input)) at (\(pos.0),\(pos.1)).")}
        return Response(status:HTTPResponseStatus.noContent)
    }
}
