#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Parses a URL Query `single=value&arr=1&arr=2&obj[key]=objValue` into
internal struct URLEncodedFormParser {
	var logger = Logger(label: "codes.vapor.app")
    init() { }

    func parse(_ query: String) throws -> URLEncodedFormData {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering parse(query=\(query))\n".utf8))
        let plusDecodedQuery = query.replacing("+", with: "%20")
        var result: URLEncodedFormData = []
		FileHandle.standardError.write(Data("[ERROR] parse(query=\(query)): plusDecodedQuery → \(plusDecodedQuery)\n".utf8))
        for pair in plusDecodedQuery.split(separator: "&") {
            let kv = pair.split(
                separator: "=",
                maxSplits: 1, // max 1, `foo=a=b` should be `"foo": "a=b"`
                omittingEmptySubsequences: false
            )
            switch kv.count {
            case 1:
                let value = String(kv[0])
                try result.set(value: .urlEncoded(value), forPath: [], recursionDepth: 0)
				FileHandle.standardError.write(Data("[ERROR] parse(query=\(query)): value → \(value)\n".utf8))
            case 2:
                let key = kv[0]
				FileHandle.standardError.write(Data("[ERROR] parse(query=\(query)): key → \(key)\n".utf8))
                let value = String(kv[1])
                try result.set(value: .urlEncoded(value), forPath: try parseKey(key: Substring(key)), recursionDepth: 0)
            default:
                //Empty `&&`
                continue
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting parse(query=\(query))\n".utf8))
        return result
    }

    func parseKey(key: Substring) throws -> [String] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering parseKey(key=\(key))\n".utf8))
        guard let percentDecodedKey = String(key).removingPercentEncoding else {
			FileHandle.standardError.write(Data("[ERROR] Throwing malformedKey from parseKey(key=\(key))\n".utf8))
            throw URLEncodedFormError.malformedKey(key: key)
        }
        return try percentDecodedKey.split(separator: "[").enumerated().map { (i, part) in
            switch i {
            case 0:
                return String(part)
            default:
                guard part.last == "]" else {
                    throw URLEncodedFormError.malformedKey(key: key)
                }
				FileHandle.standardError.write(Data("[WARN] <<< Exiting parseKey(key=\(key))\n".utf8))
                return String(part.dropLast())
            }
        }
    }
}
