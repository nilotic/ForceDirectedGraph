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
        print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
/*
        if let forceDirectedGraphScene = ForceDirectedGraphScene(fileNamed: "GraphScene") {
            let skView = view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            forceDirectedGraphScene.scaleMode = .AspectFill
            
            skView.presentScene(forceDirectedGraphScene)
        } else {
            print("[\((NSString(string: "\(#file))").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to get the graph scene.")
            
        }
  */
        
        forceDirectedGraphScene.size = view.frame.size
        
        
        let skView = SKView(frame: view.frame)
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        forceDirectedGraphScene.scaleMode = .AspectFill
        
        skView.presentScene(forceDirectedGraphScene)

        view.addSubview(skView)
    }
    
    public func setGraphData(jsonFileName: String) -> Bool {
        print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)]")
        
        if forceDirectedGraphScene.setNodeList(jsonFileName) == false {
            print("[\((NSString(string: "\(#file)").lastPathComponent as NSString).stringByDeletingPathExtension) \(#function)] Error: Failed to set data.")
            return false
        }
        
        return false
    }
    
}
