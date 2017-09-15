//
//  BencodeSequence.swift
//  Bencode
//
//  Created by Daniel Tombor on 2017. 09. 15..
//

import Foundation

public struct BencodeIterator: IteratorProtocol {
    
    public typealias Element = (key: String?, value: Bencode)
    
    let bencode: Bencode
    let sortedKeys: [String]
    private var index: Int = 0
    
    init(bencode: Bencode) {
        self.bencode = bencode
        sortedKeys = bencode.dict?.keys.sorted() ?? []
    }
    
    public mutating func next() -> Element? {
        switch bencode {
        case .list(let l) where index < l.count:
            defer { index += 1 }
            return (key: nil, value: l[index])
        case .dictionary(let d):
            guard index < sortedKeys.count else { return nil }
            defer { index += 1 }
            let key = sortedKeys[index]
            return (key: key, value: d[key]!)
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
