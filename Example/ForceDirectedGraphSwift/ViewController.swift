//
//  ViewController.swift
//  ForceDirectedGraphSwift
//
//  Created by Den jo on 07/10/2016.
//  Copyright (c) 2016 Den jo. All rights reserved.
//

import UIKit
import ForceDirectedGraphSwift

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let graphScene = GraphScene(view: self.view)
        graphScene.setGraphData("nodeInfoListTest")
    }
    
}

