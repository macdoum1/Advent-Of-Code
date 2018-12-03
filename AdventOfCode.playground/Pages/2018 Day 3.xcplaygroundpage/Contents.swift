//: [Previous](@previous)

import Foundation

// Day 3
// https://adventofcode.com/2018/day/3

// *** Shared ***
struct Claim {
    let id: String
    private let leftInset: Int
    private let topInset: Int
    private let width: Int
    private let height: Int
    
    var xStart: Int {
        return leftInset
    }
    
    var xEnd: Int {
        return leftInset + width
    }
    
    var yStart: Int {
        return topInset
    }
    
    var yEnd: Int {
        return topInset + height
    }
    
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

func claimsFromFilename(_ filename: String) -> [Claim] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let content = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    return content.split(separator: "\n").compactMap { return Claim(string: String($0)) }
}

var claims = claimsFromFilename("input-pt1")
let totalWidth = 1000
let totalHeight = 1000

// *** Part 1 ***
var fabric = Array(repeating: Array(repeating: 0, count: totalWidth), count: totalHeight)

for claim in claims {
    for x in claim.xStart..<claim.xEnd {
        for y in claim.yStart..<claim.yEnd {
            fabric[x][y] += 1
        }
    }
}

var squareInchesOverlapped = 0
for (_, row) in fabric.enumerated() {
    for (_, value) in row.enumerated() {
        if value >= 2 {
            squareInchesOverlapped += 1
        }
    }
}
squareInchesOverlapped

// *** Part 2 ***
claims = claimsFromFilename("input-pt2")

var fabricWithIds = Array(repeating: Array(repeating: "", count: totalWidth), count: totalHeight)
var intersectedClaimIds = Set<String>()

for claim in claims {
    for x in claim.xStart..<claim.xEnd {
        for y in claim.yStart..<claim.yEnd {
            let existingId = fabricWithIds[x][y]
            
            if existingId != "" {
                intersectedClaimIds.insert(claim.id)
                intersectedClaimIds.insert(existingId)
            }
            
            fabricWithIds[x][y] = claim.id
        }
    }
}

let allClaimIds = Set<String>( claims.map { $0.id })
let nonIntersectedClaimIds = allClaimIds.subtracting(intersectedClaimIds)
//: [Next](@next)
