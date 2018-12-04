//: [Previous](@previous)

import Foundation

// Day 4
//

/// *** Shared ***
struct GuardUpdate {
    enum Action {
        case guardChanged
        case fallAsleep
        case wakesUp
    }
    
    let action: Action
    let timestamp: Date
    var guardId: Int!
    var isSleepChange: Bool {
        return action == .wakesUp || action == .fallAsleep
    }
    
    init(string: String) {
        action = GuardUpdate.actionFromString(string)
        timestamp = GuardUpdate.dateFromString(string)
        guardId = GuardUpdate.guardIdFromString(string)
    }
    
    private static func actionFromString(_ string: String) -> Action {
        if string.contains("begins shift") {
            return .guardChanged
        } else if string.contains("wakes up") {
            return .wakesUp
        } else {
            return .fallAsleep
        }
    }
    
    private static func dateFromString(_ string: String) -> Date {
        var sanitizedString = string.replacingOccurrences(of: "[", with: "")
        sanitizedString = String(sanitizedString.split(separator: "]").first!)
        //[1518-11-01 00:00
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return formatter.date(from: sanitizedString)!
    }
    
    private static func guardIdFromString(_ string: String) -> Int? {
        guard GuardUpdate.actionFromString(string) == .guardChanged else { return nil }
        let components = string.split(separator: " ")
        var guardId = String(components[3])
        guardId = guardId.replacingOccurrences(of: "#", with: "")
        return Int(guardId)
    }
}

struct SleepRange {
    let start: Date
    let end: Date
    let guardId: Int
    
    var numberOfMinutes: Int {
        return Int(end.timeIntervalSince(start)/60)
    }
}

extension Date {
    var minute: Int {
        let cal = Calendar.current
        return cal.component(.minute, from: self)
    }
}

func updatesFromFilename(_ filename: String) -> [GuardUpdate] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let content = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    let splitStrings: [String] = content.split(separator: "\n").compactMap { return String($0) }
    
    var updates: [GuardUpdate] = []
    for string in splitStrings {
        let update = GuardUpdate(string: string)
        updates.append(update)
    }
    return updates
}

var updates = updatesFromFilename("input-pt1").sorted { (updateA, updateB) -> Bool in
    return updateA.timestamp < updateB.timestamp
}

var lastGuardId: Int? = updates.first?.guardId

updates = updates.map({ (update) -> GuardUpdate in
    if let guardId = update.guardId {
        lastGuardId = guardId
    }
    
    var newUpdate = update
    newUpdate.guardId = lastGuardId
    return newUpdate
})
// *** Part 1 ***
let sleepUpdates = updates.filter { $0.isSleepChange }

sleepUpdates

sleepUpdates.count

let sleepRanges = stride(from: 0, to: sleepUpdates.count-1, by: 2).compactMap { (i) -> SleepRange? in
    let start = sleepUpdates[i]
    let end = sleepUpdates[i+1]
    
    guard start.action == .fallAsleep, end.action == .wakesUp else { return nil }
    
    
    return SleepRange(start: start.timestamp, end: end.timestamp, guardId: start.guardId)
}
sleepRanges
sleepRanges.count

let sleepRangesByGuard: [Int: [SleepRange]] = Dictionary(grouping: sleepRanges, by: { $0.guardId })
sleepRangesByGuard
sleepRangesByGuard.count

let sleepTimeByGuard = sleepRangesByGuard.mapValues { (sleepRanges) -> Int in
    return sleepRanges.map { $0.numberOfMinutes }.reduce(0, +)
}
sleepRangesByGuard.count

let guardWithLongestSleepTime = sleepTimeByGuard.max { (a, b) -> Bool in
    return a.value < b.value
}!.key

guardWithLongestSleepTime

let sleepRangesForGuardWithLongestSleepTime = sleepRangesByGuard[guardWithLongestSleepTime]!

var minuteToCountMap = [Int: Int]()
for sleepRange in sleepRangesForGuardWithLongestSleepTime {
    let start = sleepRange.start.minute
    let end = sleepRange.end.minute
    for i in start..<end {
        let count = minuteToCountMap[i] ?? 0
        minuteToCountMap[i] = count + 1
    }
}

minuteToCountMap

sleepRangesForGuardWithLongestSleepTime

let mostSleptAtMinuteForSleepiestGuard = minuteToCountMap.max { (a, b) -> Bool in
    return a.value < b.value
}!.key

mostSleptAtMinuteForSleepiestGuard

let result = guardWithLongestSleepTime * mostSleptAtMinuteForSleepiestGuard

result
// *** Part 2 ***

var sameMinuteGuard: (guardId: Int, minute: Int, countForMinute: Int) = (0, 0, 0)
for (guardId, sleepRanges) in sleepRangesByGuard {
    var minuteToCountMap = [Int: Int]()
    for sleepRange in sleepRanges {
        let start = sleepRange.start.minute
        let end = sleepRange.end.minute
        for i in start..<end {
            let count = minuteToCountMap[i] ?? 0
            minuteToCountMap[i] = count + 1
        }
    }
    let mostSleepMinuteForGuard = minuteToCountMap.max { (a, b) -> Bool in
        return a.value < b.value
    }!
    
    if mostSleepMinuteForGuard.value > sameMinuteGuard.countForMinute {
        sameMinuteGuard = (guardId, mostSleepMinuteForGuard.key, mostSleepMinuteForGuard.value)
    }
}

let pt2Result = sameMinuteGuard.minute * sameMinuteGuard.guardId
pt2Result







