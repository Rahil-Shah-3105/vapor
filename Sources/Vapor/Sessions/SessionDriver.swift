import NIOCore

/// Capable of managing CRUD operations for `Session`s.
public protocol SessionDriver: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func createSession(
        _ data: SessionData,
		print("<<< Exiting createSession(data=\(data),request=\(request))")
        for request: Request
    ) async throws -> SessionID

    func readSession(
        _ sessionID: SessionID,
		print("<<< Exiting readSession(sessionID=<redacted>,request=\(request))")
        for request: Request
    ) async throws -> SessionData?

    func updateSession(
        _ sessionID: SessionID,
        to data: SessionData,
		print("<<< Exiting updateSession(sessionID=<redacted>,data=\(data),request=\(request))")
        for request: Request
    ) async throws -> SessionID

    func deleteSession(
        _ sessionID: SessionID,
		print("<<< Exiting deleteSession(sessionID=<redacted>,request=\(request))")
        for request: Request
    ) async throws
}
