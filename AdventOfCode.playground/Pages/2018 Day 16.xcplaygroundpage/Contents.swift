//: [Previous](@previous)

import Foundation

extension Bool { var intValue: Int { return self ? 1 : 0 } }

enum Opcode: String, CaseIterable {
    case addRegister = "addr"
    case addImmediate = "addi"
    case multiplyRegister = "mulr"
    case multipleImmediate = "muli"
    case bitwiseANDRegister = "banr"
    case bitwiseANDImmediate = "bani"
    case bitwiseORRegister = "borr"
    case bitwiseORImmediate = "bori"
    case setRegister = "setr"
    case setImmediate = "seti"
    case greaterThanImmediateRegister = "gtir"
    case greaterThanRegisterImmediate = "gtri"
    case greaterThanRegisterRegister = "gtrr"
    case equalImmediateRegister = "eqir"
    case equalRegisterImmediate = "eqri"
    case equalRegisterRegister = "eqrr"
}

struct Instruction {
    let opcode: Opcode
    let A: Int
    let B: Int
    let C: Int
    
    /// Performs instruction with given registers
    /// Returns: Resulting registers
    func perform(initialRegisters: [Int]) -> [Int] {
        var registers = initialRegisters
        switch opcode {
        case .addRegister:
            registers[C] = registers[A] + registers[B]
        case .addImmediate:
            registers[C] = registers[A] + B
        case .multiplyRegister:
            registers[C] = registers[A] * registers[B]
        case .multipleImmediate:
            registers[C] = registers[A] * B
        case .bitwiseANDRegister:
            registers[C] = registers[A] & registers[B]
        case .bitwiseANDImmediate:
            registers[C] = registers[A] & B
        case .bitwiseORRegister:
            registers[C] = registers[A] | registers[B]
        case .bitwiseORImmediate:
            registers[C] = registers[A] | B
        case .setRegister:
            registers[C] = registers[A] // B is ignored
        case .setImmediate:
            registers[C] = A
        case .greaterThanImmediateRegister:
            registers[C] = (A > registers[B]).intValue
        case .greaterThanRegisterImmediate:
            registers[C] = (registers[A] > B).intValue
        case .greaterThanRegisterRegister:
            registers[C] = (registers[A] > registers[B]).intValue
        case .equalImmediateRegister:
            registers[C] = (A == registers[B]).intValue
        case .equalRegisterImmediate:
            registers[C] = (registers[A] == B).intValue
        case .equalRegisterRegister:
            registers[C] = (registers[A] == registers[B]).intValue
        }
        return registers
    }
}

struct Sample {
    let initialRegisters: [Int]
    let opcode: Int
    let A: Int
    let B: Int
    let C: Int
    let afterRegisters: [Int]
    
    init(line1: String, line2: String, line3: String) {
        var santizedBefore = line1.replacingOccurrences(of: "Before: [", with: "")
        santizedBefore = santizedBefore.replacingOccurrences(of: "]", with: "")
        santizedBefore = santizedBefore.replacingOccurrences(of: " ", with: "")
        initialRegisters = santizedBefore.split(separator: ",").map {
            Int($0)!
        }
        
        let instructionComponents = line2.split(separator: " ").map { Int($0)! }
        opcode = instructionComponents[0]
        A = instructionComponents[1]
        B = instructionComponents[2]
        C = instructionComponents[3]
        
        var santizedAfter = line3.replacingOccurrences(of: "After:  [", with: "")
        santizedAfter = santizedAfter.replacingOccurrences(of: "]", with: "")
        santizedAfter = santizedAfter.replacingOccurrences(of: " ", with: "")
        afterRegisters = santizedAfter.split(separator: ",").map {
            Int($0)!
        }
    }
}

struct Parser {
    static func getSamplesFromInput(_ input: String) -> [Sample] {
        let chunks = input.components(separatedBy: "\n\n\n\n")
        let lines = chunks.first!.split(separator: "\n")
        return stride(from: 0, to: lines.count, by: 3).map { (i) -> Sample in
            let line1 = String(lines[i])
            let line2 = String(lines[i+1])
            let line3 = String(lines[i+2])
            return Sample(line1: line1, line2: line2, line3: line3)
        }
    }
    
