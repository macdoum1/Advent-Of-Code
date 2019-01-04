//: [Previous](@previous)

import Foundation

extension String {
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

struct Group {
    let number: Int
    let unitCount: Int
    let hitPoints: Int
    let attackDamage: Int
    let attackType: String
    let initiative: Int
    let weaknesses: [String]
    let immunities: [String]
    
    var effectivePower: Int {
        return unitCount * attackDamage
    }
}

struct Simulator {
    var immuneSystemGroups: [Group]
    var infectionGroups: [Group]
    
    func fight() {
        for group in infectionGroups {
            for targetOfImmuneSystem in selectTargetsFrom(infectionGroups) {
                let potentialDamage = calculateDamage(attacker: targetOfImmuneSystem, target: group)
                print("Immune system group \(targetOfImmuneSystem.number) would deal defending group \(group.number) \(potentialDamage) damage")
            }
        }
        
        for group in infectionGroups {
            for targetOfInfection in selectTargetsFrom(immuneSystemGroups) {
                let potentialDamage = calculateDamage(attacker: targetOfInfection, target: group)
                print("Infection group \(targetOfInfection.number) would deal defending group \(group.number) \(potentialDamage) damage")
            }
        }
    }
    
    private func selectTargetsFrom(_ fromGroups: [Group]) -> [Group] {
//        let maxEffectivePower = fromGroups.max { (groupA, groupB) -> Bool in
//            return groupA.effectivePower < groupB.effectivePower
//        }!.effectivePower
//
//        let groupsWithMaxEffectivePower = fromGroups.filter { (group) -> Bool in
//            return group.effectivePower == maxEffectivePower
//        }
        
        let groupsWithSortedPower = fromGroups.sorted { (groupA, groupB) -> Bool in
            return groupA.effectivePower < groupB.effectivePower
        }
        
        let groupsSortedByInitiative = groupsWithSortedPower.sorted { (groupA, groupB) -> Bool in
            groupA.initiative < groupB.initiative
        }
        
        return groupsSortedByInitiative
    }
    
    private func calculateDamage(attacker: Group, target: Group) -> Int {
        if target.immunities.contains(attacker.attackType) {
            return 0
        }
        
        if target.weaknesses.contains(attacker.attackType) {
            return attacker.effectivePower * 2
        }
        
        return attacker.effectivePower
    }
    
    func printState() {
        print("Immune System:")
        printDescriptionForGroups(immuneSystemGroups)
        
        print("Infection:")
        printDescriptionForGroups(infectionGroups)
    }
    
    private func printDescriptionForGroups(_ groups: [Group]) {
        for group in groups {
            print("Group \(group.number) contains \(group.unitCount)")
        }
    }
}

let immuneSystemGroups: [Group] = [
    Group(number: 1, unitCount: 17, hitPoints: 5390, attackDamage: 4507, attackType: "fire", initiative: 2, weaknesses: ["radiation", "bludgeoning"], immunities: []),
    Group(number: 2, unitCount: 989, hitPoints: 1274, attackDamage: 25, attackType: "slashing", initiative: 3, weaknesses: ["bludgeoning"], immunities: ["fire"]),
]

let infectionGroups: [Group] = [
    Group(number: 1, unitCount: 801, hitPoints: 4706, attackDamage: 116, attackType: "bludgeoning", initiative: 1, weaknesses: ["radiation"], immunities: []),
    Group(number: 2, unitCount: 4485, hitPoints: 2961, attackDamage: 12, attackType: "slashing", initiative: 4, weaknesses: ["fire"], immunities: ["radiation"]),
]

let sim = Simulator(immuneSystemGroups: immuneSystemGroups, infectionGroups: infectionGroups)
sim.printState()
sim.fight()





//: [Next](@next)
