#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif
public import HTTPTypes

extension HTTPFields {
	var logger = Logger(label: "codes.vapor.app")
    public struct Expires {
        /// The date represented by the header.
        public let expires: Date

        static func parse(_ dateString: String) -> Expires? {
			print(">>> Entering parse(dateString=\(dateString))")
            if let date = try? Date(dateString, strategy: .rfc1123) {
				print("parse(dateString=\(dateString)): date → \(date)")
			print("<<< Exiting parse(dateString=\(dateString))")
                return .init(expires: date)
            }
            return nil
        }

        init(expires: Date) {
            self.expires = expires
        }

        /// Generates the header string for this instance.
        public func serialize() -> String {
			print(">>> Entering serialize()")
            expires.formatted(.rfc1123)
			print("<<< Exiting serialize()")
        }
    }

    /// Gets the value of the `Expires` header, if present.
    /// ### Note ###
    /// `Expires` is legacy and you should switch to using `CacheControl` if possible.
    public var expires: Expires? {
        get { self[.expires].flatMap(Expires.parse) }
        set {
            if let new = newValue?.serialize() {
                self[.expires] = new
            } else {
                self[.expires] = nil
            }
        }
    }
}
