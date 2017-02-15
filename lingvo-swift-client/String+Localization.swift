//
//  String+Localization.swift
//  Baberini
//
//  Created by Torsten Büchner on 10.08.16.
//  Copyright © 2016 MicroMovie Media GmbH. All rights reserved.
//

import Foundation

extension String {
    
    
    func localize(_ plural:Int = -1, forceLang: String? = nil) -> String {
        if plural < 0 {
            return self.localizedString(forceLang)
        }
        
        switch plural {
        case 0:
            return (self + ".zero").localizedString(forceLang)
        case 1:
            return (self + ".one").localizedString(forceLang)
        default:
            return (self + ".other").localizedString(forceLang)
        }
    }
    
    func replaceKeys(_ replacements:[String:String]) -> String {
        var newString = self
        for key in replacements.keys {
            newString = newString.replacingOccurrences(of: "{{\(key)}}", with: replacements[key]!)
        }
        
        return newString
    }
    
    fileprivate func localizedString(_ forceLang: String?) -> String {
        
        // If a language is handed over, try to get a translation for it.
        if  let forceLang = forceLang,
            let path = Bundle.main.path(forResource: forceLang, ofType: "lproj"),
            let bundle = Bundle(path: path)
        {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        return NSLocalizedString(self, comment: "")
    }

}

extension NSMutableAttributedString {
    func replaceKeys(_ replacements:[String:NSAttributedString]) {
        for key in replacements.keys {
            let range = (self.string as NSString).range(of: "{{\(key)}}")
            if range.location != NSNotFound {
                self.replaceCharacters(in: range, with: replacements[key]!)
            }
        }
    }
}
