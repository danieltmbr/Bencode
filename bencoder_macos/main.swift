//
//  main.swift
//  bencoder_macos
//
//  Created by Daniel Tombor on 2017. 09. 12..
//

import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser
let torrentPath = "Desktop/am.torrent"
let torrentUrl = home.appendingPathComponent(torrentPath)

do {
    let content = try String(contentsOf: torrentUrl, encoding: .ascii)
    if let bencode = Bencode(bencodedString: content) {
        print(bencode)
    } else { print("Couldn't decode") }
}
catch {
    print("No torrent")
}

if let bencode = Bencode(file: torrentUrl) {
    print(bencode["info"]["files"][0]["path"][0].string!)
}
