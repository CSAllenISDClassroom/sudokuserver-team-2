import Vapor

func routes(_ app: Application) throws {
    var games : [Board] = []
    
    app.get { req in
        return "It works!"
    }

    app.get("games") { req -> String in
        games.append(Board(difficulty:Difficulty.medium))
        return "{\"boardID\":\(games.count-1)}"
    }

    app.get("games", ":id", "cells") { req -> String in
        return games[Int(req.parameters.get("id")!)!].toJSON()
    }

    app.put("games", ":id", "cells", ":boxIndex", ":cellIndex") { req -> String in
        guard let id : Int = req.parameters.get("id"),
              let boxIndex : Int = req.parameters.get("boxIndex"),
              let cellIndex : Int = req.parameters.get("cellIndex")
        else {
            fatalError("theres probably a better way to handle this.")
        }
        let pos = BCtoXY(b:boxIndex, c:cellIndex)
        return "work in progress"
    }
}

func BCtoXY(b:Int, c:Int) -> (Int, Int) {
    let y = Int(b/3) + Int(c/3)
    let x = Int(b%3) + Int(c%3)
    return (x, y)
}
