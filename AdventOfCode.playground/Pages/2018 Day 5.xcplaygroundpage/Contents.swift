//: [Previous](@previous)

import Foundation

// Day 5

// *** Shared ***
func polymerStringFromFilename(_ filename: String ) -> String {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let string = (try? String(contentsOf: fileURL!, encoding: .utf8))?.replacingOccurrences(of: "\n", with: "") ?? ""
    return string.replacingOccurrences(of: "\n", with: "")
}

struct Polymer {
    static let allComponentTypes = "abcdefghijklmnopqrstuvwxyz"
    static var possiblePairs: [String] = {
        var possiblePairs = [String]()
        for char in allComponentTypes {
            let lower = "\(char)"
            let upper = lower.uppercased()
            
            possiblePairs.append("\(lower)\(upper)")
            possiblePairs.append("\(upper)\(lower)")
        }
        return possiblePairs
    }()
    
    static func componentsAfterReacting(_ components: String) -> String {
        var startingComponents = components
        var remainingComponents = Polymer.componentsAfterReactingOnce(startingComponents)
        while startingComponents.count != remainingComponents.count {
            startingComponents = remainingComponents
            remainingComponents = Polymer.componentsAfterReactingOnce(startingComponents)
        }
        return remainingComponents
    }
    
    private static func componentsAfterReactingOnce(_ components: String) -> String {
        var remainingComponents = components
        
        for pair in possiblePairs {
            remainingComponents = remainingComponents.replacingOccurrences(of: pair, with: "")
        }
        
        return remainingComponents
    }
}

// *** Part 1 ***
func part1() -> Int {
    let components = polymerStringFromFilename("input-pt1")
    return Polymer.componentsAfterReacting(components).count
}
part1() // 11894

// *** Part 2 ***
func part2() -> Int {
    let components = polymerStringFromFilename("input-pt1")
    let componentsAfterReaction = Polymer.componentsAfterReacting(components)
    var min = componentsAfterReaction.count
    for char in Polymer.allComponentTypes {
        var filteredComponents = componentsAfterReaction.replacingOccurrences(of: "\(char)", with: "")
        filteredComponents = filteredComponents.replacingOccurrences(of: "\(char)".uppercased(), with: "")
        let componentsLeft = Polymer.componentsAfterReacting(filteredComponents)
        let componentsLeftCount = componentsLeft.count
        if componentsLeftCount < min {
            min = componentsLeftCount
        }
    }
    return min
}
part2() // 5310
//: [Next](@next)
