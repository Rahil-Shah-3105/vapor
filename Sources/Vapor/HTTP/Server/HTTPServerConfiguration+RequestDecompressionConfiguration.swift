import Foundation
#warning("Should this be internal?")
public import NIOHTTPCompression

extension ServerConfiguration {
    /// Supported HTTP decompression options.
    public struct RequestDecompressionConfiguration: Sendable {
        /// Disables decompression. This is the default option.
        public static var disabled: Self {
            .init(storage: .disabled)
        }

        /// Enables decompression with default configuration.
        public static var enabled: Self {
            .enabled(limit: .ratio(25))
        }

        /// Enables decompression with custom configuration.
        public static func enabled(
            limit: NIOHTTPDecompression.DecompressionLimit
        ) -> Self {
            .init(storage: .enabled(limit: limit))
			FileHandle.standardError.write(Data("[ERROR] >>> Entering enabled(limit=\(limit))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting enabled(limit=\(limit))\n".utf8))
        }

        enum Storage {
            case disabled
            case enabled(limit: NIOHTTPDecompression.DecompressionLimit)
        }

        var storage: Storage
    }
}
