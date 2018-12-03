//: [Previous](@previous)

import Foundation

// Day 3
// https://adventofcode.com/2018/day/3


// *** Shared ***
func claimStringsFromFilename(_ filename: String) -> [String] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let content = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    return content.split(separator: "\n").compactMap { return String($0) }
}

let claimStrings = claimStringsFromFilename("input-pt1")

struct Claim {
    let id: String
    let leftInset: Int
    let topInset: Int
    let width: Int
    let height: Int
    init(string: String) {
        var santizedString = string.replacingOccurrences(of: " @", with: "")
        santizedString = santizedString.replacingOccurrences(of: ",", with: " ")
        santizedString = santizedString.replacingOccurrences(of: ":", with: "")
        santizedString = santizedString.replacingOccurrences(of: "x", with: " ")
        let components = santizedString.split(separator: " ")
        
        id = String(components.first!)
        leftInset = Int(components[1])!
        topInset = Int(components[2])!
        width = Int(components[3])!
        height = Int(components[4])!
    }
}

struct FabricClaim {
    var claims: [Claim] = []
}

let claims = claimStrings.map { Claim(string: $0) }
let totalWidth = 1000
let totalHeight = 1000


// *** Part 1 ***
var fabric = Array(repeating: Array(repeating: 0, count: totalWidth), count: totalHeight)

for claim in claims {
    let xStart = claim.leftInset
    let xEnd = claim.leftInset + claim.width
    let yStart = claim.topInset
    let yEnd = claim.topInset + claim.height
    
    for x in xStart..<xEnd {
        for y in yStart..<yEnd {
            fabric[x][y] += 1
        }
    }
}

var count = 0
for x in 0...fabric.count-1 {
    let row = fabric[x]
    for y in 0...row.count-1 {
        if fabric[x][y] >= 2 {
            count += 1
        }
    }
}

count


// *** Part 2 ***



//: [Next](@next)
