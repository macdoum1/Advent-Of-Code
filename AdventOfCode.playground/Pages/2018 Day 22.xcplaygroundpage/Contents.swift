//: [Previous](@previous)

import Foundation

enum RegionType: Int {
    case rocky = 0
    case narrow = 1
    case wet = 2
}

struct Cave {
    let target: Position
    let depth: Int
    
    init(target: Position, depth: Int) {
        self.target = target
        self.depth = depth
    }
    
    private var erosionLevelMap = [Position: Int]()
    
    mutating func geologicalIndex(atPosition position: Position) -> Int {
        if position.x == 0 && position.y == 0 {
            return 0
        } else if position == target {
            return 0
        } else if position.y == 0 {
            return position.x * 16807
        } else if position.x == 0 {
            return position.y * 48271
        } else {
            return erosionLevel(atPosition: position.left) * erosionLevel(atPosition: position.above)
        }
    }
    
    mutating func erosionLevel(atPosition position: Position) -> Int {
        if let cached = erosionLevelMap[position] {
            return cached
        } else {
            let erosion = (geologicalIndex(atPosition: position) + depth) % 20183
            erosionLevelMap[position] = erosion
            return erosion
        }
    }
    
    mutating func regionType(atPosition position: Position) -> RegionType {
        let erosionMod3 = erosionLevel(atPosition: position) % 3
        return RegionType(rawValue: erosionMod3)!
    }
    
    mutating func riskLevel() -> Int {
        var risk = 0
        for x in 0...target.x {
            for y in 0...target.y {
                risk += regionType(atPosition: Position(x: x, y: y)).rawValue
            }
        }
        return risk
    }
}

// Example
//var cave = Cave(target: Position(x: 10, y: 10), depth: 510)
//
//let position = Position(x: 10, y: 10)
//print(cave.geologicalIndex(atPosition: position))
//print(cave.erosionLevel(atPosition: position))
//print(cave.regionType(atPosition: position))
//print(cave.riskLevel())

//let input = """
//depth: 11541
//target: 14,778
//"""

func part1() {
    var cave = Cave(target: Position(x: 14, y: 778), depth: 11541)
    print(cave.riskLevel())
}



//: [Next](@next)
