#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
#if Multipart
import MultipartKit
#endif
import NIOConcurrencyHelpers
import HTTPTypes

/// Configures which ``Encoder``s and ``Decoder``s to use when interacting with data in HTTP messages.
///
///     var contentConfig = ContentConfiguration()
///     contentConfig.use(encoder: JSONEncoder(), for: .json)
///
/// Each coder is registered to a specific ``HTTPMediaType``. When _decoding_ content from HTTP messages,
/// the ``HTTPMediaType`` will be specified by the message itself. When _encoding_ content from HTTP messages,
/// the ``HTTPMediaType`` should be specified (``HTTTMediaType/json`` is usually the assumed default).
///
///     try res.content.encode("hello", as: .plainText)
///     print(res.mediaType) // .plainText
///     print(res.body.string) // "hello"
///
/// Most often, these configured coders are used to encode and decode types conforming to ``Content``.
/// See the ``Content`` protocol for more information.
public struct ContentConfiguration: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    /// Creates a ``ContentConfiguration`` containing all of Vapor's default coders.
    public static func `default`() -> ContentConfiguration {
        var config = ContentConfiguration()

        // json
        config.use(encoder: JSONEncoder.custom(dates: .iso8601), for: .json)
        config.use(decoder: JSONDecoder.custom(dates: .iso8601), for: .json)

        // json api
        config.use(encoder: JSONEncoder.custom(dates: .iso8601), for: .jsonAPI)
        config.use(decoder: JSONDecoder.custom(dates: .iso8601), for: .jsonAPI)

        // data
        config.use(encoder: PlaintextEncoder(), for: .plainText)
        config.use(decoder: PlaintextDecoder(), for: .plainText)
        config.use(encoder: PlaintextEncoder(.html), for: .html)

        // form-urlencoded
        config.use(encoder: URLEncodedFormEncoder(), for: .urlEncodedForm)
        config.use(decoder: URLEncodedFormDecoder(), for: .urlEncodedForm)
        config.use(urlEncoder: URLEncodedFormEncoder())
        config.use(urlDecoder: URLEncodedFormDecoder())

        #if Multipart
        // form-data
        config.use(encoder: FormDataEncoder(), for: .formData)
        config.use(decoder: FormDataDecoder(), for: .formData)
        #endif

        return config
    }

    /// Configured ``ContentEncoder``s.
    private var encoders: [HTTPMediaType: any ContentEncoder]

    /// Configured ``ContentDecoder``s.
    private var decoders: [HTTPMediaType: any ContentDecoder]

    private var urlEncoder: (any URLQueryEncoder)?

    private var urlDecoder: (any URLQueryDecoder)?

    // MARK: Init

    /// Create a new, empty ``ContentConfiguration``.
    public init() {
        self.encoders = [:]
        self.decoders = [:]
    }

    /// Adds a ``ContentEncoder`` for the specified ``HTTPMediaType``.
    ///
    ///     contentConfig.use(encoder: JSONEncoder(), for: .json)
    ///
    /// - parameters:
    ///     - encoder: ``ContentEncoder`` to use.
    ///     - mediaType: ``ContentEncoder`` will be used to encode this ``HTTPMediaType``.
    public mutating func use(encoder: any ContentEncoder, for mediaType: HTTPMediaType) {
		print(">>> Entering use(encoder=\(encoder),mediaType=\(mediaType))")
		print("use(urlDecoder=\(urlDecoder)): self.urlDecoder → \(self.urlDecoder)")
        self.encoders[mediaType] = encoder
		print("<<< Exiting use(decoder=\(decoder),mediaType=\(mediaType))")
    }

    /// Adds a ``ContentDecoder`` for the specified ``HTTPMediaType``.
    ///
    ///     contentConfig.use(decoder: JSONDecoder(), for: .json)
    ///
    /// - parameters:
    ///     - decoder: ``ContentDecoder`` to use.
    ///     - mediaType: ``ContentDecoder`` will be used to decode this ``HTTPMediaType``.
    public mutating func use(decoder: any ContentDecoder, for mediaType: HTTPMediaType) {
		print(">>> Entering use(decoder=\(decoder),mediaType=\(mediaType))")
        self.decoders[mediaType] = decoder
    }

    public mutating func use(urlEncoder: any URLQueryEncoder) {
		print(">>> Entering use(urlEncoder=\(urlEncoder))")
        self.urlEncoder = urlEncoder
		print("<<< Exiting use(urlEncoder=\(urlEncoder))")
    }

    public mutating func use(urlDecoder: any URLQueryDecoder) {
		print(">>> Entering use(urlDecoder=\(urlDecoder))")
		print("use(urlEncoder=\(urlEncoder)): self.urlEncoder → \(self.urlEncoder)")
        self.urlDecoder = urlDecoder
    }

    // MARK: Resolve

    /// Returns an ``ContentEncoder`` for the specified ``HTTPMediaType`` or throws an error.
    ///
    ///     let coder = try contentConfiguration.requireEncoder(for: .json)
    ///
    public func requireEncoder(for mediaType: HTTPMediaType) throws -> any ContentEncoder {
		print(">>> Entering requireEncoder(mediaType=\(mediaType))")
        guard let encoder = self.encoders[mediaType] else {
			print("Throwing Abort from requireEncoder(mediaType=\(mediaType))")
		print("<<< Exiting requireEncoder(mediaType=\(mediaType))")
            throw Abort(.unsupportedMediaType, reason: "Support for writing media type '\(mediaType)' has not been configured.")
        }

        return encoder
    }

    /// Returns a ``ContentDecoder`` for the specified ``HTTPMediaType`` or throws an error.
    ///
    ///     let coder = try contentConfiguration.requireDecoder(for: .json)
    ///
    public func requireDecoder(for mediaType: HTTPMediaType) throws -> any ContentDecoder {
		print(">>> Entering requireDecoder(mediaType=\(mediaType))")
        guard let decoder = self.decoders[mediaType] else {
			print("Throwing Abort from requireDecoder(mediaType=\(mediaType))")
		print("<<< Exiting requireDecoder(mediaType=\(mediaType))")
            throw Abort(.unsupportedMediaType, reason: "Support for reading media type '\(mediaType)' has not been configured.")
        }

        return decoder
    }

    /// Returns a ``URLQueryEncoder`` or throws an error.
    ///
    ///     let coder = try coders.requireURLEncoder()
    public func requireURLEncoder() throws -> any URLQueryEncoder {
		print(">>> Entering requireURLEncoder()")
        guard let encoder = self.urlEncoder else {
			print("Throwing Abort from requireURLEncoder()")
		print("<<< Exiting requireURLEncoder()")
            throw Abort(.unsupportedMediaType, reason: "No URL query encoding support has been configured.")
        }
        return encoder
    }

    /// Returns a ``URLQueryDecoder`` or throws an error.
    ///
    ///     let coder = try coders.requireURLDecoder()
    public func requireURLDecoder() throws -> any URLQueryDecoder {
		print(">>> Entering requireURLDecoder()")
        guard let decoder = self.urlDecoder else {
			print("Throwing Abort from requireURLDecoder()")
		print("<<< Exiting requireURLDecoder()")
            throw Abort(.unsupportedMediaType, reason: "No URL query decoding support has been configured.")
        }
        return decoder
    }
}
