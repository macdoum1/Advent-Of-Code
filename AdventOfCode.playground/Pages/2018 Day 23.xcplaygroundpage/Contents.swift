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
                print("excluded |\($0)|")
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
//: [Next](@next)
