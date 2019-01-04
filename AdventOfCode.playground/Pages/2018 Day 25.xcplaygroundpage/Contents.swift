//: [Previous](@previous)

import Foundation

struct SkyPoint: Hashable {
    let w: Int
    let x: Int
    let y: Int
    let z: Int
    
    init?(string: String) {
        let components = string.components(separatedBy: ",")
        let numbers = components.compactMap {
            Int($0)
        }
        
        if numbers.count != 4 {
            return nil
        }
        
        w = numbers[0]
        x = numbers[1]
        y = numbers[2]
        z = numbers[3]
    }
    
    private func manhattanDistanceTo(_ point: SkyPoint) -> Int {
        let wDiff = w - point.w
        let xDiff = x - point.x
        let yDiff = y - point.y
        let zDiff = z - point.z
        return abs(wDiff) + abs(xDiff) + abs(yDiff) + abs(zDiff)
    }
    
    func canFormConstellationWith(_ point: SkyPoint) -> Bool {
        let distance = manhattanDistanceTo(point)
        return distance <= 3
    }
}

struct SkySolver {
    let points: [SkyPoint]
    
    init(filename: String) {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        let input = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
        self.init(input: input)
    }
    
    init(input: String) {
        let lines = input.components(separatedBy: "\n")
        points = lines.compactMap { SkyPoint(string: $0) }
    }
    
    var pointToPossiblePointMap: [SkyPoint: Set<SkyPoint>] {
        var map = [SkyPoint: Set<SkyPoint>]()
        for pointA in points {
            for pointB in points {
                if pointA.canFormConstellationWith(pointB) {
                    map[pointA, default: []].insert(pointB)
                }
            }
        }
        return map
    }
    
    var numberOfConstellations: Int {
        let map = self.pointToPossiblePointMap
        
        var constellationCount = 0
        
        var used = Set<SkyPoint>()
        for point in points {
            guard !used.contains(point) else {
                continue
            }
            
            var working: Set<SkyPoint> = [point]
            var new = working
            while !new.isEmpty {
                new = Set(working.lazy.flatMap { map[$0]! })
                new.subtract(working)
                working.formUnion(new)
            }
            used.formUnion(working)
            constellationCount += 1
        }
        
        return constellationCount
    }
}

let input = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let skySolver = SkySolver(input: input)
print(skySolver.numberOfConstellations)

//: [Next](@next)
