//
//  ObjectParsable.swift
//  lingvo-swift-client
//
//  Created by Torsten Büchner on 16.09.16.
//  Copyright © 2016 Museum Barberini. All rights reserved.
//

import Foundation

public enum ParsingError: Error {
    
    case ParsingError(error:DictionaryError, type:String)
    
    public static var domain = "com.micromovie.lingvo.swift-client"
    
    public var code: Int {
        switch self {
        case .ParsingError: return 1
        }
    }
}

protocol ObjectParsable:class {
    var id:Int {get set}

    associatedtype SelfReturnType = Self
    
    static func parse(data:[String:AnyObject], linkingDictionaries: [[Int:AnyObject]]?) throws -> SelfReturnType
}

protocol ObjectSortedParsable:ObjectParsable {
    var sortIndex:Int {get set}
}

class ObjectParser {
    
    // Parses a JSON array of dicts into an array of objects
    static func parseArray<T:ObjectParsable>(data: [[String : AnyObject]], _ linkingDictionaries: [Int:AnyObject]...) throws -> [T] where T.SelfReturnType == T {
        var items = [T]()

        do {
            for rawItem in data {
                items.append(try T.parse(data: rawItem, linkingDictionaries: linkingDictionaries))
            }
        } catch let error as DictionaryError {
            throw ParsingError.ParsingError(error:error, type:String(describing: T.self))
        }
        
        return items
    }
    
    // Parses a JSON array of dicts into a dict of array of objects. The foreign key will be the key of the resulting dictionary.
//    static func parseArrayForMapping<T:MBObjectParsable>(data: [[String : AnyObject]], foreignIntKey:String, sortIndexIntKey:String?, _ linkingDictionaries: [Int:AnyObject]...) throws -> [Int:List<T>] where T.SelfReturnType == T, T:Any {
//
//        // Sorting
//        let preProcessedData:[[String : AnyObject]]
//        if let sortKey = sortIndexIntKey {
//            preProcessedData = data.sorted {
//                switch ($0[sortKey], $1[sortKey]) {
//                case (nil, nil), (_, nil):
//                    return true
//                case (nil, _):
//                    return false
//                case let (lhs as String, rhs as String):
//                    return lhs < rhs
//                case let (lhs as Int, rhs as Int):
//                    return  lhs < rhs
//                // Add more for Double, Date, etc.
//                default:
//                    return true
//                }
//            }
//        } else {
//            preProcessedData = data
//        }
//        
//        // parsing
//        var items = [Int:List<T>]()
//        for rawItem in preProcessedData {
//            let foreignKey:Int = try rawItem.valueForKey(foreignIntKey)
//            let t:T = try T.parse(rawItem, linkingDictionaries: linkingDictionaries)
//            
//            if items[foreignKey] == nil {
//                items[foreignKey] = List<T>()
//            }
//            
//            items[foreignKey]!.append(t)
//        }
//        
//        return items
//    }
    
    static func getDictWithPrimaryKeyMapping<T:ObjectParsable>(array:[T]) -> [Int:T] {
        
        var dict = [Int:T] ()
        
        for item in array {
            dict[item.id] = item
        }
        return dict
    }
}


//extension Dictionary where Key: ExpressibleByStringLiteralal, Value: AnyObject {
//    
//    func extractLinkedObjectWithKey<T:AnyObject>( dataKey:Key, linkingDictionaries: [[Int:AnyObject]]?) -> T? {
//        let optionalLinkedObjectID:Int? = try? self.valueForKey(key: dataKey)
//        
//        if  let linkedObjectID = optionalLinkedObjectID,
//            let linkingDictionaries = linkingDictionaries
//        {
//            for linkingDictionary in linkingDictionaries {
//                if  let tDict = linkingDictionary as? [Int:T],
//                    let t = tDict[linkedObjectID]
//                {
//                    return t
//                }
//            }
//        }
//        
//        return nil
//    }
//}
