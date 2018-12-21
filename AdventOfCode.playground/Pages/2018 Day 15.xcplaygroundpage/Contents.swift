//: [Previous](@previous)

import Foundation

// Protocols
protocol GraphDatasource {
    var map: [[MapPiece]] { get }
}

protocol MapPiece {
    static var characterRepresentation: Character { get }
    var characterRepresentation: Character { get }
    init()
}

extension MapPiece {
    var characterRepresentation: Character {
        return Self.characterRepresentation
    }
}

protocol Unit: MapPiece {
    var attackPower: Int { get set }
    var hitPoints: Int { get set }
    var description: String { get }

}

extension Unit {
    var isDead: Bool {
        return hitPoints <= 0
    }
}

struct Empty: MapPiece {
    static let characterRepresentation: Character = "."
}

struct Wall: MapPiece {
    static let characterRepresentation: Character = "#"
}

struct Elf: Unit {
    var attackPower: Int = 3
    var hitPoints: Int = 200
    static let characterRepresentation: Character = "E"
    var description: String {
        return "E(\(hitPoints))"
    }
}

struct Goblin: Unit {
    var attackPower: Int = 3
    var hitPoints: Int = 200
    static let characterRepresentation: Character = "G"
    var description: String {
        return "G(\(hitPoints))"
    }
}

struct Cave: GraphDatasource {
    var debugMode = false
    
    internal var map: [[MapPiece]]
    
    private static let CharacterToPiece: [Character: MapPiece.Type] = {
        let allPieces: [MapPiece.Type] = [
            Empty.self,
            Wall.self,
            Elf.self,
            Goblin.self,
        ]
        
        var map: [Character: MapPiece.Type] = [:]
        for piece in allPieces {
            map[piece.characterRepresentation] = piece
        }
        return map
    }()
    
    init(input: String) {
        let lines = input.split(separator: "\n")
        map = lines.map {
            let row = Array($0)
            return row.map {
                let type = Cave.CharacterToPiece[$0]!
                return type.init()
            }
        }
    }
    
    /// Performs a single round for all units
    ///
    /// - Returns: True is targets remain
    mutating func performRound(elfAttack: Int=3) -> Bool {
        // Get all units in reading order
        var units = allUnitsInReadingOrder()
        
        for i in 0..<units.count {
            let piece = units[i]
            guard var elf = piece.1 as? Elf else { continue }
            
            elf.attackPower = elfAttack
            units[i].1 = elf
            map[piece.0.y][piece.0.x] = elf
        }
        
        var targetsRemain = true
        
        var unitIndex = 0
        while unitIndex < units.count {
            defer {
                unitIndex += 1
            }
            let unit = units[unitIndex]
            
            let targets = allTargetsForUnit(unit.1, amongst: units)
            
            if targets.isEmpty {
                targetsRemain = false
                break
            }
            
            // If performed attack before movement, turn is over
            if performAttackIfNecessary(unit: unit, units: &units, unitIndex: &unitIndex) {
                continue
            }
            
            var positions = getEmptyPositionsAroundTargets(targets)
            debugState(title: "Empty Positions", fillIn: positions, with: "?")
            
            positions = findNextPositionsAlongShortestPaths(unit: unit, positions: positions)
            debugState(title: "Possible positions", fillIn: positions, with: "!")

            positions = positionsSortedByReadingOrder(positions)
            
            if let stepPosition = positions.first {
                debugState(title: "Step to take", fillIn: [stepPosition], with: "$")
                
                // Update the map with new position, empty out old
                map[unit.0.y][unit.0.x] = Empty()
                map[stepPosition.y][stepPosition.x] = unit.1
                
                // Update position within unit array
                units[unitIndex].0 = stepPosition
                
                performAttackIfNecessary(unit: units[unitIndex], units: &units, unitIndex: &unitIndex)
            }
        }
        
        return targetsRemain
    }
    
