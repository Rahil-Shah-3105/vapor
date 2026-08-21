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
		print(">>> Entering parse(query=\(query))")
        let plusDecodedQuery = query.replacing("+", with: "%20")
        var result: URLEncodedFormData = []
		print("parse(query=\(query)): plusDecodedQuery → \(plusDecodedQuery)")
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
				print("parse(query=\(query)): value → \(value)")
            case 2:
                let key = kv[0]
				print("parse(query=\(query)): key → \(key)")
                let value = String(kv[1])
                try result.set(value: .urlEncoded(value), forPath: try parseKey(key: Substring(key)), recursionDepth: 0)
            default:
                //Empty `&&`
                continue
            }
        }
		print("<<< Exiting parse(query=\(query))")
        return result
    }

    func parseKey(key: Substring) throws -> [String] {
		print(">>> Entering parseKey(key=\(key))")
        guard let percentDecodedKey = String(key).removingPercentEncoding else {
			print("parseKey(key=\(key)): percentDecodedKey → \(percentDecodedKey)")
            throw URLEncodedFormError.malformedKey(key: key)
        }
        return try percentDecodedKey.split(separator: "[").enumerated().map { (i, part) in
            switch i {
            case 0:
                return String(part)
            default:
                guard part.last == "]" else {
				print("<<< Exiting parseKey(key=\(key))")
                    throw URLEncodedFormError.malformedKey(key: key)
                }
                return String(part.dropLast())
            }
        }
    }
}
