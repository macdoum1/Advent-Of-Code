//: [Previous](@previous)

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

enum Piece: Character {
    case sand = "."
    case clay = "#"
    case waterSource = "+"
    case flowingWater = "|"
    case standingWater = "~"
    
    var canFlowThrough: Bool {
        switch self {
        case .sand, .waterSource, .flowingWater:
            return true
        case .clay, .standingWater:
            return false
        }
    }
}

extension Array where Element == [Piece] {
    subscript(position: Position) -> Piece? {
        get {
            return self[safe: position.y]?[safe: position.x]
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            self[position.y][position.x] = newValue
        }
    }
}

struct Position: Hashable {
    let x: Int
    let y: Int
    var left: Position {
        return Position(x: x-1, y: y)
    }
    
    var right: Position {
        return Position(x: x+1, y: y)
    }
    
    var below: Position {
        return Position(x: x, y: y+1)
    }
}

struct Underground {
    private var map: [[Piece]]
    private let adjustedWaterSourcePosition: Position
    
    init(input: String, waterSourcePosition: Position) {
        let lines = input.split(separator: "\n")
        
        var clayPositions = Set<Position>()
        for line in lines {
            var line = String(line)
            //x=495, y=2..7
            line = line.replacingOccurrences(of: ",", with: "")
            //x=495 y=2..7
            let coords = line.split(separator: " ")
            //["x=495", "y=2..7"]
            let isFirstX = coords[0].contains("x")
            
            let xString = String(coords[isFirstX ? 0 : 1])
            let yString = String(coords[isFirstX ? 1 : 0])
            
            let xInts = Underground.getIntsFromCoordString(xString)
            let yInts = Underground.getIntsFromCoordString(yString)
            
            for x in xInts {
                for y in yInts {
                    let position = Position(x: x, y: y)
                    clayPositions.insert(position)
                }
            }
        }
        
        let xValues = clayPositions.map { $0.x }
        let yValues = clayPositions.map { $0.y }
        
        // We need a little padding in case water flows over clay
        // on the edge
        let xMin = xValues.min()! - 1
        let xMax = xValues.max()! + 1
        let yMin = yValues.min()!
        let yMax = yValues.max()!
        
        let xSize = xMax-xMin+1
        let ySize = yMax-yMin+1

        var tempMap = [[Piece]](repeating: [Piece](repeating: Piece.sand, count: xSize), count: ySize)
        for clayPosition in clayPositions {
            tempMap[clayPosition.y-yMin][clayPosition.x-xMin] = Piece.clay
        }
        
        adjustedWaterSourcePosition = Position(x: waterSourcePosition.x-xMin, y: 0)
        tempMap[adjustedWaterSourcePosition] = Piece.waterSource
        map = tempMap
    }
    
    private static func getIntsFromCoordString(_ string: String) -> [Int] {
        // "x=495" || "y=2..7" we don't care about x or y in here
        let isRange = string.contains("..")
        
        var sanitizedString = string.replacingOccurrences(of: "y=", with: "")
        sanitizedString = sanitizedString.replacingOccurrences(of: "x=", with: "")
        
        if isRange {
            sanitizedString = sanitizedString.replacingOccurrences(of: "..", with: ",")
            let nums = sanitizedString.split(separator: ",").map {
                return Int($0)!
            }
            return Array(nums[0]...nums[1])
        } else {
            return [Int(sanitizedString)!]
        }
    }
    
    func printState() {
        let desc = map.map {
            String($0.map {
                return $0.rawValue
            })
        }.joined(separator: "\n")
        print(desc)
        print("\n")
    }
    
    func countAllWater() -> Int {
        return map.map {
            $0.filter {
                $0 == Piece.flowingWater || $0 == Piece.standingWater
            }.count
        }.reduce(0, +)
    }
    
    func countStandingWater() -> Int {
        return map.map {
            $0.filter {
                $0 == Piece.standingWater
            }.count
        }.reduce(0, +)
    }
    
    mutating func flow() {
        let source = adjustedWaterSourcePosition
        
        var flowedPositions = Set<Position>()
        flow(from: source, flowedPositions: &flowedPositions)
    }
    
    private mutating func flow(from position: Position, flowedPositions: inout Set<Position>) -> Bool {
        guard let piece = map[position], piece.canFlowThrough else { return false }
                
        if flowedPositions.contains(position) { return false }
        
        map[position] = .flowingWater
        flowedPositions.insert(position)
        
        let below = position.below
        if flow(from: below, flowedPositions: &flowedPositions) {
            return true
        } else if let belowPiece = map[below], !belowPiece.canFlowThrough {
            let flowLeft = flow(from: position.left, flowedPositions: &flowedPositions)
            let flowRight = flow(from: position.right, flowedPositions: &flowedPositions)

            stabilizeStandingWaterAroundPosition(position)

            if flowLeft || flowRight {
                return true
            }
        }
        
        return false
    }

    private mutating func stabilizeStandingWaterAroundPosition(_ position: Position) {
        guard let leftWall = (positionOfFirstWall(position) { (position) -> Position in
            return position.left
        }) else {
            return
        }
        
        guard let rightWall = (positionOfFirstWall(position) { (position) -> Position in
            return position.right
        }) else {
            return
        }
        
        // We want to make all spaces between non-flowable pieces
        // standing water
        for x in leftWall.x+1..<rightWall.x {
            map[leftWall.y][x] = .standingWater
        }
    }
    
    private func positionOfFirstWall(_ position: Position, mutator: ((Position) -> Position)) -> Position? {
        var nextPosition: Position? = mutator(position)
        guard var piece = map[nextPosition!] else { return nil } // If nil, can't be standing
        
        while piece.canFlowThrough {
            nextPosition = mutator(nextPosition!)
            
            guard let nextPiece = map[nextPosition!] else {
                return nil
            }
            
            let below = Position(x: nextPosition!.x, y: nextPosition!.y+1)
            if (map[below]?.canFlowThrough) ?? true {
                return nil
            }
            
            piece = nextPiece
        }
        return nextPosition
    }
}

//let input = """
//x=495, y=2..7
//y=7, x=495..501
//x=501, y=3..7
//x=498, y=2..4
//x=506, y=1..2
//x=498, y=10..13
//x=504, y=10..13
//y=13, x=498..504
//y=25, x=490..506
//x=490, y=20..25
//x=506, y=20..25
//"""

let input = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

var underground = Underground(input: input, waterSourcePosition: Position(x: 500, y: 0))

print("Initial")
underground.flow()

underground.printState()
print("All Water: \(underground.countAllWater())")
print("Standing Water: \(underground.countStandingWater())")
/*
 All Water: 29063
 Standing Water: 23811
*/

//: [Next](@next)
