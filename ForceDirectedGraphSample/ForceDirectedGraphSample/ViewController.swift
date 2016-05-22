//
//  ViewController.swift
//  ForceDirectedGraphSample
//
//  Created by nilotic on 5/22/16.
//  Copyright © 2016 nilotic. All rights reserved.
//

import UIKit
import ForceDirectedGraph

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let graphScene = GraphScene(view: self.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

