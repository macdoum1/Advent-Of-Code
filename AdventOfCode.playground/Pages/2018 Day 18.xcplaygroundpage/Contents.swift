//: [Previous](@previous)

import Foundation

enum Piece: Character {
    case openGround = "."
    case tree = "|"
    case lumberyard = "#"
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element == [Piece] {
    subscript(x: Int, y: Int) -> Piece? {
        get {
            return self[safe: y]?[safe: x]
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            self[y][x] = newValue
        }
    }
}

struct Forest {
    var map: [[Piece]]
    
    var resourceValue: Int {
        let treeCount = map.map { (row) -> Int in
            return row.filter {
                $0 == .tree
                }.count
            }.reduce(0, +)
        
        let lumberyardCount = map.map { (row) -> Int in
            return row.filter {
                $0 == .lumberyard
                }.count
            }.reduce(0, +)
        
        return treeCount * lumberyardCount
    }
    
    init(input: String) {
        let lines = input.split(separator: "\n")
        map = lines.map {
            $0.map {
                return Piece(rawValue: $0)!
            }
        }
    }
    
    mutating func move(minutes: Int) {
        var mapToTime = [map: 0]

        for currentTime in 1...minutes {
            moveOneMinute()
            
            // If the current map is the same configuration
            // as the map was at a previous time, there must be
            // a cycle of some sort
            // Otherwise, just store the map for later cycle detection
            guard let sameMapAtTime = mapToTime[map] else {
                mapToTime[map] = currentTime
                continue
            }
            
            let diff = currentTime - sameMapAtTime
            let remaining = minutes - sameMapAtTime
            map = mapToTime.first {
                $0.value == remaining % diff + sameMapAtTime
            }!.key
            break
        }
    }
    
    mutating func moveOneMinute() {
        var tempMap = map
        
        for y in 0..<map.count {
            for x in 0..<map[y].count {
                let adjacentPieces = getAdjacentPieces(x: x, y: y)
                switch map[x, y]! {
                case .openGround:
                    let treeCount = adjacentPieces.filter { $0 == .tree }.count
                    if treeCount >= 3 {
                        tempMap[x, y] = .tree
                    } else {
                        tempMap[x, y] = map[x, y]
                    }
                case .tree:
                    let lumberyardCount = adjacentPieces.filter { $0 == .lumberyard }.count
                    if lumberyardCount >= 3 {
                        tempMap[x, y] = .lumberyard
                    } else {
                        tempMap[x, y] = map[x, y]
                    }
                case .lumberyard:
                    let treeCount = adjacentPieces.filter { $0 == .tree }.count
                    let lumberyardCount = adjacentPieces.filter { $0 == .lumberyard }.count
                    if lumberyardCount >= 1 && treeCount >= 1 {
                        tempMap[x, y] = .lumberyard
                    } else {
                        tempMap[x, y] = .openGround
                    }
                }
            }
        }

        map = tempMap
    }
    
    private func getAdjacentPieces(x: Int, y: Int) -> [Piece] {
        return [
            map[x-1, y-1], // top left
            map[x, y-1], // above
            map[x+1, y-1], // top right
            map[x-1, y], // left
            map[x-1, y+1], // bottom left
            map[x, y+1], // below
            map[x+1, y+1], // bottom right
            map[x+1, y], // right
        ].compactMap { $0 }
    }
    
    func printState() {
        let desc = map.map {
            String($0.map {
                return $0.rawValue
            })
            }.joined(separator: "\n")
        print(desc)
    }
}

//let input = """
//.#.#...|#.
//.....#|##|
//.|..|...#.
//..|#.....#
//#.#|||#|#|
//...#.||...
//.|....|...
//||...#|.#|
//|.||||..|.
//...#.|..|.
//"""

let input = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

var forest = Forest(input: input)
forest.move(minutes: 1000000000)
let value = forest.resourceValue
print("Resource value \(value)")
// 

//: [Next](@next)
