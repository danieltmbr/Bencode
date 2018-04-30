# Bencode

Bencode is a general purpose bencode encoder & decoder written in swift 4.

Inspired by [VFK SwiftyBencode][vfk] & [arvidsigvardsson/Bencode][abc]

## Installation

**⚠️ Xcode 9 is required ⚠️**

Bencode is available through [CocoaPods](http://cocoapods.org).
To install it, simply add the following line to your Podfile:

```ruby
pod 'Bencode', :git => 'https://github.com/danieltmbr/Bencode.git'
```

## Usage

**Initialize with URL:**

```swift
let bencode: Bencode? = Bencode(file: torrentUrl)
```

**Initialize with bencoded string:**

```swift
let bencode: Bencode? = Bencode(bencodedString: content)
```

**Would you like to know more of the parsing failures, use the decoder:**

```swift
do {
    let bencode = Bencoder().decode(from: fileURL)
} catch let error {
    print(error)
}
```

**Accessing properties:**

Accessing properties is very handy with subscripts & accessors.
Value accessors `.int`, `.string`, `.list` & `.dict` are optional.
Subscripts produces **BencodeOptional** enums, by doing so you can chain optional subscripts without having to write `?` or `!` behind every one of them.
Bencode also comfort to Sequence protocol, so you can use `map`, `filter`, `foreach` etc. on them. :)

```swift
let bencode = Bencode(file: torrentUrl)

let info = bencode["info"]
let files = info["files"]

// You can use them as a sequence
// .values is a shorthand for .map{ $0.value }
files.values.forEach {
    print($0["path"][0].string!)
}

// Easy optional chaning without unwapping every stage:
let filePath: String? = info["files"][0]["path"][0].string
let fileLength: Int? = bencode["info"]["files"]["length"].int
```

## Help

* Post any issues you find
* Post new feature requests
* Pull requests are welcome

## Author

danieltmbr, daniel@tmbr.me

## License

Bencode is available under the MIT license. See the LICENSE file for more info.


[vfk]: https://github.com/VFK/SwiftyBencode
[abc]: https://github.com/arvidsigvardsson/Bencode
