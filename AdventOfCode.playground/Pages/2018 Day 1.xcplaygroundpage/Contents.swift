import UIKit

// Day 1
// https://adventofcode.com/2018/day/1

// *** Shared ***
func deltasFromFilename(_ filename: String) -> [Int] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let content = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    let deltaStrings = content.split(separator: "\n")
    return deltaStrings.compactMap { return Int($0) }
}

// *** Part 1 ***
var deltas = deltasFromFilename("input-pt1")
var frequency = 0
for delta in deltas {
    frequency += delta
}
frequency

// *** Part 2 ***
deltas = deltasFromFilename("input-pt2")
frequency = 0

var frequenciesReached = [Int: Bool]()

var duplicateFrequencyFound = false
var i = 0
while !duplicateFrequencyFound {
    let delta = deltas[(i % deltas.count + deltas.count) % deltas.count]
    frequency += delta
    
    if frequenciesReached[frequency] ?? false {
        duplicateFrequencyFound = true
    }
    
    frequenciesReached[frequency] = true
    
    i += 1
}
frequency
