//: [Previous](@previous)

import Foundation

// Day 8
struct Node {
    private let children: [Node]
    private let metadata: [Int]
    
    var metadataSum: Int {
        var sum = metadata.reduce(0, +)
        sum += children.map {
            $0.metadataSum
        }.reduce(0, +)
        return sum
    }
    
    var value: Int {
        if children.isEmpty {
            return metadataSum
        } else {
            var value = 0
            for entry in metadata {
                if entry <= children.count {
                    value += children[entry - 1].value
                }
            }
            return value
        }
    }
    
    init(filename: String) {
        let string = Node.stringFromFilename(filename).replacingOccurrences(of: "\n", with: "")
        var numbers = string.split(separator: " ").map { Int($0)! }
        self.init(numbers: &numbers)
    }
    
    private init(numbers: inout [Int]) {
        // The first two numbers of metadata
        // within a node are the quantities of
        // children and metadata
        let childQuantity = numbers.removeFirst()
        let metadataQuantity = numbers.removeFirst()
        
        // Create children with remaining header
        // information
        var children = [Node]()
        for _ in 0..<childQuantity {
            children.append(Node(numbers: &numbers))
        }
        
        // Create metadata with remaining header
        // information
        var metadata = [Int]()
        for _ in 0..<metadataQuantity {
            metadata.append(numbers.removeFirst())
        }
        
        self.children = children
        self.metadata = metadata
    }
    
    private static func stringFromFilename(_ filename: String) -> String {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        return (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    }
}


let tree = Node(filename: "input")
let metadataSum = tree.metadataSum
metadataSum // 41555

let value = tree.value
value // 16653

//: [Next](@next)
