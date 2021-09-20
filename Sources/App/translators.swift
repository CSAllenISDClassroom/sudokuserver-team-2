import Vapor

public func BCtoXY(b:Int, c:Int) -> (Int, Int) {
    let y = Int(b/3)*3 + Int(c/3)
    let x = Int(b%3)*3 + Int(c%3)
    return (x, y)
}

public struct InputValue : Content {
    var inputValue : Int?
}
