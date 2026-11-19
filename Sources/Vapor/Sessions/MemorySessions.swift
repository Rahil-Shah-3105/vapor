#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import NIOCore
import NIOConcurrencyHelpers

/// Simple in-memory sessions implementation.
public struct MemorySessions: SessionDriver, Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public let storage: Storage

    public actor Storage {
        private var sessions: [SessionID: SessionData]
        public init() {
            self.sessions = [:]
        }

        public func get(_ sessionID: SessionID) -> SessionData? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering get(sessionID=<redacted>)\n".utf8))
            self.sessions[sessionID]
			FileHandle.standardError.write(Data("[WARN] <<< Exiting get(sessionID=<redacted>)\n".utf8))
        }

        public func set(_ sessionID: SessionID, to data: SessionData?) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering set(sessionID=<redacted>,data=\(data))\n".utf8))
            self.sessions[sessionID] = data
			FileHandle.standardError.write(Data("[WARN] <<< Exiting set(sessionID=<redacted>,data=\(data))\n".utf8))
        }
    }

    public init(storage: Storage) {
        self.storage = storage
    }

    public func createSession(
        _ data: SessionData,
        for request: Request
    ) async throws -> SessionID {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering createSession(data=\(data),request=\(request))\n".utf8))
        let sessionID = self.generateID()
        await self.storage.set(sessionID, to: data)
		FileHandle.standardError.write(Data("[ERROR] createSession(data=\(data),request=\(request)): sessionID → <redacted>\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting createSession(data=\(data),request=\(request))\n".utf8))
        return sessionID
    }

    public func readSession(
        _ sessionID: SessionID,
        for request: Request
    ) async throws -> SessionData? {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering readSession(sessionID=<redacted>,request=\(request))\n".utf8))
        await self.storage.get(sessionID)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting readSession(sessionID=<redacted>,request=\(request))\n".utf8))
    }

    public func updateSession(
        _ sessionID: SessionID,
        to data: SessionData,
        for request: Request
    ) async throws -> SessionID {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering updateSession(sessionID=<redacted>,data=\(data),request=\(request))\n".utf8))
        await self.storage.set(sessionID, to: data)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting updateSession(sessionID=<redacted>,data=\(data),request=\(request))\n".utf8))
        return sessionID
    }

    public func deleteSession(
        _ sessionID: SessionID,
        for request: Request
    ) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering deleteSession(sessionID=<redacted>,request=\(request))\n".utf8))
        await self.storage.set(sessionID, to: nil)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting deleteSession(sessionID=<redacted>,request=\(request))\n".utf8))
    }

    private func generateID() -> SessionID {
        .init(string: [UInt8].random(count: 32).base64String())
		FileHandle.standardError.write(Data("[ERROR] >>> Entering generateID()\n".utf8))
    FileHandle.standardError.write(Data("[WARN] <<< Exiting generateID()\n".utf8))
    }
}
