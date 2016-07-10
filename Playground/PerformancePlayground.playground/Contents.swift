//: Playground - noun: a place where people can play

import UIKit

//
//  ForceDirectedGraphDataManager.swift
//  SpringTest
//
//  Created by nilotic on 4/17/16.
//  Copyright © 2016 Den Jo. All rights reserved.
//
// http://waynewbishop.com/swift/graphs/dijkstra/
// https://github.com/nilotic/Undirected-Dijkstra-Swift
//


import SpriteKit
import UIKit

// MARK: - Define
final class Vertex {
    var name: String
    var group: GroupType
    var gender: Gender
    
    var point     = CGPoint(x: 0, y: 0)
    var neighbors = [Edge]()
    
    init(name: String, group: GroupType, gender: Gender) {
        self.name   = name
        self.group  = group
        self.gender = gender
    }
    
    var node:SKNode?
}

final class Edge {
    var neighbor: Vertex
    var weight: Int
    var visited: Bool
    
    init(neighbor: Vertex, weight: Int, visited: Bool) {
        self.neighbor = neighbor
        self.weight   = weight
        self.visited  = visited
    }
}

final class Path {
    var total: Int!
    var destination: Vertex
    var previous: Path!
    
    init() {
        self.destination = Vertex(name: "", group: .None, gender: .None)
    }
    
    init(destination: Vertex) {
        self.destination = destination
    }
}

struct KamadaKawaiInfo {
    static let springConst: Float = 1
    static let minEpsilon:Float   = 1          // target deltaM goal
    static let maxPasses           = 5000       // Maximum number of inner loops
    
}

// MARK: - Enum
enum GroupType: Int {
    case None = 0
    case Development
    case Marketing
    case Business
    case Accounting
    case Planning
    case Design
    case QualityAssurance
    case HumanResources
    case Finance
    case Team1
    case Team2
    case Team3
    case Team4
    case Team5
}

enum Gender {
    case None
    case Man
    case Woman
}


final class ForceDirectedGraphDataManager {
    // MARK: - Singletone
    static let sharedInstance = ForceDirectedGraphDataManager()
    
    
    // MARK: - Value
    // MARK: Private
    private var isDirected = false
    
    private var shortestPathMatrix      = [[Float]]()
    private var kMatrix                 = [[Float]]()
    private var lMatrix                 = [[Float]]()
    private var springConstant: Float  = 1
    
    
    // MARK: Public
    var canvas = [Vertex]()
    
    // MARK: - Function
    // MARK: - Init
    init() {
        print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        if setKawadaKawaiGraph() == false {
            print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set kawadaKawai graph.")
        }
        
        
    }
    
