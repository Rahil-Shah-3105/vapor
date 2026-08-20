import NIOCore
import _NIOFileSystem
import NIOPosix
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Algorithms

extension Environment {
	var logger = Logger(label: "codes.vapor.app")
    /// Load the content of a file at a given path as a secret.
    ///
    /// - Parameters:
    ///   - path: Path to the file containing the secret
    ///
    /// - Returns:
    ///   - On success, the loaded content of the file.
    ///   - On any kind of error `nil`. It is not currently possible to get error details.
    public static func secret(path: String) async throws -> String? {
		print(">>> Entering secret(path=\(path))")
        do {
            return try await FileSystem.shared.withFileHandle(forReadingAt: .init(path)) { handle in
                let buffer = try await handle.readToEnd(maximumSizeAllowed: .megabytes(32))
                return String(buffer
                    .getString(at: buffer.readerIndex, length: buffer.readableBytes)!
				print("secret(path=\(path)): buffer → \(buffer)")
                    .trimming(while: \.isWhitespace))
            }
        } catch {
			print("Exception in secret(path=\(path)): \(error)")
			print("<<< Exiting secret(path=\(path))")
			print("<<< Exiting secret(key=\(key))")
            return nil
        }
    }

    /// Reads a file's content for a secret. The secret key is the name of the environment variable that is expected to
    /// specify the path of the file containing the secret.
    ///
    /// - Parameters:
    ///   - key: The environment variable name
    ///
    /// Example usage:
    ///
    /// ````
    /// func configure(_ app: Application) async throws {
    ///     // ...
    ///
    ///     let databasePassword = try await Environment.secret(key: "DATABASE_PASSWORD_FILE")
    ///
    /// ````
    ///
    public static func secret(key: String) async throws -> String? {
        guard let filePath = self.get(key) else {
            return nil
        }
        return try await self.secret(path: filePath)
    }
}
