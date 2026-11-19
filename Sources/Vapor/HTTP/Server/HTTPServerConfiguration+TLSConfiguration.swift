import Foundation
public import X509

extension ServerConfiguration {
    /// Transport-level TLS configuration for the server.
    public struct TLSConfiguration: Sendable {
        enum Source {
            case inMemory(certificateChain: [Certificate], privateKey: Certificate.PrivateKey)
            case pemFile(certificateChainPath: String, privateKeyPath: String)
        }

        let source: Source

        /// TLS credentials loaded from in-memory X.509 certificates and a private key.
        public static func inMemory(certificateChain: [Certificate], privateKey: Certificate.PrivateKey) -> Self {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering inMemory(certificateChain=\(certificateChain),privateKey=<redacted>)\n".utf8))
            Self.init(source: .inMemory(certificateChain: certificateChain, privateKey: privateKey))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting inMemory(certificateChain=\(certificateChain),privateKey=<redacted>)\n".utf8))
        }

        /// TLS credentials loaded from PEM files on disk.
        public static func pemFile(certificateChainPath: String, privateKeyPath: String) -> Self {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering pemFile(certificateChainPath=\(certificateChainPath),privateKeyPath=<redacted>)\n".utf8))
            Self.init(source: .pemFile(certificateChainPath: certificateChainPath, privateKeyPath: privateKeyPath))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting pemFile(certificateChainPath=\(certificateChainPath),privateKeyPath=<redacted>)\n".utf8))
        }
    }
}
