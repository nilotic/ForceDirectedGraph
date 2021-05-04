//
//  Utility.swift
//  ForceDirectedGraph
//
//  Created by nilotic on 7/24/16.
//  Copyright © 2016 nilotic. All rights reserved.
//

import Foundation
import os.log

enum LogType: String {
    case info    = "[💬]"
    case warning = "[⚠️]"
    case error   = "[‼️]"
}


func log(_ type: LogType = .error, _ message: Any?, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    var logMessage = ""
    
    // Add file, function name
    if let filename = file.split(separator: "/").map(String.init).last?.split(separator: ".").map(String.init).first {
        logMessage = "\(type.rawValue) [\(filename)  \(function)]\((type == .info) ? "" : " ✓\(line)")"
    }

    os_log("%s", "\(logMessage)  ➜  \(message ?? "")\n ‎‎")
    #endif
}

