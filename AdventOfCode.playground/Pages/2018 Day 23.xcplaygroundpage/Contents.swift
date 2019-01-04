//: [Previous](@previous)

import Foundation

extension String {
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

struct Nanobot {
    let position: (x: Int, y: Int, z: Int)
    let signalRadius: Int
    init?(string: String) {
        let pattern = "^pos=<(?<x>-?\\d+),(?<y>-?\\d+),(?<z>-?\\d+)>, r=(?<radius>-?\\d+)$"
        let results = string.groups(for: pattern).flatMap { $0 }
        let numbers = results.compactMap { Int($0) }
        
        if numbers.count < 4 {
            return nil
        }
        
        position = (numbers[0], numbers[1], numbers[2])
        signalRadius = numbers[3]
    }
}

struct BotFinder {
    let bots: [Nanobot]

    init(filename: String) {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        let input = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
        self.init(input: input)
    }
    
    init(input: String) {
        bots = input.components(separatedBy: "\n").compactMap {
            if let bot = Nanobot(string: $0) {
                return bot
            } else {
                return nil
            }
        }
    }
    
    var botWithLargestSignal: Nanobot {
        return bots.max {
            return $0.signalRadius < $1.signalRadius
        }!
    }
    
    func numberOfBotsWithinRange(of bot: Nanobot) -> Int {
        return bots.filter { (botToTest) -> Bool in
            let xDiff = (bot.position.x - botToTest.position.x)
            let yDiff = (bot.position.y - botToTest.position.y)
            let zDiff = (bot.position.z - botToTest.position.z)
            let distance = abs(xDiff) + abs(yDiff) + abs(zDiff)
            return distance <= bot.signalRadius
        }.count
    }
    
    func part2() -> Int {
        let xValues = bots.map { $0.position.x }
        let yValues = bots.map { $0.position.y }
        let zValues = bots.map { $0.position.z }
        
        var bestGrid: (x: Int, y: Int, z: Int)? = nil
        
        var xMin = xValues.min()!
        var xMax = xValues.max()!
        var yMin = yValues.min()!
        var yMax = yValues.max()!
        var zMin = zValues.min()!
        var zMax = zValues.max()!
        
        var gridSize = xMax - xMin
        while gridSize > 0 {
            var maxCount = 0
            for x in stride(from: xMin, to: xMax, by: gridSize) {
                for y in stride(from: yMin, to: yMax, by: gridSize) {
                    for z in stride(from: zMin, to: zMax, by: gridSize) {
                        var count = 0
                        for bot in bots {
                            let xDiff = (bot.position.x - x)
                            let yDiff = (bot.position.y - y)
                            let zDiff = (bot.position.z - z)
                            let distance = abs(xDiff) + abs(yDiff) + abs(zDiff)
                            if distance - bot.signalRadius < gridSize {
                                count += 1
                            }
                        }
                        
                        if maxCount < count {
                            maxCount = count
                            bestGrid = (x, y, z)
                        } else if maxCount == count {
                            if bestGrid == nil || manhattanDistance(x: x, y: y, z: z) < manhattanDistance(x: bestGrid?.x ?? 0, y: bestGrid?.y ?? 0, z: bestGrid?.z ?? 0) {
                                bestGrid = (x, y, z)
                            }
                        }
                    }
                }
            }
            
            xMin = bestGrid?.x ?? 0 - gridSize
            xMax = bestGrid?.x ?? 0 + gridSize
            
            yMin = bestGrid?.y ?? 0 - gridSize
            yMax = bestGrid?.y ?? 0 + gridSize
            
            zMin = bestGrid?.z ?? 0 - gridSize
            zMax = bestGrid?.z ?? 0 + gridSize
            
            gridSize = Int(floor(Double(gridSize) / 2.0))
        }
        
        return manhattanDistance(x: bestGrid!.x, y: bestGrid!.y, z: bestGrid!.z)
    }
    
    func manhattanDistance(x: Int, y: Int, z: Int) -> Int {
        return abs(x) + abs(y) + abs(z)
    }
    
}

let input = """
pos=<0,0,0>, r=4
pos=<1,0,0>, r=1
pos=<4,0,0>, r=3
pos=<0,2,0>, r=1
pos=<0,5,0>, r=3
pos=<0,0,3>, r=1
pos=<1,1,1>, r=1
pos=<1,1,2>, r=1
pos=<1,3,1>, r=1
"""

let botFinder = BotFinder(filename: "input")
let largestSignalBot = botFinder.botWithLargestSignal
let numberOfBotsWithinRange = botFinder.numberOfBotsWithinRange(of: largestSignalBot)
// 595

botFinder.part2()
// 28479189 too low
//: [Next](@next)
