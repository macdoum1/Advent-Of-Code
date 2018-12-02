//: [Previous](@previous)

import Foundation

// Day 2
// https://adventofcode.com/2018/day/2

// *** Shared ***
func boxIdsFromFilename(_ filename: String) -> [String] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let content = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    return content.split(separator: "\n").compactMap { return String($0) }
}

// *** Part 1 ***
var boxIds = boxIdsFromFilename("input-pt1")

var twoTimeAppearances = 0
var threeTimeAppearances = 0

for boxId in boxIds {
    var characterToCountMap: [Character: Int] = [:]
    for letter in boxId {
        characterToCountMap[letter] = (characterToCountMap[letter] ?? 0) + 1
    }
    
    if characterToCountMap.values.contains(2) {
        twoTimeAppearances += 1
    }
    
    if characterToCountMap.values.contains(3) {
        threeTimeAppearances += 1
    }
}

twoTimeAppearances
threeTimeAppearances
let checksum = twoTimeAppearances * threeTimeAppearances

// *** Part 2 ***
boxIds = boxIdsFromFilename("input-pt2")

func countDisimilaritiesBetweenBoxIds(_ boxIdA: String,
                                      _ boxIdB: String) -> Int {
    return zip(boxIdA, boxIdB).filter({ (characterA, characterB) -> Bool in
        return characterA != characterB
    }).count
}

func findAlmostMatchingBoxIds(boxIds: [String]) -> (String, String)? {
    var almostMatchingBoxIds: (String, String)? = nil
    for a in 0...boxIds.count-1 {
        for b in a+1...boxIds.count-1 {
            let boxIdA = boxIds[a]
            let boxIdB = boxIds[b]
            if countDisimilaritiesBetweenBoxIds(boxIdA, boxIdB) == 1 {
                almostMatchingBoxIds = (boxIdA, boxIdB)
                break
            }
        }
        
        if almostMatchingBoxIds != nil {
            break
        }
    }
    return almostMatchingBoxIds
}

let almostMatchingBoxIds = findAlmostMatchingBoxIds(boxIds: boxIds)!

let indexOfMissingCharacter = almostMatchingBoxIds.0.indices.firstIndex { (index) -> Bool in
    return almostMatchingBoxIds.0[index] != almostMatchingBoxIds.1[index]
}

indexOfMissingCharacter

var matchingPartOfBoxId = almostMatchingBoxIds.0
matchingPartOfBoxId.remove(at: indexOfMissingCharacter!)

almostMatchingBoxIds.0
almostMatchingBoxIds.1
matchingPartOfBoxId

