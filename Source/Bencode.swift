//
//  Decoder.swift
//  Bencoder
//
//  Created by Daniel Tombor on 2017. 09. 12..
//

import Foundation

// MARK: - Bencode

public enum Bencode {
    case integer(Int)
    case string([UInt8])
    indirect case list([Bencode])
    indirect case dictionary([BencodeKey:Bencode])
}

public extension Bencode {
    
    /** Decoding from Bencoded string */
    init?(bencodedString str: String) {
        self.init(bytes: str.ascii)
    }
    
    /** Decoding bencoded file */
    init?(file url: URL) {
        guard let data = try? Data(contentsOf: url)
            else { return nil }
        self.init(bytes: [UInt8](data))
    }
    
    /** Decoding from bytes */
    init?(bytes: [UInt8]) {
        guard let bencode = Bencode.parse(bytes)?.bencode
            else { return nil }
        self = bencode
    }
    
    /** Encoding to Bencode string */
    var encoded: String {
        switch self {
        case .integer(let i): return "i\(i)e"
        case .string(let b): return "\(b.count):\(String(bytes: b, encoding: .ascii)!)"
        case .list(let l):
            let desc = l.map { $0.encoded }.joined()
            return "l\(desc)e"
        case .dictionary(let d):
            let desc = d.sorted(by: { $0.key < $1.key })
                .map { "\(Bencode.string($0.key.ascii).encoded)\($1.encoded)" }
                .joined()
            return "d\(desc)e"
        }
    }
    
    /** Encoding to Bencoded Data */
    var asciiEncoding: Data {
        return Data(bytes: encoded.ascii)
    }
}

// MARK: - Private decding helpers

private extension Bencode {
    
    private struct Tokens {
        static let i: UInt8 = 0x69
        static let l: UInt8 = 0x6c
        static let d: UInt8 = 0x64
        static let e: UInt8 = 0x65
        static let zero: UInt8 = 0x30
        static let nine: UInt8 = 0x39
        static let colon: UInt8 = 0x3a
        static let hyphen: UInt8 = 0x2d
    }
    
    typealias ParseResult = (bencode: Bencode, index: Int)

    static func parse(_ data: [UInt8]) -> ParseResult? {
        return parse(ArraySlice(data), from: 0)
    }
    
    static private func parse(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        
        guard data.count > index + 1
            else { return nil }
        
        let nextIndex = index+1
        let nextSlice = data[nextIndex...]
        
        switch data[index] {
        case Tokens.i: return parseInt(nextSlice, from: nextIndex)
        case Tokens.zero...Tokens.nine: return parseString(data, from: index)
        case Tokens.l: return parseList(nextSlice, from: nextIndex)
        case Tokens.d: return parseDictionary(nextSlice, from: nextIndex)
        default: return nil
        }
    }
    
    static func parseInt(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        guard let end = data.index(of: Tokens.e),
            let num = Array(data[..<end]).int
            else { return nil }
        return (bencode: .integer(num), index: end+1)
    }
    
    static func parseString(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        guard let sep = data.index(of: Tokens.colon),
            let len = Array(data[..<sep]).int
            else { return nil }
        
        let start = sep + 1
        let end = data.index(start, offsetBy: len)
        
        return (bencode: .string(Array(data[start..<end])), index: end)
    }
    
    static func parseList(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        var l: [Bencode] = []
        var idx: Int = index
        
        while data[idx] != Tokens.e {
            guard let result = parse(data[idx...], from: idx)
                else { return nil }
            l.append(result.bencode)
            idx = result.index
        }
        
        return (bencode: .list(l), index: idx+1)
    }
    
    static func parseDictionary(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        var d: [BencodeKey:Bencode] = [:]
        var idx: Int = index
        var order = 0
        
        while data[idx] != Tokens.e {
            guard let keyResult = parseString(data[idx...], from: idx),
                case .string(let keyData) = keyResult.bencode,
                let key = keyData.string,
                let valueResult = parse(data[keyResult.index...], from: keyResult.index)
                else { return nil }

            d[BencodeKey(key, order: order)] = valueResult.bencode
            idx = valueResult.index
            order += 1
        }
        return (bencode: .dictionary(d), index: idx+1)
    }
}
