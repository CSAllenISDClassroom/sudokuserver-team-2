public class Board {
    private var board : [[Tile]]
    private let rows : [Row]
    private let columns : [Column]
    private let groups : [Group]

    public let difficulty : Difficulty

    private var originalBoard : [[OTile]] = Array(repeating:Array(repeating:OTile(), count:9), count:9)
    private var totalBoardGens = 0

    // insertNumber() returns true if insert position is valid (no number already there & no similar number in row/column/group), and false if position is invalid
    public func insertNumber(xPos:Int, yPos:Int, number:Int) -> Bool {
        guard self.board[yPos][xPos].value == nil && validInsertPosition(xPos:xPos, yPos:yPos, number:number) else {
            return false
        }
        self.board[yPos][xPos].value = number
        return true
    }

    // removeNumber returns true if remove position is valid (player-inserted number there), and false if position is invalid
    public func removeNumber(xPos:Int, yPos:Int) -> Bool {
        guard self.board[yPos][xPos].value != nil && self.originalBoard[yPos][xPos].value == nil else {
            return false
        }
        self.board[yPos][xPos].value = nil
        return true
    }

    // Initializes the board with the proper difficulty, preparing one complete board for the server and removing cells to make an incomplete one for the client
    init(difficulty:Difficulty) {
        self.difficulty = difficulty
        self.board = [
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()],
          [Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile(),Tile()]
        ]
        var rows : [Row] = []
        var columns : [Column] = []
        var groups : [Group] = []
        // prepare rows and columns
        for y in 0..<board.count {
            var rowTmp : [Tile] = []
            var columnTmp : [Tile] = []
            for x in 0..<board[y].count {
                rowTmp.append(self.board[y][x])
                columnTmp.append(self.board[x][y])
            }
            rows.append(Row(tiles:rowTmp))
            columns.append(Column(tiles:columnTmp))
        }
        // prepare groups
        for y in 1...3 {
            for x in 1...3 {
                var groupTmp : [Tile] = []
                groupTmp.append(self.board[y*3-3][x*3-3])
                groupTmp.append(self.board[y*3-3][x*3-2])
                groupTmp.append(self.board[y*3-3][x*3-1])
                groupTmp.append(self.board[y*3-2][x*3-3])
                groupTmp.append(self.board[y*3-2][x*3-2])
                groupTmp.append(self.board[y*3-2][x*3-1])
                groupTmp.append(self.board[y*3-1][x*3-3])
                groupTmp.append(self.board[y*3-1][x*3-2])
                groupTmp.append(self.board[y*3-1][x*3-1])
                groups.append(Group(tiles:groupTmp))
            }
        }
        // cp
        self.rows = rows
        self.columns = columns
        self.groups = groups
        // build board
        while true {
            do {
                self.totalBoardGens += 1
                try genBoardNums()
                break
            } catch GenError.impossibleBoard {
                resetBoard()
            } catch {
                print("Unexpected error: \(error)")
            }
        }
        removeBoardNums()
        print("New board built. Took \(totalBoardGens) attempts.")
        // cp to original board
        for y in 0..<self.board.count {
            for x in 0..<self.board[y].count {
                self.originalBoard[y][x].value = self.board[y][x].value
            }
        }
    }

    // Determines if the number being inputted to a position is valid for the complete sudoku board
    private func validInsertPosition(xPos:Int, yPos:Int, number:Int) -> Bool {
        return !(rows[yPos].tiles.contains(where:{$0.value == number}) || columns[xPos].tiles.contains(where:{$0.value == number}) || xyToGroup(x:xPos, y:yPos).tiles.contains(where:{$0.value == number}))
    }

    // Generates a random number for a random position on the board
    private func genBoardNums() throws {
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                var randNums = [1,2,3,4,5,6,7,8,9]
                var rand = randNums[Int.random(in: 0..<randNums.count)]
                while rows[y].tiles.contains(where:{$0.value == rand}) || columns[x].tiles.contains(where:{$0.value == rand}) || xyToGroup(x:x, y:y).tiles.contains(where:{$0.value == rand}) {
                    randNums.removeAll(where: {rand == $0})
                    guard randNums.count > 0 else {
                        throw GenError.impossibleBoard
                    }
                    rand = randNums[Int.random(in: 0..<randNums.count)]
                }
                board[y][x].value = rand
            }
        }
    }

    // Removes random numbers from the board depending on the difficulty to make an incomplete board
    private func removeBoardNums() {
        // amount to remove
        let count : Int
        switch self.difficulty {
        case Difficulty.easy: count = 81 - 30
        case Difficulty.medium: count = 81 - 24
        case Difficulty.hard: count = 81 - 20
        case Difficulty.hell: count = 81 - 17
        }
        var cells = Array(repeating:[0,0], count:count)
        // find cells
        for i in 0..<cells.count {
            var randX = Int.random(in:0...8)
            var randY = Int.random(in:0...8)
            while cells.contains(where: {$0[0] == randX && $0[1] == randY}) {
                randX = Int.random(in:0...8)
                randY = Int.random(in:0...8)
            }
            cells[i][0] = randX
            cells[i][1] = randY
        }
        // remove cells
        for cell in cells {
            self.board[cell[1]][cell[0]].value = nil
        }
    }

    private func xyToGroup(x:Int, y:Int) -> Group {
        precondition(x <= 8 && x >= 0 && y <= 8 && y >= 0, "Coordinates must be valid 'board' indexes.")
        let res : Group
        switch (x/3, y/3) {
        case (0,0): res = self.groups[0]
        case (1,0): res = self.groups[1]
        case (2,0): res = self.groups[2]
        case (0,1): res = self.groups[3]
        case (1,1): res = self.groups[4]
        case (2,1): res = self.groups[5]
        case (0,2): res = self.groups[6]
        case (1,2): res = self.groups[7]
        case (2,2): res = self.groups[8]
        case (_,_): fatalError("Welp, ig u messed up that switch statement.")
        }
        return res
    }

    private func resetBoard() {
        for y in self.board {
            for tile in y {
                tile.value = nil
            }
        }
    }

    public func toString() -> String {
        var s : String = ""
        for y in self.board {
            for tile in y {
                if tile.value == nil {s += "-"}
                else {s += String(tile.value!)}
                s += " "
            }
            s += "\n"
        }
        return s
    }

    public func oToString() -> String {
        var s : String = ""
        for y in self.originalBoard {
            for tile in y {
                if tile.value == nil {s += "-"}
                else {s += String(tile.value!)}
                s += " "
            }
            s += "\n"
        }
        return s
    }

    public func toJSON() -> String {
        let board = convertBoardToBC()
        var s : String = "{\"cells\":["
        for b in 0..<board.count {
            s += "["
            for c in 0..<board[b].count {
                let tile = board[b][c]
                if tile.value == nil {s += "null"}
                else {s += String(tile.value!)}
                if c != board[b].count-1 {s += ","}
            }
            if b == board.count-1 {s += "]"}
            else {s += "],"}
        }
        s += "]}"
        return s
    }

    private func convertBoardToBC() -> [[OTile]] {
        var res : [[OTile]] = Array(repeating:Array(repeating:OTile(), count:9), count:9)
        for b in 0..<res.count {
            for c in 0..<res[b].count {
                let pos = BCtoXY(b:b,c:c)
                res[b][c].value = self.board[pos.1][pos.0].value
            }
        }
        return res
    }
}
