//: [Previous](@previous)

import Foundation

//let input = """
//initial state: #..#.#..##......###...###
//
//...## => #
//..#.. => #
//.#... => #
//.#.#. => #
//.#.## => #
//.##.. => #
//.#### => #
//#.#.# => #
//#.### => #
//##.#. => #
//##.## => #
//###.. => #
//###.# => #
//####. => #
//"""

let input = """
initial state: ##.####..####...#.####..##.#..##..#####.##.#..#...#.###.###....####.###...##..#...##.#.#...##.##..

##.## => #
....# => .
.#.#. => #
..### => .
##... => #
##### => .
###.# => #
.##.. => .
..##. => .
...## => #
####. => .
###.. => .
.#### => #
#...# => #
..... => .
..#.. => .
#..## => .
#.#.# => #
.#.## => #
.###. => .
##..# => .
.#... => #
.#..# => #
...#. => .
#.#.. => .
#.... => .
##.#. => .
#.### => .
.##.# => .
#..#. => #
..#.# => .
#.##. => #
"""

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct Tunnel {
    struct Rule {
        /// Always 5 long
        let sequence: [Bool]
        let producesPlant: Bool
        init(line: String) {
            let components = line.split(separator: " ")
            
            sequence = components[0].map({ (character) -> Bool in
                return character == "#"
            })
            
            producesPlant = components[2] == "#"
        }
    }
    static let padding = 1
    
    let rules: [Rule]
    let initialState: [Bool]
    
    init(string: String) {
        let lines = string.split(separator: "\n")
        
        // Get initial state from string and map into bool array
        let initialStateString = String(lines[0].split(separator: " ")[2])
        initialState = initialStateString.map { (character) -> Bool in
            return character == "#"
        }
        
        rules = (1..<lines.count).map({ (i) -> Rule in
            return Rule(line: String(lines[i]))
        })
    }
    
    func stateAfterGeneration(_ generation: Int) -> [Bool] {
        var lastState = initialState
        
        for i in 0..<generation {
            lastState.insert(contentsOf: Array(repeating: false, count: Tunnel.padding), at: 0)
            lastState.append(contentsOf: Array(repeating: false, count: Tunnel.padding))
            
            var indicesToUpdate = [Int: Bool]()
            for (potIndex, pot) in lastState.enumerated() {
                let left2 = lastState[safe: potIndex-2] ?? false
                let left1 = lastState[safe: potIndex-1] ?? false
                let right1 = lastState[safe: potIndex+1] ?? false
                let right2 = lastState[safe: potIndex+2] ?? false
                let sequence = [left2, left1, pot, right1, right2]
                if let match = rules.first(where: { (rule) -> Bool in
                    rule.sequence == sequence
                }) {
                    indicesToUpdate[potIndex] = match.producesPlant
                }
            }
            
            // Apply changes for next generation
            var newState = Array.init(repeating: false, count: lastState.count)
            for (index, producePlant) in indicesToUpdate {
                newState[index] = producePlant
            }
            
            // Assign new state
            lastState = newState
            
            print(i)
        }
        
        return lastState
    }
    
    static func stateToString(_ state: [Bool]) -> String {
        return String(state.map({ (containsPlant) -> Character in
            return containsPlant ? "#" : "."
        }))
    }
    
    static func getSumOfPotIndices(state: [Bool], generation: Int) -> Int {
        let indexOfPots = state.enumerated().compactMap { (value) -> Int? in
            if value.element {
                // Need to subtract left padding added for each generation
                return value.offset - generation * Tunnel.padding
            } else {
                return nil
            }
        }
        
        return indexOfPots.reduce(0, +)
    }
    
}

let tunnel = Tunnel(string: input)
print(Tunnel.stateToString(tunnel.initialState))


let generation = 20
let stateAfter20 = tunnel.stateAfterGeneration(generation)
print(Tunnel.stateToString(stateAfter20))
print(Tunnel.getSumOfPotIndices(state: stateAfter20, generation: generation))


//: [Next](@next)
