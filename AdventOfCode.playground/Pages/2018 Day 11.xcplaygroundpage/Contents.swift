//: [Previous](@previous)

import Foundation

struct Grid {
    private static let min = 1
    private static let max = 300
    let serialNumber: Int
    
    func powerLevelAtPosition(x: Int, y: Int) -> Int {
        let rackId = x + 10
        let step1 = rackId * y
        let step2 = step1 + serialNumber
        let step3 = step2 * rackId
        let step4 = step3 / 100 % 10
        return step4 - 5
    }
    
    func getPositionOfMaxPower(size: Int) -> (x: Int, y: Int, size: Int) {
        return getPositionOfMaxPower(minSize: size, maxSize: size)
    }
    
    func getPositionOfMaxPower(minSize: Int = Grid.min, maxSize: Int = Grid.max) -> (x: Int, y: Int, size: Int) {
        var partials = Array(repeating: Array(repeating: 0, count: Grid.max+1), count: Grid.max+1)
        for x in Grid.min...Grid.max {
            for y in Grid.min...Grid.max {
                let power = powerLevelAtPosition(x: x, y: y)
                let partial1 = partials[x][y-1]
                let partial2 = partials[x-1][y]
                let partial3 = partials[x-1][y-1]
                partials[x][y] = power + partial1 + partial2 - partial3
            }
        }
        
        var maxPower = 0
        var position = (-1, -1, -1)
        
        for size in minSize...maxSize {
            for x in size...Grid.max {
                for y in size...Grid.max {
                    let power = partials[x][y]
                    let partial1 = partials[x-size][y]
                    let partial2 = partials[x][y-size]
                    let partial3 = partials[x-size][y-size]
                    let totalPower = power - partial1 - partial2 + partial3
                    if totalPower > maxPower {
                        maxPower = totalPower
                        let positionX = x - size + 1
                        let positionY = y - size + 1
                        position = (positionX, positionY, size)
                    }
                }
            }
        }
        return position
    }
}

func part1() {
    let grid = Grid(serialNumber: 7989)
    let position = grid.getPositionOfMaxPower(size: 3)
    print(position)
}


func part2() {
    let grid = Grid(serialNumber: 7989)
    let position = grid.getPositionOfMaxPower(minSize: 1, maxSize: 300)
    print(position)
}

part1()
part2()

//: [Next](@next)
