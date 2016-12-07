//
//  ForceDirectedGraphScene.swift
//  ForceDirectedGraph
//
//  Created by Den Jo on 2/10/16.
//  Copyright (c) 2016 Den Jo. All rights reserved.
//

import SpriteKit

// MARK: - Define
struct JointInfo {
    let jointSpring: SKPhysicsJointSpring
    let line: SKShapeNode
    
    init(joint: SKPhysicsJointSpring, line: SKShapeNode) {
        self.jointSpring = joint
        self.line        = line
    }
}

struct NodeColor {
    static let Line   = UIColor(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    static let Edge   = UIColor.white
    static let Group1 = UIColor(colorLiteralRed: 228.0/255.0, green: 49.0/255.0,  blue: 45.0/255.0,  alpha: 1.0)
    static let Group2 = UIColor(colorLiteralRed: 1.0,         green: 128.0/255.0, blue: 36.0/255.0,  alpha: 1.0)
    static let Group3 = UIColor(colorLiteralRed: 1.0,         green: 186.0/255.0, blue: 123.0/255.0, alpha: 1.0)
    static let Group4 = UIColor(colorLiteralRed: 136.0/255.0, green: 221.0/255.0, blue: 142.0/255.0, alpha: 1.0)
    static let Group5 = UIColor(colorLiteralRed: 16.0/255.0,  green: 164.0/255.0, blue: 72.0/255.0,  alpha: 1.0)
    static let Group6 = UIColor(colorLiteralRed: 167.0/255.0, green: 198.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    static let Group7 = UIColor(colorLiteralRed: 0.0,         green: 118.0/255.0, blue: 176.0/255.0, alpha: 1.0)
    static let Group8 = UIColor(colorLiteralRed: 152.0/255.0, green: 104.0/255.0, blue: 185.0/255.0, alpha: 1.0)
    static let Group9 = UIColor(colorLiteralRed: 198.0/255.0, green: 175.0/255.0, blue: 211.0/255.0, alpha: 1.0)
    
    static func getNodeColor(_ group: GroupType) -> UIColor {
        switch group {
        case .accounting:
            return NodeColor.Group1
            
        case .business:
            return NodeColor.Group2
            
        case .design:
            return NodeColor.Group3
            
        case .development:
            return NodeColor.Group4
            
        case .finance:
            return NodeColor.Group5
            
        case .humanResources:
            return NodeColor.Group6
            
        case .marketing:
            return NodeColor.Group7
            
        case .planning:
            return NodeColor.Group8
            
        case .qualityAssurance:
            return NodeColor.Group9
            
        default:
            return NodeColor.Group1
        }
    }
}

struct NodeInfo {
    let vertex: Vertex
    let shapeNode: SKNode
}


// MARK: - Enum
enum PhysicsCategoryType: UInt32 {
    case none       = 0
    case circle     = 2
    case line       = 4
}


final public class ForceDirectedGraphScene: SKScene {
    
    // DataManager
    fileprivate let forceDirectedGraphDataManager = ForceDirectedGraphDataManager()
    
    // MARK: - Value
    // MARK: - Private
    private let radius: CGFloat             = 10.0
    private let centerCircleRadius :CGFloat = 26.0
    
    private var jointInfoArray        = [JointInfo]()
    private var selectedNode: SKNode? = nil
    private var touchedLocation       = CGPoint(x: 0 ,y: 0)
    
    fileprivate let cameraNode         = SKCameraNode()
    private let pinchGestureRecognizer = UIPinchGestureRecognizer()
    private let panGestureRecognizer   = UIPanGestureRecognizer()
    
    
    // MARK: - Function
    // MARK: - Public
    func setNodeList(_ jsonFileName: String) -> Bool {
        debugPrint(fdLog(#file, #function))
        
        if forceDirectedGraphDataManager.setGraphData(jsonFileName) == false {
            debugPrint(fdLog(#file, #function, "Error: Failed to set data."))
        }
        
        if forceDirectedGraphDataManager.setKawadaKawaiGraph() == false {
            debugPrint(fdLog(#file, #function, "Error: Failed to set kawadaKawai graph."))
        }
        
        // Add nodes
        for vertex in forceDirectedGraphDataManager.canvas {
            self.addChild(createNode(vertex))
        }
        
        
        // Set links
        for vertex in forceDirectedGraphDataManager.canvas {
            setLink(vertex)
        }
        
        return true
    }
    
    
    func setNodeList(_ nodes: [GraphNode], links: [GraphLink]) -> Bool {
        debugPrint(fdLog(#file, #function))
        
        if forceDirectedGraphDataManager.setGraphData(nodes: nodes, links: links) == false {
            debugPrint(fdLog(#file, #function, "Error: Failed to set data."))
        }
        
        if forceDirectedGraphDataManager.setKawadaKawaiGraph() == false {
            debugPrint(fdLog(#file, #function, "Error: Failed to set kawadaKawai graph."))
        }
        
        // Add nodes
        for vertex in forceDirectedGraphDataManager.canvas {
            self.addChild(createNode(vertex))
        }
        
        
        // Set links
        for vertex in forceDirectedGraphDataManager.canvas {
            setLink(vertex)
        }

        return true
    }
    
    
    // MARK: - Private 
    private func selectNodeForTouch(_ touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        
        if selectedNode != touchedNode {
            selectedNode?.removeAllActions()
            selectedNode = touchedNode
        }
    }
    
    private func panForTranslation(_ translation: CGPoint) {
        guard let position = selectedNode?.position else {
            return
        }
        
        selectedNode?.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
    }
    
    
    override public func didMove(to view: SKView) {
        /* Setup your scene here */

        self.scene?.backgroundColor = UIColor.white
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        let physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = physicsBody
        
        let ratio:CGFloat = 3.0
        self.size = CGSize(width: UIScreen.main.bounds.size.width * ratio, height: UIScreen.main.bounds.size.height * ratio)
        
        self.addChild(cameraNode)
        self.camera = cameraNode
        
        // Gesture
        pinchGestureRecognizer.addTarget(self, action: #selector(ForceDirectedGraphScene.pinchGestureRecognizerAction(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    override public func didSimulatePhysics() {
        super.didSimulatePhysics()
        debugPrint(fdLog(#file, #function))
        
        centerOnNode(cameraNode)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint(fdLog(#file, #function))
        
        /* Called when a touch begins */
        for touch in touches {
            touchedLocation = touch.location(in: self)
            guard let shapeNode = self.atPoint(touchedLocation) as? SKShapeNode else {
                continue
            }
            
            if shapeNode.physicsBody?.categoryBitMask == PhysicsCategoryType.circle.rawValue {
                selectedNode = self.atPoint(touchedLocation)
                debugPrint(fdLog(#file, #function, "position : \(selectedNode?.position)"))
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if selectedNode != nil {
                selectedNode!.position = location
            } else if (touches.count == 1) {
                cameraNode.run(SKAction.move(by: CGVector(dx: (touchedLocation.x - location.x)/2.0, dy: (touchedLocation.y - location.y)/2.0), duration: 0.0))
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint(fdLog(#file, #function))
        selectedNode = nil
    }


   
    override public func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        for jointInfo in self.jointInfoArray {
            
            guard let bodyANode = jointInfo.jointSpring.bodyA.node else {
                debugPrint(fdLog(#file, #function, "Error: Failed to get a bodyANode."))
                continue
            }
            
            guard let bodyBNode = jointInfo.jointSpring.bodyB.node else {
                debugPrint(fdLog(#file, #function, "Error: Failed to get a bodyBNode."))
                continue
            }
            
            let pathToDraw = CGMutablePath()
            pathToDraw.move(to: CGPoint(x: bodyANode.position.x, y: bodyANode.position.y))
            pathToDraw.addLine(to: CGPoint(x: bodyBNode.position.x, y: bodyBNode.position.y))
            pathToDraw.closeSubpath()
            
            jointInfo.line.path = pathToDraw
        }
    }
    
    private func createNode(_ vertex: Vertex) -> SKShapeNode {
        
        let circleNode                          = SKShapeNode(circleOfRadius: radius)
        circleNode.position                     = vertex.point
        circleNode.lineWidth                    = 2.0
        circleNode.physicsBody                  = SKPhysicsBody(circleOfRadius: radius)
        circleNode.physicsBody?.isDynamic         = true
        circleNode.physicsBody?.friction        = 0.1
        circleNode.physicsBody?.restitution     = 0.98
        circleNode.physicsBody?.mass            = 10.5
        circleNode.physicsBody?.allowsRotation  = true
        circleNode.physicsBody?.categoryBitMask = PhysicsCategoryType.circle.rawValue
        circleNode.strokeColor                  = NodeColor.Edge
        circleNode.fillColor                    = NodeColor.getNodeColor(vertex.group)
        
        vertex.node = circleNode
        
        // Label
        let labelNode       = SKLabelNode()
        labelNode.text      = vertex.name
        labelNode.fontSize  = 11.0
        labelNode.fontColor = UIColor.black
        circleNode.addChild(labelNode)
        
        return circleNode
    }
    
    private func setLink(_ vertex: Vertex) -> Bool {
        
        for edge in vertex.neighbors {
            // Line
            let pathToDraw = CGMutablePath()
            pathToDraw.move(to: CGPoint(x: edge.neighbor.point.x, y: edge.neighbor.point.y))
            pathToDraw.addLine(to: CGPoint(x: vertex.point.x, y: vertex.point.y))
            pathToDraw.closeSubpath()
            
            let line         = SKShapeNode(path: pathToDraw)
            line.strokeColor = NodeColor.Line
            line.lineWidth   = 3
            line.zPosition   = -1.0     // send to back
            self.addChild(line)
            
            guard let vertexNode = vertex.node, let neighborNode = edge.neighbor.node else {
                debugPrint(fdLog(#file, #function, "Error: Failed to set link."))
                continue
            }
            
            let spring = SKPhysicsJointSpring.joint(withBodyA: vertexNode.physicsBody!, bodyB: neighborNode.physicsBody!, anchorA: vertexNode.position, anchorB: neighborNode.position)
            spring.damping   = 0.1
            spring.frequency = 0.8
            
            self.scene?.physicsWorld.add(spring)
            self.jointInfoArray.append(JointInfo(joint: spring, line: line))

        }
        
        return true
    }
    
    fileprivate func centerOnNode(_ node: SKNode) -> Bool {
        debugPrint(fdLog(#file, #function))
        
        guard let nodeScene = node.scene, let parentNode = node.parent else {
            debugPrint(fdLog(#file, #function, "Error: Failed to set the node position."))
            return false
        }
        
        let positionInScene = nodeScene.convert(node.position, from: parentNode)
        parentNode.position = CGPoint(x: parentNode.position.x - positionInScene.x, y: parentNode.position.y - positionInScene.y)
        
        return true
    }
}

extension CGVector {
    func normalize () -> CGPoint {
        let length = CGFloat(sqrtf(pow(Float(self.dx), 2) + pow(Float(self.dy), 2)))
        return CGPoint(x: self.dx/length, y: self.dy/length)
    }
}

extension CGPoint {
    func mult(_ value: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * value, y: self.y * value)
    }
}

extension ForceDirectedGraphScene: UIGestureRecognizerDelegate {
    func pinchGestureRecognizerAction(_ recognizer: UIPinchGestureRecognizer) {
        cameraNode.run(SKAction.scale(by: 1.0 - recognizer.velocity/10.0, duration: 0.1))
        
        centerOnNode(cameraNode)
    }
}





