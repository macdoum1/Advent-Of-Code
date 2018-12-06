//: [Previous](@previous)

import Foundation
import UIKit

// Day 6

// *** Shared ***
extension Array where Element: Equatable {
    func indiciesWhere(_ filter: ((Element) -> Bool)) -> [Int] {
        return self.indices.filter {
            return filter(self[$0])
        }
    }
}

struct List {
    typealias Coordinate = (x: Int, y: Int)
    let coordinates: [Coordinate]
    let infiniteBoundingBox: (minX: Int, minY: Int, maxX: Int, maxY: Int)
    
    init(filename: String) {
        coordinates = List.coordinatesFromFilename(filename)
        
        let xValues = coordinates.map { $0.x }
        let yValues = coordinates.map { $0.y }
        
        infiniteBoundingBox = (xValues.min()!,
                               yValues.min()!,
                               xValues.max()!,
                               yValues.max()!)
    }
    
    func sizeOflargestNonInfiniteArea() -> Int {
        typealias Area = (size: Int, infinite: Bool)
        var areas: [Area] = Array(repeating: (0, false), count: coordinates.count)
        
        iterateMap { (x, y) in
            // We want to get the indicies of the coordinates
            // with the smallest manhattan distances
            let distances = manhattanDistancesFromCoordinate((x, y))
            let min = distances.min()!
            let indiciesAtMin = distances.indiciesWhere {
                $0 == min
            }
            
            // If there two or more coordinates at the minimum
            // they don't count
            if indiciesAtMin.count < 2 {
                let index = indiciesAtMin.first!
                if isCoordinateConsideringInfinite((x, y)) {
                    areas[index].infinite = true
                }
                areas[index].size += 1
            }
        }
        
        let nonInfiniteAreas = areas.filter { !$0.infinite }
        let nonInfiniteAreaSizes = nonInfiniteAreas.map { $0.size }
        return nonInfiniteAreaSizes.max() ?? -1
    }
    
    func sizeContainingRegionUnderLimit(_ limit: Int) -> Int {
        var size = 0
        iterateMap { (x, y) in
            let manhattanDistances = manhattanDistancesFromCoordinate((x, y))
            if manhattanDistances.reduce(0, +) < limit {
                size += 1
            }
        }
        return size
    }
    
    private static func coordinatesFromFilename(_ filename: String ) -> [(Int, Int)] {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        let string = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
        let lines = string.split(separator: "\n").map { return String($0) }
        return lines.map { (line) -> (Int, Int) in
            let coords = line.replacingOccurrences(of: " ", with: "").split(separator: ",")
            return (Int(coords.first!)!, Int(coords.last!)!)
        }
    }
    
    private func isCoordinateConsideringInfinite(_ coordinate: Coordinate) -> Bool {
        return coordinate.x == infiniteBoundingBox.minX ||
            coordinate.x == infiniteBoundingBox.maxX ||
            coordinate.y == infiniteBoundingBox.minY ||
            coordinate.y == infiniteBoundingBox.maxY
    }
    
    private func iterateMap(_ iterate: ((Int, Int) -> Void)) {
        for x in infiniteBoundingBox.minX...infiniteBoundingBox.maxX {
            for y in infiniteBoundingBox.minY...infiniteBoundingBox.maxY {
                iterate(x, y)
            }
        }
    }
    
    private func manhattanDistance(_ coordinateA: Coordinate,
                                   _ coordinateB: Coordinate) -> Int {
        return abs(coordinateA.x - coordinateB.x) + abs(coordinateA.y - coordinateB.y)
    }
    
    private func manhattanDistancesFromCoordinate(_ coordinateA: Coordinate) -> [Int] {
        return coordinates.map{ (coordinateB) -> Int in
            return manhattanDistance(coordinateA, coordinateB)
        }
    }
}

// *** Part 1 ***
let sizeOflargestNonInfiniteArea = List(filename: "test-input").sizeOflargestNonInfiniteArea()
print(sizeOflargestNonInfiniteArea)

// *** Part 2 ***
let sizeContainingRegionUnderLimit = List(filename: "test-input").sizeContainingRegionUnderLimit(32)
print(sizeContainingRegionUnderLimit)

//: [Next](@next)
