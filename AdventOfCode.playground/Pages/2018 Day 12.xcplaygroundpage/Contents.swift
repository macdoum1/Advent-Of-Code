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

struct Tunnel {
    class Node {
        var previous: Node?
        var next: Node?
        let containsPlant: Bool
        init(containsPlant: Bool, previous: Node?=nil, next: Node?=nil) {
            self.containsPlant = containsPlant
            self.previous = previous
            self.next = next
        }
    }
    
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
        
        var lastSum = 0
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
            
            let sum = Tunnel.getSumOfPotIndices(state: lastState, generation: i+1)
            print("Diff: \(sum - lastSum)")
            lastSum = sum
            print("Sum: \(sum) at generation \(i+1)")
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

//let tunnel = Tunnel(string: input)
//print(Tunnel.stateToString(tunnel.initialState))

//
//print(Tunnel.stateToString(state))


// The slope of the line at some point is 32
// using an existing point we can determine the sum
// at a distant generation
// Example output at high generations:
/*
 Sum: 111505 at generation 3471
 Diff: 32
 Sum: 111537 at generation 3472
 Diff: 32
 Sum: 111569 at generation 3473
 Diff: 32
 Sum: 111601 at generation 3474
 Diff: 32
 Sum: 111633 at generation 3475
 Diff: 32
 Sum: 111665 at generation 3476
 Diff: 32
 Sum: 111697 at generation 3477
 Diff: 32
 Sum: 111729 at generation 3478
 */
let generation = 50000000000
let result = (generation - 644) * 32 + 21009
print(result)

let tunnel = Tunnel(string: input)
let state = tunnel.stateAfterGeneration(generation)
print(Tunnel.getSumOfPotIndices(state: state, generation: generation))


// 1600000000401
// 1599999975919 too low
// 1600000000433 too high
// 1600000000465 too high

//: [Next](@next)
