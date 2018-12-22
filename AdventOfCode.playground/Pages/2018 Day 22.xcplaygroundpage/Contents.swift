//: [Previous](@previous)

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

// From https://codereview.stackexchange.com/questions/129487/a-generic-implementation-in-swift
// State : a protocole for states in the search space
protocol State: Equatable {
    
    // successors() : returns an array of successors states in the search space
    func successors() -> [Successor<Self>]
    
    // heuristic(goal) : returns the heuristic value in relation to a given goal state
    func heuristic(goal: Self) -> Double
    
    // id : a string identifying a state
    var id: String { get }
    
}

// States are compared by their id
func == <T: State> (lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}

// Successor : represents a successor state and its cost
struct Successor<T: State> {
    var state: T
    var cost: Double
}

// Plan : a plan of states
struct Plan<T: State> {
    
    // states : an array of states that make a plan
    var states: [T]
    
    // lastState : the last state of the plan
    var lastState: T
    
    // cost : the total cost of the plan
    var cost: Double
    
    // initialise a plan with a single state
    init(state: T) {
        states = [state]
        lastState = state
        cost = 0
    }
    
    // append a successor to this plan
    mutating func append(successor: Successor<T>) {
        states.append(successor.state)
        lastState = successor.state
        cost += successor.cost
    }
    
    // the non-mutating version of append(_:)
    func appending(successor: Successor<T>) -> Plan {
        var new = self
        new.append(successor: successor)
        return new
    }
    
}

extension Plan: Equatable {}

func == <T: State> (lhs: Plan<T>, rhs: Plan<T>) -> Bool {
    return lhs.states == rhs.states
}

// AStar<TState> : finds the A* solution (nil if no solution found) given a start state and goal state
func AStar <TState: State> (start: TState, goal: TState) -> Plan<TState>? {
    
    var fringe = [Plan(state: start)]
    
    // computes the best plan from the fringe array
    // I made this its own function to make the `while let` statement more readable
    func bestPlan() -> Plan<TState>? {
        return fringe.min {
            $0.cost + $0.lastState.heuristic(goal: goal) < $1.cost + $1.lastState.heuristic(goal: goal)
        }
    }
    
    while let bestPlan = bestPlan(),
        let index = fringe.firstIndex(of: bestPlan) {
        fringe.remove(at: index)
        
        guard bestPlan.lastState != goal else { return bestPlan }
        
        let successors = bestPlan.lastState.successors()
        
        for successor in successors where !bestPlan.states.contains(successor.state) {
            fringe.append(bestPlan.appending(successor: successor))
        }
    }
    
    return nil
    
}

/*
 As you leave, he hands you some tools: a torch and some climbing gear. You can't equip both tools at once, but you can choose to use neither.
 
 Tools can only be used in certain regions:
 
 In wet regions, you can use the climbing gear or neither tool. You cannot use the torch (if it gets wet, you won't have a light source).
 In narrow regions, you can use the torch or neither tool. You cannot use the climbing gear (it's too bulky to fit).
 */

enum Tool {
    case torch
    case climbingGear
    case neither
}

enum RegionType: Int {
    case rocky = 0
    case narrow = 1
    case wet = 2
    
    var appropriateTools: [Tool] {
        switch self {
        case .rocky:
            return [.climbingGear, .torch]
        case .wet:
            return [.climbingGear, .neither]
        case .narrow:
            return [.torch, .neither]
        }
    }
}

struct Cave {
    let target: Position
    let depth: Int
    
    init(target: Position, depth: Int) {
        self.target = target
        self.depth = depth
    }
    
    private static var erosionLevelMap = [Position: Int]()
    
    func geologicalIndex(atPosition position: Position) -> Int {
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
    
    func erosionLevel(atPosition position: Position) -> Int {
        if let cached = Cave.erosionLevelMap[position] {
            return cached
        } else {
            let erosion = (geologicalIndex(atPosition: position) + depth) % 20183
            Cave.erosionLevelMap[position] = erosion
            return erosion
        }
    }
    
    func regionType(atPosition position: Position) -> RegionType {
        let erosionMod3 = erosionLevel(atPosition: position) % 3
        return RegionType(rawValue: erosionMod3)!
    }
    
    func riskLevel() -> Int {
        var risk = 0
        for x in 0...target.x {
            for y in 0...target.y {
                risk += regionType(atPosition: Position(x: x, y: y)).rawValue
            }
        }
        return risk
    }
}

func part1() {
    let cave = Cave(target: Position(x: 14, y: 778), depth: 11541)
    print(cave.riskLevel())
}

struct Region: State {
    private static let MaxX = 10
    private static let MaxY = 10
    
    let position: Position
    let cave: Cave
    
    var id: String {
        return "\(position.x),\(position.y)"
    }
    
    var type: RegionType {
        return cave.regionType(atPosition: position)
    }
    
    func successors() -> [Successor<Region>] {
        var around = [Position]()
        if position.above.isValid {
            around.append(position.above)
        }
        
        if position.right.isValid && position.right.x <= Region.MaxX {
            around.append(position.right)
        }
        
        if position.below.isValid && position.below.y <= Region.MaxY {
            around.append(position.below)
        }
        
        if position.left.isValid {
            around.append(position.left)
        }
        
        let regions = around.map {
            Region(position: $0, cave: cave)
        }
        
        return regions.map {
            let cost = calcCost(goal: $0)
            return Successor(state: $0, cost: cost)
        }
    }
    
    func calcCost(goal: Region) -> Double {
        let currentPossibleTools = Set(type.appropriateTools)
        let toolsForNextRegion = Set(goal.type.appropriateTools)
        
        let intersection = currentPossibleTools.intersection(toolsForNextRegion)
        if intersection.isEmpty {
            return 7 + 1 // Need to switch tool and move
        } else {
            return 1 // Just move
        }
    }
    
    private func manhattanDistance(_ coordinateA: Position,
                                   _ coordinateB: Position) -> Int {
        return abs(coordinateA.x - coordinateB.x) + abs(coordinateA.y - coordinateB.y)
    }
    
    func heuristic(goal: Region) -> Double {
        return Double(manhattanDistance(position, goal.position))
    }
}

let target = Position(x: 10, y: 10)
let cave = Cave(target: target, depth: 510)

let mouthRegion = Region(position: Position(x: 0, y: 0), cave: cave)
let targetRegion = Region(position: target, cave: cave)

let result = AStar(start: mouthRegion, goal: targetRegion)
print(result)


//: [Next](@next)
