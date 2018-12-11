//: [Previous](@previous)

import Foundation

func linesFromFilename(_ filename: String) -> [String] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let string = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    return string.split(separator: "\n").map { String($0) }
}

//: [Next](@next)
