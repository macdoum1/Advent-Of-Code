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



//: [Next](@next)
