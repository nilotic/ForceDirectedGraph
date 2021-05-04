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
    static func getNodeColor(_ group: GroupType) -> UIColor {
        switch group {
        case .accounting:           return #colorLiteral(red: 0.8941176471, green: 0.1882352941, blue: 0.1764705882, alpha: 1)
        case .business:             return #colorLiteral(red: 1, green: 0.5019607843, blue: 0.1411764706, alpha: 1)
        case .design:               return #colorLiteral(red: 1, green: 0.7294117647, blue: 0.4823529412, alpha: 1)
        case .development:          return #colorLiteral(red: 0.5333333333, green: 0.8666666667, blue: 0.5568627451, alpha: 1)
        case .finance:              return #colorLiteral(red: 0.06274509804, green: 0.6431372549, blue: 0.2823529412, alpha: 1)
        case .humanResources:       return #colorLiteral(red: 0.6549019608, green: 0.7764705882, blue: 0.9019607843, alpha: 1)
        case .marketing:            return #colorLiteral(red: 0, green: 0.462745098, blue: 0.6901960784, alpha: 1)
        case .planning:             return #colorLiteral(red: 0.5960784314, green: 0.4078431373, blue: 0.7254901961, alpha: 1)
        case .qualityAssurance:     return #colorLiteral(red: 0.7764705882, green: 0.6862745098, blue: 0.8274509804, alpha: 1)
        default:                    return #colorLiteral(red: 0.8941176471, green: 0.1882352941, blue: 0.1764705882, alpha: 1)
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
        
        
        if forceDirectedGraphDataManager.setGraphData(jsonFileName) == false {
            log(.error, "Error: Failed to set data.")
        }
        
        if forceDirectedGraphDataManager.setKawadaKawaiGraph() == false {
            log(.error, "Error: Failed to set kawadaKawai graph.")
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
        
        
        if forceDirectedGraphDataManager.setGraphData(nodes: nodes, links: links) == false {
            log(.error, "Error: Failed to set data.")
        }
        
        if forceDirectedGraphDataManager.setKawadaKawaiGraph() == false {
            log(.error, "Error: Failed to set kawadaKawai graph.")
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
        pinchGestureRecognizer.addTarget(self, action: #selector(pinchGestureRecognizerAction(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    override public func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        
        centerOnNode(cameraNode)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        /* Called when a touch begins */
        for touch in touches {
            touchedLocation = touch.location(in: self)
            guard let shapeNode = self.atPoint(touchedLocation) as? SKShapeNode else {
                continue
            }
            
            if shapeNode.physicsBody?.categoryBitMask == PhysicsCategoryType.circle.rawValue {
                selectedNode = self.atPoint(touchedLocation)
                log(.error, "position : \(selectedNode?.position)")
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
        
        selectedNode = nil
    }


   
    override public func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        for jointInfo in self.jointInfoArray {
            
            guard let bodyANode = jointInfo.jointSpring.bodyA.node else {
                log(.error, "Error: Failed to get a bodyANode.")
                continue
            }
            
            guard let bodyBNode = jointInfo.jointSpring.bodyB.node else {
                log(.error, "Error: Failed to get a bodyBNode.")
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
        circleNode.strokeColor                  = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
            line.strokeColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            line.lineWidth   = 3
            line.zPosition   = -1.0     // send to back
            self.addChild(line)
            
            guard let vertexNode = vertex.node, let neighborNode = edge.neighbor.node else {
                log(.error, "Error: Failed to set link.")
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
        
        
        guard let nodeScene = node.scene, let parentNode = node.parent else {
            log(.error, "Error: Failed to set the node position.")
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
    
    @objc func pinchGestureRecognizerAction(_ recognizer: UIPinchGestureRecognizer) {
        cameraNode.run(SKAction.scale(by: 1.0 - recognizer.velocity/10.0, duration: 0.1))
        centerOnNode(cameraNode)
    }
}





