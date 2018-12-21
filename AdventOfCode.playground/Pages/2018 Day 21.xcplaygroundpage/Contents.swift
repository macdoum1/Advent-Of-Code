//: [Previous](@previous)

import Foundation

let input = """
#ip 1
seti 123 0 4
bani 4 456 4
eqri 4 72 4
addr 4 1 1
seti 0 0 1
seti 0 4 4
bori 4 65536 3
seti 12670166 8 4
bani 3 255 2
addr 4 2 4
bani 4 16777215 4
muli 4 65899 4
bani 4 16777215 4
gtir 256 3 2
addr 2 1 1
addi 1 1 1
seti 27 6 1
seti 0 0 2
addi 2 1 5
muli 5 256 5
gtrr 5 3 5
addr 5 1 1
addi 1 1 1
seti 25 6 1
addi 2 1 2
seti 17 8 1
setr 2 5 3
seti 7 2 1
eqrr 4 0 2
addr 2 1 1
seti 5 8 1
"""

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
    let equalityInstructionIndex = instructions.firstIndex {
        $0.opcode == .equalRegisterRegister
    }!
    print("Magic Index: \(equalityInstructionIndex)")
    
    var registers = [0, 0, 0, 0, 0, 0]
    var results = Set<Int>()
    var foundFirst = false
    var lastFound = 0
    
    while registers[ipRegister] < instructions.count {
        if registers[ipRegister] == equalityInstructionIndex {
            let magicValue = registers[4]
            
            if results.contains(magicValue) {
                print("Found value in set")
                break
            }
            
            if !foundFirst {
                foundFirst = true
                print("Part 1: \(magicValue)")
            }
            
            lastFound = magicValue
            results.insert(magicValue)
        }
        
        // Perform instrution
        let instruction = instructions[registers[ipRegister]]
        registers = instruction.perform(initialRegisters: registers)
        
        // Increment
        registers[ipRegister] += 1
    }
    
    print("After")
    print(registers)
    print("Part 2: \(lastFound)")
}

part1()
//3427160 too low


//: [Next](@next)