    // MARK: Private
    private func setGraphData() -> Bool {
        print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        guard let filePath = NSBundle.mainBundle().pathForResource("nodeInfoListTest", ofType: "json") else {
            print("Error: Failed to get the filePath.")
            return false
        }
        
        guard let data = try? NSData(contentsOfFile: filePath, options:.DataReadingMappedIfSafe) else {
            print("Error: Failed to get a data")
            return false
        }
        
        
        do {
            guard let deserializedData = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject] else {
                print("Error: Failed to convert data to dictionary.")
                return false
            }
            
            guard let nodes = deserializedData["nodes"] as? Array<[String:AnyObject]> else {
                print("Error: Failed to get nodeList.")
                return false
            }
            guard let links = deserializedData["links"] as? Array<[String:Int]> else {
                print("Error: Failed to get linkList.");
                return false
            }
            
            // Get nodeInfo
            for node in nodes {
                // Extract groupType
                guard let group = node["group"] as? Int else {
                    print("Error: Failed to get a group. This node will be passed.")
                    continue
                }
                
                guard let groupType = GroupType(rawValue: group) else {
                    print("Error: Failed to extract groupType. This node will be passed.")
                    continue
                }
                
                // Extract name
                guard let name = node["name"] as? String else {
                    print("Error: Failed to get name. This node will be passed.")
                    continue
                }
                
                // Add vertex
                let center = CGPointMake(UIScreen.mainScreen().bounds.size.width/CGFloat(groupType.rawValue), UIScreen.mainScreen().bounds.size.height/CGFloat(groupType.rawValue))
                let vertex = Vertex(name: name, group: groupType, gender: .None)
                vertex.point = randomPosition(center, radius: 150)
                canvas.append(vertex)
                
            }
            
            // Get linkInfo
            for link in links {
                // Extract Source
                guard let source = link["source"] else {
                    print("Error: Failed to get the source. This link will be passed.")
                    continue
                }
                
                // Extract target
                guard let target = link["target"] else {
                    print("Error: Failed to get the target. This link will be passed.")
                    continue
                }
                
                // Extract value (weight)
                guard let value = link["value"] else {
                    print("Error: Failed to get a value. This link will be passed.")
                    continue
                }
                
                if canvas.count <= source || canvas.count <= target {
                    print("DAILYHOTEL [\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to add the edge. CanvasCount: \(canvas.count), source: \(source), target: \(target)")
                    continue
                }
                
                if addEdge(canvas[source], neighbor: canvas[target], weight: value) == false {
                    print("DAILYHOTEL [\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to add the edge.")
                }
            }
            
        } catch let error {
            print("Error: Failed to deSerialize a data. \(error)")
        }
        
