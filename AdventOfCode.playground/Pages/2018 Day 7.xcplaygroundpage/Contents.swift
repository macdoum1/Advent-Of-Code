//: [Previous](@previous)

import Foundation

// Day 7

// *** Shared ***
extension String {
    var alphabetPosition: Int {
        return Int(UnicodeScalar(self)?.value ?? UInt32(0)) - 64
    }
}

struct SleighKit {
    /// This contains map of all vertices to the vertices
    /// which are connected
    /// C: A,F
    /// D: E
    /// A: B, D
    /// F: E
    /// B: E
    private let adjacencyList: [String: Set<String>]
    private let allVertices: Set<String>
    
    typealias Dependency = (from: String, to: String)
    
    init(filename: String) {
        let dependencies = SleighKit.depedenciesFromFilename(filename)
        
        var tempAllVertices = Set<String>()
        var tempAdjacencyList = [String: Set<String>]()
        for dependency in dependencies {
            tempAdjacencyList[dependency.to,
                              default: Set<String>()].insert(dependency.from)
            tempAllVertices.insert(dependency.from)
            tempAllVertices.insert(dependency.to)
        }
        adjacencyList = tempAdjacencyList
        adjacencyList
        
        allVertices = tempAllVertices
        allVertices
    }
    
    private static func linesFromFilename(_ filename: String) -> [String] {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
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
        var tempAdjacencyList = adjacencyList
        var availableVertices = getInitiallyAvailableVertices()

        var order = [String]()
        while let currentVertex = availableVertices.popLast() {
            print("Chose \(String(describing: currentVertex))")
            order.append(currentVertex)
            
            let adjustments = getAdjustmentsAfterReachingVertex(currentVertex,
                                                                adjList: tempAdjacencyList,
                                                                availableVertices: availableVertices)
            tempAdjacencyList = adjustments.adjacencyList
            availableVertices = adjustments.availableVertices
            
            print("Available vertices:\(availableVertices)")
        }

        var orderString = ""
        for vertex in order {
            orderString.append(vertex)
        }
        return orderString
    }
    
    struct Worker {
        var timeRemainingOnCurrentTask: Int = 0
        var currentVertex: String? = nil
        
        var isWorking: Bool {
            return currentVertex != nil
        }
        
        var shouldFinishTask: Bool {
            return timeRemainingOnCurrentTask <= 0 && isWorking
        }
    }
    
    func totalTimeToCompleteSteps(numOfWorkers: Int, timeToAddForEachStep: Int) -> Int {
        var tempAdjacencyList = adjacencyList
        var availableVertices = getInitiallyAvailableVertices()
        var workers = Array.init(repeating: Worker(), count: numOfWorkers)
        
        var time = 0
        var workersWithTimeRemaining = workers
        while !workersWithTimeRemaining.isEmpty {
            // Update workers as time elapses
            for (index, _) in workers.enumerated() {
                workers[index].timeRemainingOnCurrentTask -= 1
            }
            
            // Check if workers are able to finish task
            // at this point in time, if so update
            // data structures for next node
            for (index, _) in workers.enumerated() {
                if workers[index].shouldFinishTask {
                    let adjustments = getAdjustmentsAfterReachingVertex(workers[index].currentVertex!, adjList: tempAdjacencyList, availableVertices: availableVertices)
                    tempAdjacencyList = adjustments.adjacencyList
                    availableVertices = adjustments.availableVertices
                    workers[index].currentVertex = nil
                }
            }
            
            // If workers can take on another task, assign them
            for (index, worker) in workers.enumerated() {
                if worker.timeRemainingOnCurrentTask <= 0,
                    let currentVertex = availableVertices.popLast() {
                    let time = currentVertex.alphabetPosition + timeToAddForEachStep
                    workers[index] = Worker(timeRemainingOnCurrentTask: time,
                                            currentVertex: currentVertex)
                }
            }
            
            // If any of the workers have time remaining,
            // we should keep going, otherwise stop
            workersWithTimeRemaining = workers.filter { $0.timeRemainingOnCurrentTask > 0 }
            time += 1
        }
        return time - 1
    }
    
    private func getAdjustmentsAfterReachingVertex(_ vertex: String, adjList: [String: Set<String>], availableVertices: [String])
        -> (adjacencyList: [String: Set<String>], availableVertices: [String]) {
        var tempAdjacencyList = adjList
        var tempAvailableVertices = availableVertices
        for to in tempAdjacencyList.keys {
            tempAdjacencyList[to]!.remove(vertex)
            if tempAdjacencyList[to]!.isEmpty {
                tempAdjacencyList[to] = nil
                tempAvailableVertices.append(to)
            }
        }
        tempAvailableVertices.sort { $0 > $1 }
        return (tempAdjacencyList, tempAvailableVertices)
    }
    
    private func getInitiallyAvailableVertices() -> [String] {
        return allVertices.filter {
            !adjacencyList.keys.contains($0)
        }.sorted { $0 > $1 }
    }
    
    private func getDependenciesOfVertex(_ vertex: String) -> [String] {
        let keys = adjacencyList.filter({ (row) -> Bool in
            return row.value.contains(vertex)
        }).keys
        
        return Array(keys)
    }
}

let sleighKit = SleighKit(filename: "input")
//print(sleighKit.getOrderOfSteps())
print(sleighKit.totalTimeToCompleteSteps(numOfWorkers: 5, timeToAddForEachStep: 60))
// 253 is too low
//: [Next](@next)
