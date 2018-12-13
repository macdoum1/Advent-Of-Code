//: [Previous](@previous)

import Foundation

// Day 13
protocol MapPiece {
    var characterDescription: Character { get }
}

// From https://stackoverflow.com/a/50007091
extension Dictionary where Value : Hashable {
    func swapKeyValues() -> [Value : Key] {
        assert(Set(self.values).count == self.keys.count, "Values must be unique")
        var newDict = [Value : Key]()
        for (key, value) in self {
            newDict[value] = key
        }
        return newDict
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct System {
    typealias Position = (x: Int, y: Int)
    struct Train: MapPiece {
        enum IntersectionDecision: Int {
            case left
            case straight
            case right
            
            func next() -> IntersectionDecision {
                return IntersectionDecision(rawValue: rawValue + 1) ?? IntersectionDecision(rawValue: 0)!
            }
        }
        
        enum Direction: Character {
            case up = "^"
            case down = "v"
            case left = "<"
            case right = ">"
        }
        
        var isHorizontal: Bool {
            return direction == .left || direction == .right
        }
        
        var direction: Direction
        let identifier: Int
        
        private var lastIntersectionDecision = IntersectionDecision.right
        
        init?(character: Character, identifier: Int=0) {
            guard let direction = Direction(rawValue: character) else { return nil }
            self.direction = direction
            
            self.identifier = identifier
        }
        
        var characterDescription: Character {
            return direction.rawValue
        }
        
        private func shouldStayCourse(trackType: Track.TrackType) -> Bool {
            return (trackType == .horizontal && direction == .left) ||
                (trackType == .horizontal && direction == .right) ||
                (trackType == .vertical && direction == .up) ||
                (trackType == .vertical && direction == .down)
        }
        
        mutating func turnIfNecessary(trackType: Track.TrackType) {
            if shouldStayCourse(trackType: trackType) {
                return
            }
            
            switch trackType {
                
                // These are not right
            case .backwardCurve:
                switch direction {
                case .up:
                    direction = .left
                case .down:
                    direction = .right
                case .left:
                    direction = .up
                case .right:
                    direction = .down
                }
            case .forwardCurve:
                switch direction {
                case .up:
                    direction = .right
                case .down:
                    direction = .left
                case .left:
                    direction = .down
                case .right:
                    direction = .up
                }
            case .intersection:
                let decision = lastIntersectionDecision.next()
                lastIntersectionDecision = decision
                switch decision {
                case .left:
                    switch direction {
                    case .up:
                        direction = .left
                    case .down:
                        direction = .right
                    case .left:
                        direction = .down
                    case .right:
                        direction = .up
                    }
                case .straight:
                    break
                case .right:
                    switch direction {
                    case .up:
                        direction = .right
                    case .down:
                        direction = .left
                    case .left:
                        direction = .up
                    case .right:
                        direction = .down
                    }
                }
            default:
                fatalError("This shouldn't happen")
            }
        }
        
        func getNextPosition(current: Position) -> Position {
            switch direction {
            case .up:
                return (current.x, current.y-1)
            case .down:
                return (current.x, current.y+1)
            case .left:
                return (current.x-1, current.y)
            case .right:
                return (current.x+1, current.y)
            }
        }
    }
    
    struct Track: MapPiece {
        enum TrackType: Character {
            case horizontal = "-"
            case vertical = "|"
            case forwardCurve = "+"
            case backwardCurve = "/"
            case intersection = "\\"
        }
        
        var train: Train?
        
        let type: TrackType
        
        init?(character: Character) {
            // If there is a train, interpret the track
            // type from the train
            //
            // If no train exists try to get the type
            // directly
            // Otherwise it's empty
            if let train = Train(character: character) {
                self.train = train
                self.type = train.isHorizontal ? .horizontal : .vertical
            } else if let type = TrackType(rawValue: character) {
                self.type = type
            } else {
                return nil
            }
        }
        
        var characterDescription: Character {
            if let train = train {
                return train.characterDescription
            } else {
                return type.rawValue
            }
        }
    }
    
    struct Empty: MapPiece {
        var characterDescription: Character {
            return " "
        }
    }
    
    private var map: [[MapPiece]]
    
    private static func inputFromFilename(_ filename: String) -> String {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        return (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    }
    
    private static func inputFromURL(_ fileUrl: URL) -> String {
        return (try? String(contentsOf: fileUrl, encoding: .utf8)) ?? ""
    }
    
    private init(lines: [String]) {
        let xLength = lines.map { $0.count }.max() ?? 0
        map = lines.map {
            let row = Array($0)
            return (0..<xLength).map({ (x) -> MapPiece in
                if let character = row[safe: x],
                    let track = Track(character: character) {
                    return track
                } else {
                    return Empty()
                }
            })
        }
        map
    }
    
    init(filename: String) {
        let input = System.inputFromFilename(filename)
        let lines = input.split(separator: "\n").map { String($0) }
        self.init(lines: lines)
    }
    
    init(fileUrl: URL) {
        let input = System.inputFromURL(fileUrl)
        let lines = input.split(separator: "\n").map { String($0) }
        self.init(lines: lines)
    }
    
    /// Moves time forward 1 tick
    ///
    /// - Returns: Position of collision
    mutating func tick() -> Position? {
        var collisionPosition: Position? = nil
        for (y, row) in map.enumerated() {
            for (x, piece) in row.enumerated() {
                guard var track = piece as? Track else { continue }
                guard var train = track.train else { continue }
                
                train.turnIfNecessary(trackType: track.type)
                
                // Get next position based on current direction
                let nextPosition = train.getNextPosition(current: (x, y))
                
                // Move train from old track
                track.train = nil
                map[y][x] = track
                
                // Add train to new track while checking for collisions
                guard var nextTrack = map[nextPosition.y][nextPosition.x] as? Track else {
                    fatalError("You dun goofed")
                    continue
                }
                
                if nextTrack.train != nil {
                    nextTrack.train = nil
                    collisionPosition = nextPosition
                } else {
                    nextTrack.train = train
                }
                
                map[nextPosition.y][nextPosition.x] = nextTrack
            }
        }
        return collisionPosition
    }
    
    func printState() {
        let desc = map.map {
            String($0.map { $0.characterDescription })
        }.joined(separator: "\n")
        print(desc)
        
        map.forEach {
            print($0.count)
        }
    }
    
    func printPositionOfFirstCollision() {
        var system = self
        var collisionPosition: Position? = nil
        while collisionPosition == nil {
//            system.printState()
            collisionPosition = system.tick()
        }
        
        print("\(collisionPosition?.x ?? -1),\(collisionPosition?.y ?? -1)")
    }
    
    func countTrains() -> Int {
        return map.flatMap {
            $0.filter {
                guard let track = $0 as? Track else { return false }
                return track.train != nil
            }
        }.count
    }
    
    func printPositionOfLastRemainingCart() {
        var system = self
        var count = system.countTrains()
        while count > 1 {
            // Update the count if a collision occurs
            if system.tick() != nil {
                count = system.countTrains()
            }
        }
        
        for (y, row) in system.map.enumerated() {
            for (x, piece) in row.enumerated() {
                guard let track = piece as? Track else { continue }
                guard track.train != nil else { continue }
                
                print("Position of last cart: \(x),\(y)")
                
                break
            }
        }
    }
}

// Part 1
//let system = System(filename: "input")
//system.printPositionOfFirstCollision()

// Part 2

//print("Enter filename")
//let input = readLine() ?? ""
//print(input)
//let url = URL(fileURLWithPath: input)!
//print("Url generated")
//

//let system = System(fileUrl: url)
var system = System(filename: "test-input")
system.printState()
system.tick()
system.printState()
//system.printPositionOfLastRemainingCart()
// Not 97,107


//: [Next](@next)