    func sumOfRemainingHitpoints() -> Int {
        return map.map {
            $0.map {
                return ($0 as? Unit)?.hitPoints ?? 0
            }.reduce(0, +)
        }.reduce(0, +)
    }
    
    func sumOfRemainingElfs() -> Int {
        return map.map {
            return $0.filter { $0 is Elf }.count
        }.reduce(0, +)
    }
    
    private mutating func performAttackIfNecessary(unit: (Position, Unit),
                                                   units: inout [(Position, Unit)],
                                                   unitIndex: inout Int) -> Bool {
        if let enemyToAttack = getEnemyToAttack(unit: unit, amongst: units) {
            var attackedUnit = enemyToAttack.1
            attackedUnit.hitPoints -= unit.1.attackPower
            
            // If the unit is dead, remove it from array
            // and empty out the map
            // Otherwise, update the array & map
            if attackedUnit.isDead {
                units.remove(at: enemyToAttack.2)
                map[enemyToAttack.0.y][enemyToAttack.0.x] = Empty()
                
                // If we remove an enemy, update the index for iteration
                unitIndex -= 1
            } else {
                // Update map and array
                units[enemyToAttack.2] = (enemyToAttack.0, attackedUnit)
                map[enemyToAttack.0.y][enemyToAttack.0.x] = attackedUnit
            }
            
            return true
        }
        
        return false
    }
    
    private func getEnemyToAttack(unit: (Position, Unit), amongst units: [(Position, Unit)]) -> (Position, Unit, Int)? {
        
        // Get all positions around unit
        let aroundPositions = Set(Cave.getPositionsAround(unit.0))

        // Map through all units in order (to maintain index) and get enemies within range
        let enemiesWithinRange = units.enumerated().compactMap { (value) -> (Position, Unit, Int)? in
            // If a unit is not within range, return early
            guard aroundPositions.contains(value.element.0) else { return nil }
            
            guard let unitWithinRange = map[value.element.0.y][value.element.0.x] as? Unit else { return nil }
            if type(of: unit.1) != type(of: unitWithinRange) {
                return (value.element.0, unitWithinRange, value.offset)
            } else {
                return nil
            }
        }
        
        guard let minimumHPAmongstEnemies = enemiesWithinRange.min(by: { (a, b) -> Bool in
            return a.1.hitPoints < b.1.hitPoints
        })?.1.hitPoints else { return nil }
        
        let enemiesWithMinimumHP = enemiesWithinRange.filter {
            $0.1.hitPoints == minimumHPAmongstEnemies
        }
        
        // TODO sort order????
        return enemiesWithMinimumHP.first
    }
    
    struct UnitNode: GraphNode {
        let position: Position
        let datasource: GraphDatasource
        
        var connectedNodes: Set<Cave.UnitNode> {
            return Set(Cave.getPositionsAround(position).filter {
                datasource.map[$0.y][$0.x] is Empty
            }.map({ (position) -> UnitNode in
                return UnitNode(position: position, datasource: datasource)
            }))
        }
        
        func cost(to node: Cave.UnitNode) -> Float {
            if position.y == node.position.y {
                return Float(position.x + node.position.x)
            }
            
            return Float(position.y + node.position.y)
        }
        
        func estimatedCost(to node: Cave.UnitNode) -> Float {
            return cost(to: node)
        }
        
        static func == (lhs: Cave.UnitNode, rhs: Cave.UnitNode) -> Bool {
            return lhs.position == rhs.position
        }
        
        var hashValue: Int {
            return position.hashValue
        }
    }
    
    
    
    private func findNextPositionsAlongShortestPaths(unit: (Position, Unit), positions: [Position]) -> [Position] {
        let node = UnitNode(position: unit.0, datasource: self)
        
        let paths = positions.compactMap { (position) -> [UnitNode]? in
            let path = node.findPath(to: UnitNode(position: position, datasource: self))
            if path.count < 2 { return nil }
            return path
        }
        
        guard let shortestLength = (paths.min {
            $0.count < $1.count
        }?.count) else { return [] }
        
        let shortestPaths = paths.filter {
            $0.count == shortestLength
        }
        
        return shortestPaths.map {
            $0[1].position
        }
    }
    