    static func getRawInstructionsFromFilename(_ filename: String) -> [(opcode: Int, A: Int, B: Int, C: Int)] {
        let input = inputFromFilename(filename)
        let chunks = input.components(separatedBy: "\n\n\n\n")
        let lines = chunks[1].split(separator: "\n")
        return lines.map({ (line) -> (Int, Int, Int, Int) in
            let numbers = line.split(separator: " ").map { Int($0)! }
            return (numbers[0], numbers[1], numbers[2], numbers[3])
        })
    }
    
    static func getSamplesFromFilename(_ filename: String) -> [Sample] {
        let input = inputFromFilename(filename)
        return getSamplesFromInput(input)
    }
    
    private static func inputFromFilename(_ filename: String) -> String {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        return (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    }
}

let samples = Parser.getSamplesFromFilename("input")
//let input = """
//Before: [3, 2, 1, 1]
//9 2 1 2
//After:  [3, 2, 2, 1]
//"""
//let samples = Parser.getSamplesFromInput(input)

func part1() {
    let allOpcodes = Opcode.allCases
    var threePossibleOpcodeSum = 0
    for sample in samples {
        // Create instructions from all opcodes for sample
        let instructions = allOpcodes.map {
            Instruction(opcode: $0, A: sample.A, B: sample.B, C: sample.C)
        }
        
        // Perform all instructions and collect only ones
        // that match the output from the sample
        let outputs = instructions.filter {
            let output = $0.perform(initialRegisters: sample.initialRegisters)
            return output == sample.afterRegisters
        }
        
        if outputs.count >= 3 {
            threePossibleOpcodeSum += 1
        }
    }
    print(threePossibleOpcodeSum)
}

part1()
// 663

func part2() {
    // Start with all opcodes for each index
    var indicesToOpcodes = Array(repeating: Opcode.allCases, count: Opcode.allCases.count)
    
    // Iterate through all samples and remove the opcodes that don't
    // result in behavior described by sample
    for sample in samples {
        indicesToOpcodes[sample.opcode].removeAll { (opcode) -> Bool in
            let instruction = Instruction(opcode: opcode, A: sample.A, B: sample.B, C: sample.C)
            let output = instruction.perform(initialRegisters: sample.initialRegisters)
            return output != sample.afterRegisters
        }
    }
    
    // If any of the indices have a single opcode,
    // we know its correct
    var map = indicesToOpcodes.enumerated().reduce([Int: Opcode]()) { (result, value) -> [Int: Opcode] in
        var tempResult = result
        tempResult[value.offset] = value.element.count > 1 ? nil : value.element.first!
        return tempResult
    }
    
    var confirmedOpcodes = Array(map.values)
    
    // Now we'll iterate through `indicesToOpcodes` removing
    // confirmed opcodes until we have no more to remove
    // At the end of iteration the `map` should be built
    while let confirmedOpcode = confirmedOpcodes.popLast() {
        for index in 0..<indicesToOpcodes.count {
            indicesToOpcodes[index].removeAll { $0 == confirmedOpcode }
            if indicesToOpcodes[index].count == 1 {
                let newConfirmedOpcode = indicesToOpcodes[index].first!
                map[index] = newConfirmedOpcode
                confirmedOpcodes.append(newConfirmedOpcode)
            }
        }
    }
    
    let rawInstructions = Parser.getRawInstructionsFromFilename("input")
    
    let instructions = rawInstructions.map {
        Instruction(opcode: map[$0.opcode]!, A: $0.A, B: $0.B, C: $0.C)
    }
        
    var registers = [0, 0, 0, 0]
    for instruction in instructions {
        registers = instruction.perform(initialRegisters: registers)
    }
}

part2()
// [525, 3, 0, 525]

//: [Next](@next)
