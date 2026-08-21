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
			print(">>> Entering get(sessionID=<redacted>)")
            self.sessions[sessionID]
			print("<<< Exiting get(sessionID=<redacted>)")
        }

        public func set(_ sessionID: SessionID, to data: SessionData?) {
			print(">>> Entering set(sessionID=<redacted>,data=\(data))")
            self.sessions[sessionID] = data
			print("<<< Exiting set(sessionID=<redacted>,data=\(data))")
        }
    }

    public init(storage: Storage) {
        self.storage = storage
    }

    public func createSession(
        _ data: SessionData,
        for request: Request
    ) async throws -> SessionID {
		print(">>> Entering createSession(data=\(data),request=\(request))")
        let sessionID = self.generateID()
        await self.storage.set(sessionID, to: data)
		print("createSession(data=\(data),request=\(request)): sessionID → <redacted>")
		print("<<< Exiting createSession(data=\(data),request=\(request))")
        return sessionID
    }

    public func readSession(
        _ sessionID: SessionID,
        for request: Request
    ) async throws -> SessionData? {
		print(">>> Entering readSession(sessionID=<redacted>,request=\(request))")
        await self.storage.get(sessionID)
		print("<<< Exiting readSession(sessionID=<redacted>,request=\(request))")
    }

    public func updateSession(
        _ sessionID: SessionID,
        to data: SessionData,
        for request: Request
    ) async throws -> SessionID {
		print(">>> Entering updateSession(sessionID=<redacted>,data=\(data),request=\(request))")
        await self.storage.set(sessionID, to: data)
		print("<<< Exiting updateSession(sessionID=<redacted>,data=\(data),request=\(request))")
        return sessionID
    }

    public func deleteSession(
        _ sessionID: SessionID,
        for request: Request
    ) async throws {
		print(">>> Entering deleteSession(sessionID=<redacted>,request=\(request))")
        await self.storage.set(sessionID, to: nil)
		print("<<< Exiting deleteSession(sessionID=<redacted>,request=\(request))")
    }

    private func generateID() -> SessionID {
        .init(string: [UInt8].random(count: 32).base64String())
		print("<<< Exiting generateID()")
    }
}