    private func positionsSortedByReadingOrder(_ positions: [Position]) -> [Position] {
        return positions.sorted { (a, b) -> Bool in
            if a.y == b.y {
                return a.x < b.x
            }
            
            return a.y < b.y
        }
    }
    
    private func getEmptyPositionsAroundTargets(_ targets: [(Position, Unit)]) -> [Position] {
        let targetPositions = targets.map { $0.0 }
        var emptyPositions = [Position]()
        for targetPosition in targetPositions {
            let aroundPositions = Cave.getPositionsAround(targetPosition)
            let filtered = aroundPositions.filter({ (aroundPosition) -> Bool in
                return map[aroundPosition.y][aroundPosition.x] is Empty
            })
            emptyPositions.append(contentsOf: filtered)
        }
        return emptyPositions
    }
    
    private static func getPositionsAround(_ position: Position) -> [Position] {
        return [
            Position(x: position.x, y: position.y-1), // Above
            Position(x: position.x-1, y: position.y), // Left
            Position(x: position.x+1, y: position.y), // Right
            Position(x: position.x, y: position.y+1), // Below
        ]
    }
    
    private func allTargetsForUnit(_ currentUnit: Unit,
                                   amongst units: [(Position, Unit)]) -> [(Position, Unit)] {
        return units.filter({ (unit) -> Bool in
            return type(of: unit.1) != type(of: currentUnit)
        })
    }
    
    private func allUnitsInReadingOrder() -> [(Position, Unit)] {
        return map.enumerated().flatMap { (yValue) -> [(Position, Unit)] in
            let y = yValue.offset
            return yValue.element.enumerated().compactMap({ (xValue) -> (Position, Unit)? in
                guard let unit = xValue.element as? Unit else { return nil }
                let x = xValue.offset
                return (Position(x: x, y: y), unit)
            })
        }
    }
    
    func printState() {
        debugState(forceDebug: true)
    }
    
    /// Prints the current state of the cave
    /// Alternative, pass in an array of `positions` to fill in with character.
    /// good for testing
    private func debugState(title: String?=nil,
                            fillIn positions: [Position]=[],
                            with character: Character="?",
                            forceDebug: Bool=false) {
        if !debugMode && !forceDebug {
            return
        }
        
        if let title = title {
            print(title)
        }
        
        let unitDescriptionsPerRow = map.enumerated().map { (rowValue) -> String in
            return rowValue.element.compactMap({ (piece) -> String? in
                return (piece as? Unit)?.description
            }).joined(separator: ", ")
        }
        
        var descArray = map.map {
            $0.map { $0.characterRepresentation }
        }
        
        for position in positions {
            descArray[position.y][position.x] = character
        }
        
        let desc = descArray.enumerated().map {
            "\(String($0.element))   \(unitDescriptionsPerRow[$0.offset])"
        }.joined(separator: "\n")
        
        print("\(desc)\n")
    }
}

let input = """
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
"""

var cave = Cave(input: input)

let initialElves = cave.sumOfRemainingElfs()

for power in 3..<20 {
    print("Trying power \(power)")
    var round = 0
    while cave.performRound(elfAttack: power) {
        round += 1
    }
    cave.printState()
    
    print("Remaining hitpoints: \(cave.sumOfRemainingHitpoints())")
    let outcome = round * cave.sumOfRemainingHitpoints()
    print("Outcome: \(outcome)")
    print("Remaining elfs: \(cave.sumOfRemainingElfs())")
    
    if cave.sumOfRemainingElfs() == initialElves {
        break
    }
    
    cave = Cave(input: input)
    
    print("\n")
}
//: [Next](@next)
