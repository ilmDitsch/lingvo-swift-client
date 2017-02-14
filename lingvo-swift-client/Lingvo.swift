//
//  Panagram.swift
//  csvToStrings
//
//  Created by Keiner von Ihnen on 10.02.17.
//  Copyright © 2017 Keiner von Ihnen. All rights reserved.
//

import Foundation
class Lingvo {
    let consoleIO = ConsoleIO()
    let optionType : (option : OptionType, value : String)
    
    init() {
        if CommandLine.argc > 1 {
            //2
            let argument = CommandLine.arguments[1]
            //3
            self.optionType = self.consoleIO.getOption(argument.substring(from: argument.characters.index(argument.startIndex, offsetBy: 1)))
        } else {
            self.optionType = (OptionType.unknown, "")
            print("Invalid argument count")
            ConsoleIO.printUsage()
        }
    }
    
    func execute() {
        switch self.optionType.option {
        case .initialize, .push, .pull:
            print(self.optionType.value)
        case .help:
            ConsoleIO.printUsage()
        default:
            break
        }
    }
}