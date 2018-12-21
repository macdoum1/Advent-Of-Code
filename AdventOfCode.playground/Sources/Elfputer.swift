import Foundation

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}

public enum Opcode: String, CaseIterable {
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

public struct Instruction {
    public let opcode: Opcode
    public let A: Int
    public let B: Int
    public let C: Int
    public init(opcode: Opcode, A: Int, B: Int, C: Int){
        self.opcode = opcode
        self.A = A
        self.B = B
        self.C = C
    }
    
    /// Performs instruction with given registers
    /// Returns: Resulting registers
    public func perform(initialRegisters: [Int]) -> [Int] {
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
