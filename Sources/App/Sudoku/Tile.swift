public class Tile : CustomStringConvertible {
    public var value : Int? = nil
    public var possibleValues : [Int] = []
    public var description : String {return "Tile:\(value)"}
}
