//: [Previous](@previous)

import Foundation
import UIKit

// Day 10
func linesFromFilename(_ filename: String) -> [String] {
    let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt")
    let string = (try? String(contentsOf: fileURL!, encoding: .utf8)) ?? ""
    return string.split(separator: "\n").map { String($0) }
}

struct Sky {
    let points: [Point]
    
    struct Point: Hashable {
        let positionX: Int
        let positionY: Int
        let velocityX: Int
        let velocityY: Int
        
        var position: CGPoint {
            return CGPoint(x: positionX, y: positionY)
        }
        
        var velocity: CGPoint {
            return CGPoint(x: velocityX, y: velocityY)
        }
        
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
    
    func toString() -> String {
        
        var minArea = Int.max
        var minPoints: [Point] = []
        var timeToSpell = 0
        
        for time in 0...30000 {
            let newPoints = points.map { (point) -> Point in
                let newX = point.positionX + (point.velocityX * time)
                let newY = point.positionY + (point.velocityY * time)
                return Point(positionX: newX, positionY: newY)
            }
            
            let valuesX = newPoints.map { $0.positionX }
            let valuesY = newPoints.map { $0.positionY }
            
            let minX = valuesX.min()!
            let maxX = valuesX.max()!
            let minY = valuesY.min()!
            let maxY = valuesY.max()!
            
            let xRange = maxX - minX
            let yRange = maxY - minY
            let area = xRange * yRange
            if area < minArea {
                minArea = area
                minPoints = newPoints
                timeToSpell = time
            }
        }
        print(timeToSpell)
        print("Found min")
        
        var set = Set<Point>()
        for point in minPoints {
            set.insert(point)
        }
        
        let valuesX = minPoints.map { $0.positionX }
        let valuesY = minPoints.map { $0.positionY }
        
        let minX = valuesX.min()!
        let maxX = valuesX.max()!
        let minY = valuesY.min()!
        let maxY = valuesY.max()!
        
        var string = ""
        for y in minY...maxY {
            for x in minX...maxX {
                if set.contains(Point(positionX: x, positionY: y)) {
                    string.append("#")
                } else {
                    string.append(" ")
                }
            }
            string.append("\n")
            print("\(y) in \(minY)-\(maxY)")
        }
        
        return string
    }
    
    

    
    private func scaleBetween(unscaledNum: CGFloat,
                              minAllowed: CGFloat,
                              maxAllowed: CGFloat,
                              min: CGFloat,
                              max: CGFloat) -> CGFloat {
        return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed
    }
}



import UIKit
import SceneKit
import QuartzCore
import PlaygroundSupport

var sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
var scene = SCNScene()
sceneView.scene = scene
PlaygroundPage.current.liveView = sceneView

sceneView.autoenablesDefaultLighting = true

var cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(x: 0, y: 0, z: 100)
scene.rootNode.addChildNode(cameraNode)
scene.physicsWorld.timeStep = 10

func getNode(position: CGPoint, velocity: CGPoint) -> SCNNode {
    position
    velocity
    let sphere = SCNSphere(radius: 2)
    sphere.firstMaterial?.diffuse.contents  = UIColor.red
    sphere.firstMaterial?.specular.contents = UIColor.white
    let node = SCNNode(geometry: sphere)
    node.position = SCNVector3(position.x, position.y, 0)

    let physics = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 2), options:nil))
    physics.friction = 0
    physics.isAffectedByGravity = false
    physics.velocity = SCNVector3(velocity.x, velocity.y, 0)
    node.physicsBody = physics
    node.physicsBody?.restitution = 1
    return node
}

let sky = Sky(filename: "input")
for point in sky.points {
    let node = getNode(position: point.position, velocity: point.velocity)
    scene.rootNode.addChildNode(node)
}

