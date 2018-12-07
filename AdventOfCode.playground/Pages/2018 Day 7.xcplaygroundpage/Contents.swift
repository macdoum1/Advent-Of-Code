//: [Previous](@previous)

import Foundation

// Day 7

// *** Shared ***
struct SleighKit {
    /// This contains map of all verticies to the verticies
    /// which are connected
    /// C: A,F
    /// D: E
    /// A: B, D
    /// F: E
    /// B: E
    private let adjacencyList: [String: Set<String>]
    private let allVerticies: Set<String>
    
    typealias Dependency = (dependency: String, dependent: String)
    
    init(filename: String) {
        let dependencies = SleighKit.depedenciesFromFilename(filename)
        
        var tempAllVerticies = Set<String>()
        var tempAdjacencyList = [String: Set<String>]()
        for dependency in dependencies {
            tempAdjacencyList[dependency.dependency,
                              default: Set<String>()].insert(dependency.dependent)
            tempAllVerticies.insert(dependency.dependency)
            tempAllVerticies.insert(dependency.dependent)
        }
        adjacencyList = tempAdjacencyList
        adjacencyList
        
        allVerticies = tempAllVerticies
        allVerticies
    }
    
    private static func linesFromFilename(_ filename: String) -> [String] {
        filename
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        fileURL
        let string = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
        return string.split(separator: "\n").map { String($0) }
    }
    
    private static func depedenciesFromFilename(_ filename: String) -> [Dependency] {
        let lines = linesFromFilename(filename)
        
        return lines.map({ (line) -> Dependency in
            let components = line.split(separator: " ").map { String($0) }
            return (components[1], components[7])
        })
    }
    
    func getOrderOfSteps() -> String {
        var order = [String]()
        
        let verticiesWithNoDependencies = allVerticies.filter { (vertex) -> Bool in
            var isInList = false
            for set in adjacencyList.values {
                if set.contains(vertex) {
                    isInList = true
                }
            }
            return !isInList
        }
        
        var availableVertices = verticiesWithNoDependencies
        var currentVertex: String!
        while order.count != allVerticies.count {
            print("Available vertices:\(availableVertices)")
            currentVertex = Array(availableVertices).sorted { $0 < $1 }.first!
            print("Chose \(currentVertex)")
            
            order.append(currentVertex)
            availableVertices.remove(currentVertex)
            
            if let set = adjacencyList[currentVertex] {
                for vertex in set {
                    // Only insert if all dependencies have completed
                    let dependencies = getDependenciesOfVertex(vertex)
                    let dependenciesUncompleted = dependencies.filter { !order.contains($0) }.count
                    if dependenciesUncompleted == 0 {
                        availableVertices.insert(vertex)
                    }
                }
            }
        }

        var orderString = ""
        for vertex in order {
            orderString.append(vertex)
        }
        return orderString
    }
    
    private func getDependenciesOfVertex(_ vertex: String) -> [String] {
        let keys = adjacencyList.filter({ (row) -> Bool in
            return row.value.contains(vertex)
        }).keys
        
        return Array(keys)
    }
}

let sleighKit = SleighKit(filename: "input")
print(sleighKit.getOrderOfSteps())



//: [Next](@next)
