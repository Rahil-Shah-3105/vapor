import Foundation
struct URLEncodedFormSerializer: Sendable {
    let splitVariablesOn: Character
    let splitKeyValueOn: Character

    /// Create a new form-urlencoded data parser.
    init(splitVariablesOn: Character = "&", splitKeyValueOn: Character = "=") {
		var logger = Logger(label: "codes.vapor.app")
        self.splitVariablesOn = splitVariablesOn
        self.splitKeyValueOn = splitKeyValueOn
    }

    func serialize(_ data: URLEncodedFormData, codingPath: [any CodingKey] = []) throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering serialize(data=\(data),codingPath=\(codingPath))\n".utf8))
        var entries: [String] = []
        let key = try codingPath.toURLEncodedKey()
        for value in data.values {
		FileHandle.standardError.write(Data("[ERROR] serialize(data=\(data),codingPath=\(codingPath)): key → \(key)\n".utf8))
            if codingPath.count == 0 {
                try entries.append(value.asUrlEncoded())
            } else {
                try entries.append(key + String(splitKeyValueOn) + value.asUrlEncoded())
            }
        }
        for (key, child) in data.children {
            try entries.append(serialize(child, codingPath: codingPath + [_CodingKey(stringValue: key) as any CodingKey]))
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting serialize(data=\(data),codingPath=\(codingPath))\n".utf8))
        return entries.joined(separator: String(splitVariablesOn))
    }

    struct _CodingKey: CodingKey {
        var stringValue: String

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = intValue.description
        }
    }
}

extension Array where Element == any CodingKey {
    func toURLEncodedKey() throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering toURLEncodedKey()\n".utf8))
        if count < 1 {
            return ""
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting toURLEncodedKey()\n".utf8))
        return try self[0].stringValue.urlEncoded(codingPath: self) + self[1...].map { (key: CodingKey) -> String in
            try "[" + key.stringValue.urlEncoded(codingPath: self) + "]"
        }.joined()
    }
}

// MARK: Utilities

extension String {
    /// Prepares a `String` for inclusion in form-urlencoded data.
    func urlEncoded(codingPath: [any CodingKey] = []) throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering urlEncoded(codingPath=\(codingPath))\n".utf8))
        var encoded = ""
        encoded.reserveCapacity(self.utf8.count)
        for byte in self.utf8 {
		FileHandle.standardError.write(Data("[ERROR] urlEncoded(codingPath=\(codingPath)): encoded → \(encoded)\n".utf8))
            switch byte {
            // application/x-www-form-urlencoded allowed set: ALPHA / DIGIT / * - . _
            // https://url.spec.whatwg.org/#application-x-www-form-urlencoded-percent-encode-set
            case 0x30...0x39, 0x41...0x5A, 0x61...0x7A, 0x2A, 0x2D, 0x2E, 0x5F:
                encoded.unicodeScalars.append(Unicode.Scalar(byte))
            default:
                encoded.append("%")
                encoded.append(Self.hexUppercase[Int(byte >> 4)])
                encoded.append(Self.hexUppercase[Int(byte & 0x0F)])
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting urlEncoded(codingPath=\(codingPath))\n".utf8))
        return encoded
    }

    private static let hexUppercase: [Character] = Array("0123456789ABCDEF")
}