        return true
    }
    
    private func addEdge(source: Vertex, neighbor: Vertex, weight: Int) -> Bool {
        // Create a new edge
        let newEdge = Edge(neighbor: neighbor, weight: weight, visited: false)
        
        // Establish the default properties
        source.neighbors.append(newEdge)
        
        // Check for undirected graph
        if (isDirected == false) {
            // Create a new reversed edge
            let reverseEdge = Edge(neighbor: source, weight: weight, visited: false)
            
            // Establish the reversed properties
            neighbor.neighbors.append(reverseEdge)
        }
        
        return true
    }
    
    private func randomPosition(center: CGPoint, radius: Float) -> CGPoint {
        let theta = Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max) * Float(M_PI_2)
        let x = radius * cosf(theta)
        let y = radius * sinf(theta)
        return CGPointMake(center.x + CGFloat(x), center.y + CGFloat(y))
    }
    
    
    /// Undirected Dijkstra's algorithm
    private func shortestPath(source: Vertex, destination: Vertex) -> Path? {
        var frontier   = [Path]()
        var finalPaths = [Path]()
        
        var visitedEdgeList = [Edge]()
        
        // Use source edges to create the frontier
        for edge in source.neighbors {
            let newPath = Path(destination: edge.neighbor)
            newPath.previous    = nil
            newPath.total       = edge.weight
            edge.visited        = true
            
            // Add the new path to the frontier
            frontier.append(newPath)
            
            // Add edge to resetFlag
            visitedEdgeList.append(edge)
        }
        
        // Obtain the best path
        var shortestPath: Path!
        while(frontier.count != 0) {
            // Support path changes using the greedy approach
            shortestPath  = Path()
            shortestPath.total = 0
            var pathIndex = 0
            
            for index in 0..<frontier.count {
                let itemPath = frontier[index]
                if (shortestPath.total == nil) || (itemPath.total < shortestPath.total) {
                    shortestPath  = itemPath
                    pathIndex = index
                }
            }
            
            for edge in shortestPath.destination.neighbors {
                let newPath = Path()
                
                if (edge.visited == false) {
                    edge.visited       = true
                    newPath.destination = edge.neighbor
                    newPath.previous    = shortestPath
                    newPath.total       = shortestPath.total + edge.weight
                    
                    // Add the new path to the frontier
                    frontier.append(newPath)
                    
                    // Add edge to resetFlag
                    visitedEdgeList.append(edge)
                }
            }
            
            // Preserve the bestPath
            finalPaths.append(shortestPath)
            
            // Remove the bestPath from the frontier
            frontier.removeAtIndex(pathIndex)
        }
        
        for path in finalPaths {
            if (path.total < shortestPath.total) && (path.destination.name == destination.name) {
                shortestPath = path
            }
        }
        
        // Reset Flag
        for visitedEdge in visitedEdgeList {
            visitedEdge.visited = false
        }
        
        return shortestPath
    }
    
    private func farthestPath(source: Vertex, destination: Vertex) -> Path? {
        var frontier   = [Path]()
        var finalPaths = [Path]()
        
        var visitedEdgeList = [Edge]()
        
        // Use source edges to create the frontier
        for edge in source.neighbors {
            let newPath = Path(destination: edge.neighbor)
            newPath.previous    = nil
            newPath.total       = edge.weight
            edge.visited        = true
            
            // Add the new path to the frontier
            frontier.append(newPath)
            
            // Add edge to resetFlag
            visitedEdgeList.append(edge)
        }
        
        // Obtain the best path
        var farthestPath: Path!
        while(frontier.count != 0) {
            // Support path changes using the greedy approach
            farthestPath = Path()
            farthestPath.total = 0
            var pathIndex = 0
            
            for index in 0..<frontier.count {
                let itemPath = frontier[index]
                if (farthestPath.total == nil) || (itemPath.total > farthestPath.total) {
                    farthestPath = itemPath
                    pathIndex    = index
                }
            }
            
            for edge in farthestPath.destination.neighbors {
                let newPath = Path()
                
                if (edge.visited == false) {
                    edge.visited        = true
                    newPath.destination = edge.neighbor
                    newPath.previous    = farthestPath
                    newPath.total       = farthestPath.total + edge.weight
                    
                    // Add the new path to the frontier
                    frontier.append(newPath)
                    
                    // Add edge to resetFlag
                    visitedEdgeList.append(edge)
                }
            }
            
            // Preserve the bestPath
            finalPaths.append(farthestPath)
            
            // Remove the bestPath from the frontier
            frontier.removeAtIndex(pathIndex)
        }
        
        for path in finalPaths {
            if (path.total > farthestPath.total) && (path.destination.name == destination.name) {
                farthestPath = path
            }
        }
        
        // Reset Flag
        for visitedEdge in visitedEdgeList {
            visitedEdge.visited = false
        }
        
        //print("FarthestPath: \(farthestPath.total)")
        return farthestPath
    }
    
    /// Set shortest path matrixt (d matrix)
    private func setShortestPathMatrix() -> Bool {
        print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        // Initialize
        shortestPathMatrix = Array(count: canvas.count, repeatedValue: Array(count: canvas.count, repeatedValue: 0))
        
        for i in 0..<canvas.count {
            for j in i..<canvas.count {
                if i == j {
                    continue
                }
                guard let shortestPath = shortestPath(canvas[i], destination: canvas[j]) else {
                    continue
                }
                shortestPathMatrix[i][j] = Float(shortestPath.total)
                shortestPathMatrix[j][i] = Float(shortestPath.total)
            }
            //print("ShortestPath: \(shortestPathMatrix[i])")
        }
        
        return true
    }
    
    /// Set L(ideal lenght) Matrix
    private func setLMatrix() -> Bool {
        print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        // Initialize
        lMatrix =  Array(count: canvas.count, repeatedValue: Array(count: canvas.count, repeatedValue: 0))
        
        // Set L metrix
        let L0 = UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height ? Float(UIScreen.mainScreen().bounds.width) : Float(UIScreen.mainScreen().bounds.height)
        var L: Float = 0
        for i in 0..<canvas.count {
            for j in i..<canvas.count {
                var farthestPathTotal = 0
                if i != j {
                    if let farthestPath = farthestPath(canvas[i], destination: canvas[j]){
                        farthestPathTotal = farthestPath.total
                    }
                }
                
                if farthestPathTotal == 0 || shortestPathMatrix[i][j] == 0 {
                    L = 0
                } else {
                    L = (L0 / Float(farthestPathTotal)) * shortestPathMatrix[i][j]
                }
                lMatrix[i][j] = L
            }
            
            //print("LMatrix: \(lMatrix[i])")
        }
        
        return true
    }
    
    /// Set K (constant) Matrixt
    private func setKMatrix() -> Bool {
        print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        // Initialize
        kMatrix = Array(count: canvas.count, repeatedValue: Array(count: canvas.count, repeatedValue: Float(0)))
        
        if shortestPathMatrix.count < canvas.count {
            print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set kMatrix.")
            return false
        }
        
        for i in 0..<canvas.count {
            for j in i..<canvas.count {
                let denominator = pow(Float(shortestPathMatrix[i][j]), 2)
                if denominator != 0 {
                    kMatrix[i][j] = springConstant / denominator
                }
            }
            print("KMatrix: \(kMatrix[i])")
        }
        
        return true
    }
    
    /// Energy
    private func getEnergy() -> Float {
        var energy: Float = 0
        var dx: Float     = 0
        var dy: Float     = 0
        
        var lij: Float     = 0
        var dxdyPow: Float = 0
        
        for i in 0..<canvas.count - 1 {
            for j in i+1..<canvas.count {
                dx = Float(canvas[i].point.x - canvas[j].point.x)
                dy = Float(canvas[i].point.y - canvas[j].point.y)
                
                dxdyPow = pow(dx, 2) + pow(dy, 2)
                lij = lMatrix[i][j]
                energy += 0.5 * kMatrix[i][j] * (dxdyPow + pow(lij, 2) - 2 * lij * sqrt(dxdyPow))
            }
        }
        
        return energy
    }
    
    /// DeltaM
    private func getDeltaM(i: Int) -> Float {
        var dx: Float          = 0
        var dy: Float          = 0
        
        var dxdyPow: Float     = 0
        var dxdySqrt: Float    = 0
        
        var xPartial: Float    = 0
        var yPartial: Float    = 0
        
        for j in 0..<lMatrix[i].count {
            if (i != j) {
                dx = Float(canvas[i].point.x - canvas[j].point.x)
                dy = Float(canvas[i].point.y - canvas[j].point.y)
                
                dxdyPow = pow(dx, 2) + pow(dy, 2)
                dxdySqrt = sqrt(dxdyPow)
                
                if dxdySqrt != 0 {
                    xPartial += kMatrix[i][j] * (dx - lMatrix[i][j] * dx / dxdySqrt)
                    yPartial += kMatrix[i][j] * (dy - lMatrix[i][j] * dy / dxdySqrt)
                }
            }
        }
        
        return sqrt(pow(xPartial, 2) + pow(yPartial, 2))
    }
    
    /// the bulk of the KK inner loop, estimates location of local minima
    private func getDeltas(i: Int) -> CGPoint {
        // Solve deltaM partial eqns to figure out new position for node of index i where  delataM is close to 0 or less then epsilon
        var dx: Float     = 0
        var dy: Float     = 0
        var ddSqrt: Float = 0
        
        var xPartial: Float  = 0
        var yPartial: Float  = 0
        var xxPartial: Float = 0
        var yyPartial: Float = 0
        var xyPartial: Float = 0
        var yxPartial: Float = 0
        
        for j in 0..<canvas.count {
            if i != j {
                dx = Float(canvas[i].point.x - canvas[j].point.y)
                dy = Float(canvas[i].point.y - canvas[j].point.y)
                ddSqrt = sqrt(pow(dx, 2) + pow(dy, 2))
                
                let ddCubed = pow(ddSqrt, 3)
                
                if ddSqrt != 0 && ddCubed != 0 {
                    xPartial += kMatrix[i][j] * (dx - lMatrix[i][j] * dx / ddSqrt)
                    yPartial += lMatrix[i][j] * (dy - lMatrix[i][j] * dy / ddSqrt)
                    
                    xxPartial += kMatrix[i][j] * (1 - lMatrix[i][j] * pow(dy, 2) / ddCubed)
                    xyPartial += kMatrix[i][j] * (lMatrix[i][j] * dx * dy / ddCubed)
                    yxPartial += kMatrix[i][j] * (lMatrix[i][j] * dy * dx / ddCubed)
                    yyPartial += kMatrix[i][j] * (1 - lMatrix[i][j] * pow(dx, 2) / ddCubed)
                }
            }
        }
        
        // Calculate x, y position difference using partials
        let partialResult = xxPartial * yyPartial - xyPartial * yxPartial
        
        var x: Float = 0
        var y: Float = 0
        if (partialResult != 0) {
            x = ((-xPartial) * yyPartial - xyPartial * (-yPartial)) / partialResult
            y = (xxPartial * (-yPartial) - (-xPartial) * yxPartial) / partialResult
        }
        
        if x >= Float.infinity || x.isNaN == true {
            x = 0
        }
        
        if y >= Float.infinity || y.isNaN == true {
            y = 0
        }
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    private func setKawadaKawaiGraph() -> Bool {
        print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        if setGraphData() == false {
            print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set NodeInfo.")
            return false
        }
        
        if setShortestPathMatrix() == false {
            print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set shortestPathWeight Matrix.")
            return false
        }
        
        if setLMatrix() == false {
            print("DAILYHOTEL [\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set L(ideal length) Matrix.")
            return false
        }
        
        if setKMatrix() == false {
            print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set kMatrix.")
            return false
        }
        
        let initialEnergy = getEnergy()
        var epsilon = initialEnergy / Float(canvas.count)
        
        // Get daltaM max
        var deltaM: Float = 0
        var deltaMIndexMax = 0
        var deltaMMax      = getDeltaM(deltaMIndexMax)
        
        for i in 1..<canvas.count {
            deltaM = getDeltaM(i)
            if deltaM > deltaMMax {
                deltaMMax      = deltaM
                deltaMIndexMax = i
            }
        }
        
        // Epsilon minimizing loop
        var subPasses = 0
        var stop = false
        var previousDeltaMMax: Float = 0
        while (epsilon > KamadaKawaiInfo.minEpsilon) && stop == false {
            previousDeltaMMax = deltaMMax + 1;
            
            // KamadaKawai loop: while the deltaM of the node with the largest deltaM > epsilon.
            while (deltaMMax > epsilon) && ((previousDeltaMMax - deltaMMax) > 0.1) && stop == false {
                
                var deltas         = CGPoint(x: 0, y: 0)
                var moveNodeDeltaM = deltaMMax
                
                // KK Inner loop while the node with the largest energy > epsilon
                while (moveNodeDeltaM > epsilon) && stop == false {
                    // Get the deltas which will move node towards the local minima
                    deltas = getDeltas(deltaMIndexMax)
                    
                    // Set coords of node to old coord + changes
                    canvas[deltaMIndexMax].point.x += deltas.x
                    canvas[deltaMIndexMax].point.y += deltas.y
                    
                    // Recalculate the deltaM of the node w/ new values
                    moveNodeDeltaM = getDeltaM(deltaMIndexMax)
                    
                    subPasses += 1
                    if subPasses > KamadaKawaiInfo.maxPasses {
                        stop = true
                    }
                }
                
                // Recalcualte deltaMs and find node with max
                deltaMIndexMax = 0
                deltaMMax = getDeltaM(0)
                
                for i in 1..<canvas.count {
                    deltaM = getDeltaM(i)
                    if deltaM > deltaMMax {
                        deltaMMax = deltaM
                        deltaMIndexMax = i
                    }
                }
                
            } // End of while
            
            epsilon -= epsilon / 4
        } // End of while
        
        for info in canvas {
            print(info.point)
        }
        return true
    }
    
}


let dataManager = ForceDirectedGraphDataManager()














