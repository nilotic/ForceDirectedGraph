//
//  Utility.swift
//  ForceDirectedGraph
//
//  Created by nilotic on 7/24/16.
//  Copyright © 2016 nilotic. All rights reserved.
//

import Foundation

func fdLog(file: String, _ function: String, _ message: String = "") -> String  {
    var logMessage = "ForceDirectGraph"
    
    // Add file, function name
    if let fileName = file.characters.split("/").map(String.init).last?.characters.split(".").map(String.init).first{
        logMessage = "\(logMessage) | \(fileName).\(function)"
    }
    
    // Add message
    if message != "" {
        logMessage = "\(logMessage) | \(message)"
    }
    
    return logMessage
}