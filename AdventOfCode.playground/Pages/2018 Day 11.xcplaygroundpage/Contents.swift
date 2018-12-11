//: [Previous](@previous)

import Foundation

struct Grid {
    typealias Position = (x: Int, y: Int)
//    struct FuelCell {
//        let
//    }
    private static let min = 1
    private static let max = 300
    let serialNumber: Int
    

    func powerLevelAtPosition(position: Position) -> Int {
        let rackId = position.x + 10
        let step1 = rackId * position.y
        let step2 = step1 + serialNumber
        let step3 = step2 * rackId
        let step4 = step3 / 100 % 10
        return step4 - 5
    }
    
    func getPositionOfMaxPowerLevel() -> Position {
        var max = 0
        var position = (-1, -1)
        for x in stride(from: Grid.min, to: Grid.max, by: 1) {
            for y in stride(from: Grid.min, to: Grid.max, by: 1) {
                let positions = [
                    (x, y),
                    (x, y+1),
                    (x, y+2),
                    (x+1, y),
                    (x+1, y+1),
                    (x+1, y+2),
                    (x+2, y),
                    (x+2, y+1),
                    (x+2, y+2),
                ]
                let power = positions.map {
                    return powerLevelAtPosition(position: $0)
                }.reduce(0, +)
                if power > max {
                    max = power
                    position = (x, y)
                }
            }
        }
        print(max)
        return position
    }
    
}


let grid = Grid(serialNumber: 7989)
let position = grid.getPositionOfMaxPowerLevel()
print(position)
//let power = grid.powerLevelAtPosition(x: 101, y: 153)
//power
//: [Next](@next)
