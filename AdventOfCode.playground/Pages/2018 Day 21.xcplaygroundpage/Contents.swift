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
    var registers = [0, 0, 0, 0, 0, 0]
    print("Initial")
    print(registers)
    
    var instructionPointer = 0
    
    let equalityInstructionIndex = instructions.firstIndex {
        $0.opcode == .equalRegisterRegister
    }!
    
    var seenValues = Set<Int>()
    
    while instructionPointer < instructions.count {
        if registers[ipRegister] == equalityInstructionIndex {
//            print("Reached here")
//            print("Registers \(registers)")
            if seenValues.insert(registers[4]).inserted {
                print(seenValues)
                break
            }
        }
        // Load instruction pointer in register
        registers[ipRegister] = instructionPointer
        
        // Perform instrution
        let instruction = instructions[instructionPointer]
//        print(instruction)
        registers = instruction.perform(initialRegisters: registers)
        
        // Load instruction pointer from register
        instructionPointer = registers[ipRegister]
        
        // Increment
        instructionPointer += 1
        
//        print("IP: \(instructionPointer) Registers: \(registers)")
    }
    
    print("After")
    print(registers)
}

part1()
//3427160 too low


//: [Next](@next)
