//
//  Decoder.swift
//  Bencoder
//
//  Created by Daniel Tombor on 2017. 09. 12..
//

import Foundation

// i = 0x69
// s = 0x73
// : = 0x3a
// 0 = 0x30
// 9 = 0x39
// l = 0x6c
// d = 0x64
// e = 0x65
// 5.57562899589539

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
        return nil
        
//        guard let bencode = Bencode.parse(str)?.bencode
//            else { return nil }
//        self = bencode
    }
    
    /** Decoding bencoded file */
    init?(file url: URL) {
        guard let data = try? Data(contentsOf: url),
            let bencode = Bencode.parse([UInt8](data))?.bencode
            else { return nil }
        self = bencode
    }
    
    /** Encoding to Bencode string */
    var encoded: String {
        switch self {
        case .integer(let i): return "i\(i)e"
        case .string(let s): return "\(s.count):\(String(bytes: s, encoding: .ascii)!)"
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
        case 0x69: return parseInt(nextSlice, from: nextIndex)
        case 0x30...0x39: return parseString(data, from: index)
        case 0x6c: return parseList(nextSlice, from: nextIndex)
        case 0x64: return parseDictionary(nextSlice, from: nextIndex)
        default: return nil
        }
    }
    
    static func parseInt(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        guard let end = data.index(of: 0x65)
            else { return nil }
        
        let num = Bencode.convertToInt(Array(data[..<end]))
        return (bencode: .integer(num), index: end+1)
    }
    
    static func parseString(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        guard let sep = data.index(of: 0x3a)
            else { return nil }
        
        let len = Bencode.convertToInt(Array(data[..<sep]))
        let start = sep + 1
        let end = data.index(start, offsetBy: len)
        
        return (bencode: .string(Array(data[start..<end])), index: end)
    }
    
    static func parseList(_ data: ArraySlice<UInt8>, from index: Int) -> ParseResult? {
        var l: [Bencode] = []
        var idx: Int = index
        
        while data[idx] != 0x65 {
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
        
        while data[idx] != 0x65 {
            guard let keyResult = parseString(data[idx...], from: idx),
                case .string(let keyData) = keyResult.bencode,
                let valueResult = parse(data[keyResult.index...], from: keyResult.index)
                else { return nil }
            
            let key = convertToString(keyData)
            d[BencodeKey(key, order: order)] = valueResult.bencode
            idx = valueResult.index
            order += 1
        }
        return (bencode: .dictionary(d), index: idx+1)
    }
}

// MARK: - Ascii coding

internal extension Bencode {
    
    static func convertToInt(_ ascii: [UInt8]) -> Int {
        return Int(String(bytes: ascii, encoding: .ascii)!)!
    }
    
    static func convertToString(_ data: [UInt8]) -> String {
        return String(bytes: data, encoding: .ascii)!
    }
}

private extension String {
    var ascii: [UInt8] {
        return unicodeScalars.map { return UInt8($0.value) }
    }
}
