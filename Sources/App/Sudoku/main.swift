/*
import Vapor

let app = try Application(.detect())
defer { app.shutdown() }

app.get("hello") { req in
    return "Hello, world."
}

try app.run()
*/
print("Wowzers! We're starting up!")

let difficulty : Difficulty
print("Enter difficulty: ", terminator:"")
let difInput = readLine()
switch difInput {
case "easy": difficulty = Difficulty.easy
case "medium": difficulty = Difficulty.medium
case "hard": difficulty = Difficulty.hard
case "hell": difficulty = Difficulty.hell
default: fatalError("U broke me :(")
}

var board = Board(difficulty:difficulty)
print(board.toString())
print("Original:")
print(board.oToString())

while let input = readLine() {
    let args = input.split(separator: " ")
    switch args[0] {
    case "insert": board.insertNumber(xPos:Int(args[1])!, yPos:Int(args[2])!, number:Int(args[3])!)
    case "remove": board.removeNumber(xPos:Int(args[1])!, yPos:Int(args[2])!)
    default: print("unknown command. :(")
    }
    print(board.toString())
}
