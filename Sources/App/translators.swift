import Vapor

public func BCtoXY(b:Int, c:Int) -> (Int, Int) {
    let y = Int(b/3)*3 + Int(c/3)
    let x = Int(b%3)*3 + Int(c%3)
    return (x, y)
}

public func toDifficulty(inputDifficulty:String) -> Difficulty? {
    var returnValue : Difficulty?
    switch inputDifficulty {
    case "easy":
        returnValue = Difficulty.easy
    case "medium":
        returnValue = Difficulty.medium
    case "hard":
        returnValue = Difficulty.hard
    case "hell":
        returnValue = Difficulty.hell
    default:
        returnValue = nil
        print("Reached default difficulty switch case: Setting Difficulty to medium")
    }
    return returnValue
}

public struct InputValue : Content {
    var value : Int?
}

public struct InputDifficulty : Content {
    var difficulty : String?
    
}

