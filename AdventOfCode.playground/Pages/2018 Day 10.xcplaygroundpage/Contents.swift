//: [Previous](@previous)

import Foundation

// Day 10
func linesFromFilename(_ filename: String) -> [String] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let string = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    return string.split(separator: "\n").map { String($0) }
}

struct Sky {
    private let points: [Point]
    struct Point: Hashable {
        let positionX: Int
        let positionY: Int
        let velocityX: Int
        let velocityY: Int
        init(line: String) {
            var santizedString = line.replacingOccurrences(of: " ", with: "")
            santizedString = santizedString.replacingOccurrences(of: "position=", with: "")
            santizedString = santizedString.replacingOccurrences(of: "velocity", with: "")
            santizedString = santizedString.replacingOccurrences(of: "=", with: ",")
            santizedString = santizedString.replacingOccurrences(of: "<", with: "")
            santizedString = santizedString.replacingOccurrences(of: ">", with: "")
            
            let numbers = santizedString.split(separator: ",").compactMap { Int($0) }
            positionX = numbers[0]
            positionY = numbers[1]
            velocityX = numbers[2]
            velocityY = numbers[3]
        }
        
        init(positionX: Int, positionY: Int) {
            self.positionX = positionX
            self.positionY = positionY
            self.velocityX = 0
            self.velocityY = 0
        }
    }
    
    init(filename: String) {
        let lines = Sky.linesFromFilename(filename)
        points = lines.map { Point(line: $0) }
    }
    
    init(url: URL) {
        let lines = Sky.linesFromURL(url)
        points = lines.map { Point(line: $0) }
    }
    
    private static func linesFromFilename(_ filename: String) -> [String] {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
        let string = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
        return string.split(separator: "\n").map { String($0) }
    }
    
    private static func linesFromURL(_ fileUrl: URL) -> [String] {
        let string = (try? String(contentsOf: fileUrl, encoding: .utf8)) ?? ""
        return string.split(separator: "\n").map { String($0) }
    }
    
    func stringAfterTime(_ time: Int) -> String {
        let newPoints = points.map { (point) -> Point in
            let newX = point.positionX + (point.velocityX * time)
            let newY = point.positionY + (point.velocityY * time)
            return Point(positionX: newX, positionY: newY)
        }
        
        var pointSet = Set<Point>()
        for newPoint in newPoints {
            pointSet.insert(newPoint)
        }
        
        let valuesX = points.map { $0.positionX }
        let valuesY = points.map { $0.positionY }
        
        let minX = valuesX.min()!
        let maxX = valuesX.max()!
        let minY = valuesY.min()!
        let maxY = valuesY.max()!
        
        var string = ""
        for y in minY..<maxY {
            for x in minX..<maxX {
                let point = Point(positionX: x, positionY: y)
                let contains = pointSet.contains(point)
                
                if contains {
                    string.append("#")
                } else {
                    string.append(" ")
                }
            }
            string.append("\n")
        }
        return string
    }
}

print("Enter input path")
let urlString = readLine()
print(urlString!)
let url = URL(fileURLWithPath: urlString!)
let sky = Sky(url: url)

var time = 0
while readLine() != nil {
    print("Time \(time)")
    let string = sky.stringAfterTime(time)
    print(string)
    time += 1
}
////: [Next](@next)
