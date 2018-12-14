//: [Previous](@previous)

import Foundation

// Day 14

struct RecipeBoard {
    private var recipeScores = [Int]()
    private var elf1Index = 0
    private var elf2Index = 1
    
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
        let integerArray = "\(sum)".compactMap{ Int(String($0)) }
        recipeScores.append(contentsOf: integerArray)
    }
    
    func printState() {
        print(recipeScores)
        print("Elf 1 Index \(elf1Index)")
        print("Elf 2 Index \(elf2Index)")
    }
    
    mutating func printTenRecipesAfterNRecipes(_ n: Int) {
        while recipeScores.count < n + 10 {
            generateNewRecipes()
//            printState()
        }
        
        
        
        let string = recipeScores[n..<n+10].map { String($0) }.joined()
        print(string)
    }
}

var recipeBoard = RecipeBoard(initialScores: [3, 7])
recipeBoard.printTenRecipesAfterNRecipes(147061)

// Not 1455811313
//: [Next](@next)
