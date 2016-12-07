//
//  GraphScene.swift
//  ForceDirectedGraph
//
//  Created by nilotic on 5/22/16.
//  Copyright © 2016 nilotic. All rights reserved.
//

import SpriteKit

final public class GraphScene {
    
    private let forceDirectedGraphScene = ForceDirectedGraphScene()
    
    public init(view: UIView) {
        debugPrint(fdLog(#file, #function))
        
        forceDirectedGraphScene.size = view.frame.size
        
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        forceDirectedGraphScene.scaleMode = .aspectFill
        
        skView.presentScene(forceDirectedGraphScene)

    }
    
    public func setGraphData(_ jsonFileName: String) -> Bool {
        debugPrint(fdLog(#file, #function))
        
        return forceDirectedGraphScene.setNodeList(jsonFileName)
    }
    
    public func setGraphData(_ nodes: [GraphNode], links: [GraphLink]) -> Bool {
        debugPrint(fdLog(#file, #function))
        
        return forceDirectedGraphScene.setNodeList(nodes, links: links)
    }
    
}
