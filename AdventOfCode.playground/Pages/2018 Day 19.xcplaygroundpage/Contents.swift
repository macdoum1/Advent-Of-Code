//: [Previous](@previous)

import Foundation

let input = """
#ip 4
addi 4 16 4
seti 1 2 3
seti 1 6 1
mulr 3 1 2
eqrr 2 5 2
addr 2 4 4
addi 4 1 4
addr 3 0 0
addi 1 1 1
gtrr 1 5 2
addr 4 2 4
seti 2 8 4
addi 3 1 3
gtrr 3 5 2
addr 2 4 4
seti 1 4 4
mulr 4 4 4
addi 5 2 5
mulr 5 5 5
mulr 4 5 5
muli 5 11 5
addi 2 5 2
mulr 2 4 2
addi 2 18 2
addr 5 2 5
addr 4 0 4
seti 0 6 4
setr 4 8 2
mulr 2 4 2
addr 4 2 2
mulr 4 2 2
muli 2 14 2
mulr 2 4 2
addr 5 2 5
seti 0 1 0
seti 0 5 4
"""

//let input = """
//#ip 0
//seti 5 0 1
//seti 6 0 2
//addi 0 1 0
//addr 1 2 3
//setr 1 0 0
//seti 8 0 4
//seti 9 0 5
//"""

var lines = input.split(separator: "\n")

let ipRegister = Int(lines.removeFirst().replacingOccurrences(of: "#ip ", with: ""))!

let instructions = lines.map { (line) -> Instruction in
    var components = line.split(separator: " ")
    let opcode = Opcode(rawValue: String(components[0]))!
    let A = Int(components[1])!
    let B = Int(components[2])!
    let C = Int(components[3])!
    return Instruction(opcode: opcode, A: A, B: B, C: C)
}

func part1() {
    var registers = [0, 0, 0, 0, 0, 0]
    print("Initial")
    print(registers)

    var instructionPointer = 0

    while instructionPointer < instructions.count {
        // Load instruction pointer in register
        registers[ipRegister] = instructionPointer
        
        // Perform instrution
        let instruction = instructions[instructionPointer]
        print(instruction)
        registers = instruction.perform(initialRegisters: registers)
        
        // Load instruction pointer from register
        instructionPointer = registers[ipRegister]
        
        // Increment
        instructionPointer += 1
        
        print("IP: \(instructionPointer) Registers: \(registers)")
    }

    print("After")
    print(registers)
}

func part2() {
    var registers = [1, 0, 0, 0, 0, 0]
    var instructionPointer = 0
    while instructionPointer != 1 {
        // Load instruction pointer in register
        registers[ipRegister] = instructionPointer
        
        // Perform instrution
        let instruction = instructions[instructionPointer]
        registers = instruction.perform(initialRegisters: registers)
        
        // Load instruction pointer from register
        instructionPointer = registers[ipRegister]
        
        // Increment
        instructionPointer += 1
    }
    
    // The value in the last register appears constant after
    // the IP is 1
    // and appears to the be the condition for the loop
    // to exit
    let importantValue = registers[5]
    print("Important Value \(importantValue)")

    // It looks like the underlying loop is trying to get
    // sum of all factors. Let's iterate through all factors
    // up to (and including) sqrt(n).
    let squareOfImportantValue = Int(Double(importantValue).squareRoot())
    let sumOfFactors = (1...squareOfImportantValue).map {
        guard importantValue % $0 == 0 else { return 0 }
        return (importantValue / $0 != $0) ? importantValue/$0 + $0 : $0
    }.reduce(0, +)
    print("Sum of all factors (register 0):\(sumOfFactors)")
}
part2()
//18964204




//: [Next](@next)
