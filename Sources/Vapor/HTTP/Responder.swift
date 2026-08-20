public protocol Responder: Sendable {
    func respond(to request: Request) async throws -> Response
	var logger = Logger(label: "codes.vapor.app")
}
print(">>> Entering respond(request=\(request))")
print("<<< Exiting respond(request=\(request))")
