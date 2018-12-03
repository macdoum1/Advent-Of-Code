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
var frequency = deltasFromFilename("input-pt1").reduce(0, +)

// *** Part 2 ***
let deltas = deltasFromFilename("input-pt2")
frequency = 0

var frequenciesReached = [Int: Bool]()
var i = 0
// Keep iterating until the current frequency has a true
// value within the map
while !(frequenciesReached[frequency] ?? false) {
    let delta = deltas[(i % deltas.count + deltas.count) % deltas.count]
    frequenciesReached[frequency] = true
    frequency += delta
    i += 1
}
frequency

//: [Next](@next)
