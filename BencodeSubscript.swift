//
//  BencodeSubscriptExtension.swift
//  bencoder_macos
//
//  Created by Daniel Tombor on 2017. 09. 13..
//

import Foundation

public enum BencodeOptional {
    case none
    case bencode(Bencode)
}

public extension Bencode {
    
    // Accessing int value
    var int: Int? {
        guard case .integer(let i) = self else { return nil }
        return i
    }
    
    // Accessing string value
    var string: String? {
        guard case .string(let s) = self else { return nil }
        return s
    }
    
    // Accessing list item by index
    subscript(index: Int) -> BencodeOptional {
        guard case .list(let l) = self,
            index >= 0, index < l.count else { return .none }
        return .bencode(l[index])
    }
    
    // Accessing dictionary value by key
    subscript(key: String) -> BencodeOptional {
        guard case .dictionary(let d) = self,
            let b = d[key] else { return .none }
        return .bencode(b)
    }
}

public extension BencodeOptional {
    
    // Accessing bencode enum
    var bencode: Bencode? {
        guard case .bencode(let b) = self else { return nil }
        return b
    }
    
    // Accessing int value
    var int: Int? {
        guard case .bencode(let b) = self else { return nil }
        return b.int
    }
    
    // Accessing string value
    var string: String? {
        guard case .bencode(let b) = self else { return nil }
        return b.string
    }
    
    // Accessing list item by index
    subscript(index: Int) -> BencodeOptional {
        guard case .bencode(let b) = self else { return .none }
        return b[index]
    }
    
    // Accessing dictionary value by key
    subscript(key: String) -> BencodeOptional {
        guard case .bencode(let b) = self else { return .none }
        return b[key]
    }
}

