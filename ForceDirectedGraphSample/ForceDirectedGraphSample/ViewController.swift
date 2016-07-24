//
//  ViewController.swift
//  ForceDirectedGraphSample
//
//  Created by nilotic on 5/22/16.
//  Copyright © 2016 nilotic. All rights reserved.
//

import UIKit
import ForceDirectedGraph

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let graphScene = GraphScene(view: self.view)
//        graphScene.setGraphData("nodeInfoListTest")
        
        
        setDummyData()
    }

    private func setDummyData() -> Bool {
        let totalCount = 10
        
        var nodes = [GraphNode]()
        var links = [GraphLink]()
        
        for i in 0..<totalCount {
            nodes.append(GraphNode(name: "\(i)", group: i%10))
            
            let source = Int(arc4random_uniform(UInt32(totalCount)))
            let target = Int(arc4random_uniform(UInt32(totalCount)))
            
            if source != target {
                links.append(GraphLink(source: source, target: target, value: Int(arc4random_uniform(UInt32(totalCount/2)))))
            }
            
        }
        
        let graphScene = GraphScene(view: self.view)
        return graphScene.setGraphData(nodes, links: links)
    }


}

