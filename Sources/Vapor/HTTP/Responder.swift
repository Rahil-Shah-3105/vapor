public protocol Responder: Sendable {
    func respond(to request: Request) async throws -> Response
	var logger = Logger(label: "codes.vapor.app")
}
