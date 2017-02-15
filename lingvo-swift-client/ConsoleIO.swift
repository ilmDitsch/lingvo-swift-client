//
//  ComandIO.swift
//  lingvo-swift-client
//
//  Created by Keiner von Ihnen on 10.02.17.
//  Copyright © 2017 Keiner von Ihnen. All rights reserved.
//

import Foundation

enum OptionType: String {
    case push = "push"
    case pull = "pull"
    case initialize = "init"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "push": self = .push
        case "pull": self = .pull
        case "init": self = .initialize
        case "h": self = .help
        default: self = .unknown
        }
    }
}

class ConsoleIO {
    
    static let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    
    class func printUsage() {
        print("usage:")
        print("\(executableName) -init (initialize the directory)")
        print("")
        print("\(executableName) -push (push the strings information to the remote)")
        print("")
        print("\(executableName) -pull (pull the strings information from the remote)")
        print("")
        print("\(executableName) -h (to show usage information)")
    }
    
    func getOption(_ option: String) -> (option:OptionType, value: String) {
        return (OptionType(value: option), option)
    }
    
    @discardableResult
    class func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
