//
//  BencodeSequence.swift
//  Bencode
//
//  Created by Daniel Tombor on 2017. 09. 15..
//

import Foundation

public struct BencodeIterator: IteratorProtocol {
    
    public typealias Element = Bencode
    
    let bencode: Bencode
    private var index: Int = 0
    
    init(bencode: Bencode) {
        self.bencode = bencode
    }
    
    public mutating func next() -> Element? {
        switch bencode {
        case .list(let l) where index < l.count:
            defer { index += 1 }
            return l[index]
        case .dictionary(let d):
            let keys = d.keys.sorted()
            guard index < keys.count else { return nil }
            defer { index += 1 }
            return d[keys[index]]
        default: return nil
        }
    }
}

extension Bencode: Sequence {

    public typealias Iterator = BencodeIterator
    
    public func makeIterator() -> Iterator {
        return BencodeIterator(bencode: self)
    }
}
