//: [Previous](@previous)

import Foundation

// Day 14

struct RecipeBoard {
    private var recipeScores = [Int]()
    private var elf1Index = 0
    private var elf2Index = 1
    
    var sumToIntegerCache = [Int: [Int]]()
    
    init(initialScores: [Int]) {
        recipeScores = initialScores
    }
    
    mutating func generateNewRecipes() {
        let elf1Score = recipeScores[elf1Index]
        let elf2Score = recipeScores[elf2Index]
        
        addRecipeFromScores(elf1Score, elf2Score)
        
        let count = recipeScores.count
        elf1Index = (elf1Index+elf1Score+1) % count
        elf2Index = (elf2Index+elf2Score+1) % count
    }
    
    private mutating func addRecipeFromScores(_ score1: Int, _ score2: Int) {
        let sum = score1 + score2
        if sum >= 10 {
            recipeScores.append(sum / 10 % 10)
        }
        recipeScores.append(sum % 10)
    }
    
    func printState() {
        print(recipeScores)
        print("Elf 1 Index \(elf1Index)")
        print("Elf 2 Index \(elf2Index)")
    }
    
    mutating func printTenRecipesAfterNRecipes(_ n: Int) {
        while recipeScores.count < n + 10 {
            generateNewRecipes()
        }
        
        let string = recipeScores[n..<n+10].map { String($0) }.joined()
        print(string)
    }
    
    mutating func printHowManyRecipesBefore(target: Int) {
        var count = 0
        let targetIntArray = "\(target)".map { return Int(String($0))! }
        while isTargetPresentNearEndOfRecipeList(target: targetIntArray)  {
            generateNewRecipes()
            count = recipeScores.count - targetIntArray.count
            print(count)
        }
        
        if Array(recipeScores.suffix(targetIntArray.count)) == targetIntArray {
            print(count)
        } else {
            print(count - 1)
        }
    }
    
    // Since we can add to to two integers at once, we need to check
    // both states
    private func isTargetPresentNearEndOfRecipeList(target: [Int]) -> Bool {
        return Array(recipeScores.suffix(target.count)) != target &&
            Array(recipeScores.dropLast().suffix(target.count)) != target
    }
}

// Part 1
var recipeBoard = RecipeBoard(initialScores: [3, 7])
////recipeBoard.printTenRecipesAfterNRecipes(2018)
//
//// Part 2
recipeBoard.printHowManyRecipesBefore(target: 147061)
// Not 71764232 too high
// Not 71764231 too high
//     20283721
//: [Next](@next)
