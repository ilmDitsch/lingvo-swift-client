//
//  Dictionary+Parser.swift
//  Baberini
//
//  Created by Torsten Büchner on 16.09.16.
//  Copyright © 2016 Museum Barberini. All rights reserved.
//

import Foundation

public enum DictionaryError: Error {
    
    case NoValueWithKey(key: String)
    case UnwrappingFailed(key: String, type: Any)
    case ResolvingKeypathFailed(keypath: String)
    
    public static var domain = "com.lingvo.swift-client.extensions.dictionary.error"
    
    public var code: Int {
        switch self {
        case .NoValueWithKey: return 1
        case .UnwrappingFailed: return 2
        case .ResolvingKeypathFailed: return 3
        }
    }
    
    //    public var localizedDescription: String {
    //        switch self {
    //        case .NoValueWithKey(let key): return "No value with key: `\(key)`"
    //        case .UnwrappingFailed(let key, let type): return "Could not cast value for key `\(key)` to type `\(type)`"
    //        case .ResolvingKeypathFailed(let keypath): return "Could not resolve keypath: `\(keypath)`"
    //        }
    //    }
    
}

public extension Dictionary where Value: AnyObject {
    
    public func valueForKey<T>(key: Key) throws -> T! { // Must return T! instead of just T
        guard let value = self[key] else {
            throw DictionaryError.NoValueWithKey(key: "\(key)")
        }
        
        guard let result = value as? T else {
            throw DictionaryError.UnwrappingFailed(key: "\(key)", type: T.self)
        }
        
        return result
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    
    public func valueForKeyPath<T>(keypath: String) throws -> T {
        let keypathComponents = keypath.components(separatedBy: ".")
        return try valueForKeyPath(remainingKeypathComponents: keypathComponents, originalKeypath: keypath)
    }
    
    private func valueForKeyPath<T>(remainingKeypathComponents: [String], originalKeypath: String) throws -> T {
        
        var mutableRemainingKeypathComponents = remainingKeypathComponents
        
        // Check if keypathComponents has a valid count
        guard mutableRemainingKeypathComponents.count > 0 else {
            throw DictionaryError.ResolvingKeypathFailed(keypath: originalKeypath)
        }
        
        // Pop first component and force cast to key type
        guard let nextKeyString = mutableRemainingKeypathComponents.removeFirst() as? Key.StringLiteralType else {
            throw DictionaryError.ResolvingKeypathFailed(keypath: originalKeypath)
        }
        let nextKey = Key(stringLiteral: nextKeyString)
        
        // Determine result recursive
        if mutableRemainingKeypathComponents.count == 0 {
            return try self.valueForKey(key: nextKey)
        } else {
            let subDictionary = try self.valueForKey(key: nextKey) as Dictionary<String, Value>
            return try subDictionary.valueForKeyPath(remainingKeypathComponents: mutableRemainingKeypathComponents, originalKeypath: originalKeypath)
        }
    }

}
