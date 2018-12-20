//: [Previous](@previous)

import Foundation

struct Position: Hashable {
    let x: Int
    let y: Int
    
    func adding(_ position: Position) -> Position {
        return Position(x: x+position.x, y: y+position.y)
    }
}

enum RegexChar: Character {
    case north = "N"
    case east = "E"
    case south = "S"
    case west = "W"
    case or = "|"
    case openParen = "("
    case closeParen = ")"
    case startOfRegex = "^"
    case endOfRegex = "$"
    case newLine = "\n"
    
    var isDirection: Bool {
        switch self {
        case .north, .east, .south, .west:
            return true
        default:
            return false
        }
    }
    
    var directionValue: Position {
        switch self {
        case .north:
            return Position(x: 0, y: -1)
        case .east:
            return Position(x: 1, y: 0)
        case .south:
            return Position(x: 0, y: 1)
        case .west:
            return Position(x: -1, y: 0)
        default:
            fatalError("Shouldn't get here")
        }
    }
}

struct RegularMap {
    private let positionsToLength: [Position: Int]
    
    init(filename: String) {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        let input =  (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
        self.init(input: input)
    }

    init(input: String) {
        var positionStack = [Position]()
        var currentPosition = Position(x: 0, y: 0)
        var previousPosition = currentPosition
        var positionsToLength = [Position: Int]()
        for character in input {
            guard let regexChar = RegexChar(rawValue: character) else {
                fatalError("Whoops!")
            }
            
            switch regexChar {
            case .north, .east, .south, .west:
                currentPosition = currentPosition.adding(regexChar.directionValue)
                if let currentLength = positionsToLength[currentPosition] {
                    let previousLength = positionsToLength[previousPosition, default: 0] + 1
                    positionsToLength[currentPosition] = min(currentLength, previousLength)
                } else {
                    positionsToLength[currentPosition] = positionsToLength[previousPosition, default: 0] + 1
                }
            case .openParen:
                positionStack.append(currentPosition)
            case .closeParen:
                currentPosition = positionStack.popLast()!
            case .or:
                currentPosition = positionStack.last!
            case .startOfRegex, .endOfRegex, .newLine:
                continue
            }
            previousPosition = currentPosition
        }
        
        self.positionsToLength = positionsToLength
    }
    
    var maxLength: Int? {
        return positionsToLength.values.max()
    }
    
    func pathsWithNumberOfDoors(_ numberOfDoors: Int) -> Int {
        return positionsToLength.values.filter { $0 >= numberOfDoors }.count
    }
}

let map = RegularMap(filename: "input")
print(map.maxLength!)
print(map.pathsWithNumberOfDoors(1000))
//3991
//8394


//: [Next](@next)
