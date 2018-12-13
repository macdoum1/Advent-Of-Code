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

struct System {
//    private static let intersectionRule: [Train.Direction] = [.left, .straight, .right]
    struct Train: MapPiece {
        enum Direction {
            case up
            case down
            case left
            case right
        }
        
        private let map: [Character: Direction] = [
            "^": .up,
            "v": .down,
            "<": .left,
            ">": .right,
        ]
        
        var isHorizontal: Bool {
            return direction == .left || direction == .right
        }
        
        var direction: Direction
        let identifier: Int
        
        init?(character: Character, identifier: Int=0) {
            guard let direction = map[character] else { return nil }
            self.direction = direction
            
            self.identifier = identifier
        }
        
        var characterDescription: Character {
            let inverseMap = map.swapKeyValues()
            return inverseMap[direction]!
        }
        
        func shouldStayCourse(trackType: Track.TrackType) -> Bool {
            return (trackType == .horizontal && direction == .left) ||
                (trackType == .horizontal && direction == .right) ||
                (trackType == .vertical && direction == .up) ||
                (trackType == .vertical && direction == .down)
        }
        
        typealias Position = (x: Int, y: Int)
        
        func getNextPosition(current: Position, trackType: Track.TrackType) -> Position {
            if shouldStayCourse(trackType: trackType) {
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
            } else {
                // TODO handle turning
                // TODO handle curves?
                print("should turn")
                return (-1, -1)
            }
        }
    }
    
    struct Track: MapPiece {
        enum TrackType {
            case horizontal
            case vertical
            case forwardCurve
            case backwardCurve
            case intersection
        }
        
        var train: Train?
        
        private let map: [Character: TrackType] = [
            "-": .horizontal,
            "|": .vertical,
            "+": .intersection,
            "/": .forwardCurve,
            "\\": .backwardCurve,
        ]
        
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
            } else if let type = map[character] {
                self.type = type
            } else {
                return nil
            }
        }
        
        var characterDescription: Character {
            if let train = train {
                return train.characterDescription
            } else {
                let inverseMap = map.swapKeyValues()
                return inverseMap[type]!
            }
        }
    }
    
    struct Empty: MapPiece {
        var characterDescription: Character {
            return " "
        }
    }
    
    private let map: [[MapPiece]]
    
    init(filename: String) {
        let input = System.inputFromFilename(filename)
        let lines = input.split(separator: "\n")
        
        map = lines.map { (line) -> [MapPiece] in
            return line.map({ (character) -> MapPiece in
                if let track = Track(character: character) {
                    // TODO store train for ticking better
                    return track
                } else {
                    return Empty()
                }
            })
        }
    }
    
    func tick() {
        for (y, row) in map.enumerated() {
            print("row: \(row.count)")
            for (x, piece) in row.enumerated() {
                guard var track = piece as? Track else { continue }
                guard let train = track.train else { continue }
                
                let nextPosition = train.getNextPosition(current: (x, y), trackType: track.type)
                print(nextPosition)
                track.train = nil
                guard var nextTrack = map[nextPosition.x][nextPosition.y] as? Track else {
                    fatalError("You dun goofed")
                    continue
                }
                
                nextTrack.train = train
            }
        }
    }
    
    func printState() {
        let desc = map.map {
            String($0.map { $0.characterDescription })
        }.joined(separator: "\n")
        
        print(desc)
    }
    
    private static func inputFromFilename(_ filename: String) -> String {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        return (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    }
}

let system = System(filename: "test-input")
system.printState()
system.tick()
system.printState()


//: [Next](@next)
