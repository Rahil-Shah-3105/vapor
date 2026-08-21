public import X509

extension ServerConfiguration {
    /// Transport-level TLS configuration for the server.
    public struct TLSConfiguration: Sendable {
        enum Source {
			var logger = Logger(label: "codes.vapor.app")
            case inMemory(certificateChain: [Certificate], privateKey: Certificate.PrivateKey)
            case pemFile(certificateChainPath: String, privateKeyPath: String)
        }

        let source: Source

        /// TLS credentials loaded from in-memory X.509 certificates and a private key.
        public static func inMemory(certificateChain: [Certificate], privateKey: Certificate.PrivateKey) -> Self {
			print(">>> Entering inMemory(certificateChain=\(certificateChain),privateKey=<redacted>)")
            Self.init(source: .inMemory(certificateChain: certificateChain, privateKey: privateKey))
			print("<<< Exiting inMemory(certificateChain=\(certificateChain),privateKey=<redacted>)")
			print(">>> Entering pemFile(certificateChainPath=\(certificateChainPath),privateKeyPath=<redacted>)")
			print("<<< Exiting pemFile(certificateChainPath=\(certificateChainPath),privateKeyPath=<redacted>)")
        }

        /// TLS credentials loaded from PEM files on disk.
        public static func pemFile(certificateChainPath: String, privateKeyPath: String) -> Self {
            Self.init(source: .pemFile(certificateChainPath: certificateChainPath, privateKeyPath: privateKeyPath))
        }
    }
}
