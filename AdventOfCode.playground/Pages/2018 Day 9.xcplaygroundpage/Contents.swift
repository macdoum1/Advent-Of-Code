//: [Previous](@previous)

import Foundation

// Day 9
class Marble {
    var value: Int
    var previous: Marble?
    var next: Marble?
    init(value: Int, previous: Marble? = nil, next: Marble? = nil) {
        self.value = value
        self.previous = previous
        self.next = next
    }
    
    func appendMarbleWithValue(_ value: Int) -> Marble {
        let newMarble = Marble(value: value, previous: self, next: next)
        next?.previous = newMarble
        next = newMarble
        return newMarble
    }
    
    func removeNthPreviousMarble(_ nth: Int) -> Marble {
        var marbleToRemove: Marble = self
        for _ in 0..<nth {
            marbleToRemove = marbleToRemove.previous!
        }
        marbleToRemove.remove()
        return marbleToRemove
    }
    
    private func remove() {
        previous?.next = next
        next?.previous = previous
    }
}

struct Game {
    private struct ScoringRule {
        static let divisibleBy = 23
        static let marbleToRemove = 7
    }

    static func getMaxScore(numOfElves: Int, valueOfLastMarble: Int) -> Int {
        // Create first marble which creates a
        // circle with itself
        var currentMarble = Marble(value: 0)
        currentMarble.previous = currentMarble
        currentMarble.next = currentMarble
        
        var elfToScoreMap = [Int: Int]()
        
        var currentMarbleValue = 1
        while currentMarbleValue <= valueOfLastMarble {
            for i in 0..<numOfElves {
                if currentMarbleValue % ScoringRule.divisibleBy == 0 {
                    // Get the elf's current score
                    var currentScoreForElf = elfToScoreMap[i] ?? 0
                    
                    let marbleToRemove = currentMarble.removeNthPreviousMarble(ScoringRule.marbleToRemove)
                    
                    // Add both the removed marble and the current
                    // marble's score
                    currentScoreForElf += marbleToRemove.value
                    currentScoreForElf += currentMarbleValue
                    elfToScoreMap[i] = currentScoreForElf
                    
                    // Move the current marble pointer to
                    // the marble after the removed marble
                    currentMarble = marbleToRemove.next!
                } else {
                    currentMarble = currentMarble.next!.appendMarbleWithValue(currentMarbleValue)
                }
                
                currentMarbleValue += 1
            }
        }
        return elfToScoreMap.values.max() ?? 0
    }
}

//10 players; last marble is worth 1618 points: high score is 8317

let maxScore = Game.getMaxScore(numOfElves: 10, valueOfLastMarble: 1618)
print(maxScore)

//let maxScore = Game.getMaxScore(numOfElves: 431, valueOfLastMarble: 70950)
//print(maxScore)

//let maxScore = Game.getMaxScore(numOfElves: 431, valueOfLastMarble: 70950*100)
//print(maxScore)

//: [Next](@next)
