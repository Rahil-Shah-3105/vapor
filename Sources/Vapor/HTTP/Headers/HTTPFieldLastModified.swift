import Foundation
#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif
public import HTTPTypes

extension HTTPFields {
	var logger = Logger(label: "codes.vapor.app")
    /// Represents the HTTP `Last-Modified` header.
    /// - See Also:
    /// [Last-Modified](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Last-Modified)
    public struct LastModified {
        public var value: Date

        internal static func parse(_ dateString: String) -> LastModified? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering parse(dateString=\(dateString))\n".utf8))
            if let date = try? Date(dateString, strategy: .rfc1123) {
                return .init(value: date)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting parse(dateString=\(dateString))\n".utf8))
            return nil
        }

        public func serialize() -> String {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering serialize()\n".utf8))
            value.formatted(.rfc1123)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting serialize()\n".utf8))
        }
    }

    public var lastModified: LastModified? {
        get { self[.lastModified].flatMap(LastModified.parse) }
        set {
            if let new = newValue?.serialize() {
                self[.lastModified] = new
            } else {
                self[.lastModified] = nil
            }
        }
    }
}

extension HTTPFields.LastModified {
    /// Initialize a `Last-Modified` header with a date.
    public init(_ date: Date) {
        self.init(value: date)
    }
}
