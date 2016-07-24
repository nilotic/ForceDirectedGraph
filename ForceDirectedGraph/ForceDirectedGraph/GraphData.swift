//
//  GraphData.swift
//  ForceDirectedGraph
//
//  Created by nilotic on 7/24/16.
//  Copyright © 2016 nilotic. All rights reserved.
//


public struct GraphNode {
    public var name: String
    public var group: Int
    
    public init(name: String, group: Int) {
        self.name  = name
        self.group = group
    }
}

public struct GraphLink {
    public var source: Int
    public var target: Int
    public var value: Int

    public init(source: Int, target: Int, value: Int) {
        self.source = source
        self.target = target
        self.value  = value
    }
}