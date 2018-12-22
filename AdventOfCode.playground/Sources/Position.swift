import Foundation

public struct Position: Hashable {
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public var left: Position {
        return Position(x: x-1, y: y)
    }
    
    public var right: Position {
        return Position(x: x+1, y: y)
    }
    
    public var below: Position {
        return Position(x: x, y: y+1)
    }
    
    public var above: Position {
        return Position(x: x, y: y-1)
    }
    
    public var isValid: Bool {
        return x >= 0 && y >= 0
    }
    
    public func adding(_ position: Position) -> Position {
        return Position(x: x+position.x, y: y+position.y)
    }
}
