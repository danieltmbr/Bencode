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
    case string(String)
    indirect case list([Bencode])
    indirect case dictionary([BencodeKey:Bencode])
}

public extension Bencode {
    
    /** Decoding from Bencoded string */
    init?(bencodedString str: String) {
        guard let bencode = Bencode.parse(str)?.bencode else { return nil }
        self = bencode
    }
    
    /** Decoding bencoded file */
    init?(file url: URL) {
        guard let str = try? String(contentsOf: url, encoding: .ascii),
            let bencode = Bencode.parse(str)?.bencode else { return nil }
        self = bencode
    }
    
    /** Encoding to Bencode string */
    var encoded: String {
        switch self {
        case .integer(let i): return "i\(i)e"
        case .string(let s): return "\(s.count):\(s)"
        case .list(let l):
            let desc = l.map { $0.encoded }.joined()
            return "l\(desc)e"
        case .dictionary(let d):
            let desc = d.sorted(by: { $0.key < $1.key })
                .map { "\(Bencode.string($0.key).encoded)\($1.encoded)" }
                .joined()
            return "d\(desc)e"
        }
    }
}

// MARK: - Private decding helpers

private extension Bencode {
    
    typealias ParseResult = (bencode: Bencode, text: String)

    static func parse(_ s: String) -> ParseResult? {
        
        guard let c = s.first else {
            return nil
        }
        
        switch c {
        case "i": return parseInt(String(s.suffix(s.count-1)))
        case "0"..."9": return parseString(s)
        case "l":
            var l: [Bencode] = []
            var sfx = String(s.suffix(s.count-1))
            while sfx.first != "e" {
                guard let result = parse(String(sfx))
                    else { return nil }
                l.append(result.bencode)
                sfx = result.text
            }
            return (bencode: .list(l), text: String(sfx.suffix(sfx.count-1)))
        case "d":
            var d: [BencodeKey:Bencode] = [:]
            var sfx = String(s.suffix(s.count-1))
            var order = 0
            while sfx.first != "e" {
                guard let keyResult = parseString(sfx),
                    case .string(let key) = keyResult.bencode,
                    let valueResult = parse(keyResult.text)
                    else { return nil }
                d[BencodeKey(key, order: order)] = valueResult.bencode
                sfx = valueResult.text
                order += 1
            }
            return (bencode: .dictionary(d), text: String(sfx.suffix(sfx.count-1)))
        default: return nil
        }
    }
    
    static func parseInt(_ s: String) -> ParseResult? {
        guard let end = s.index(of: "e"),
            let num = Int(s[..<end])
            else { return nil }
        return (bencode: .integer(num), text: suffix(s, after: end))
    }
    
    static func parseString(_ s: String) -> ParseResult? {
        guard let sep = s.index(of: ":"),
            let len = Int(s[..<sep])
            else { return nil }
        let end = s.index(sep, offsetBy: len)
        let content = String(s[s.index(after: sep)...end])
        return (bencode: .string(content), text: suffix(s, after: end))
    }

    static func suffix(_ s: String, after i: String.Index) -> String {
        return i < s.endIndex ? String(s[s.index(after: i)...]) : ""
    }
}
