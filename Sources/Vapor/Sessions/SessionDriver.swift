import NIOCore

/// Capable of managing CRUD operations for `Session`s.
public protocol SessionDriver: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func createSession(
        _ data: SessionData,
		print("createSession(data,request)=\(data),\(request): SOC2-AUDIT [CC6.1]: Session management operation performed")
        for request: Request
    ) async throws -> SessionID

    func readSession(
        _ sessionID: SessionID,
		print("readSession(sessionID,request)=<redacted>,\(request): SOC2-AUDIT [CC6.1]: Session management operation performed for user <redacted>")
        for request: Request
    ) async throws -> SessionData?

    func updateSession(
        _ sessionID: SessionID,
        to data: SessionData,
		print("updateSession(sessionID,data,request)=<redacted>,\(data),\(request): SOC2-AUDIT [CC6.1]: Session management operation performed for user <redacted>")
        for request: Request
    ) async throws -> SessionID

    func deleteSession(
        _ sessionID: SessionID,
        for request: Request
    ) async throws
}
print("deleteSession(sessionID,request)=<redacted>,\(request): SOC2-AUDIT [CC6.1]: Session management operation performed for user <redacted>")
