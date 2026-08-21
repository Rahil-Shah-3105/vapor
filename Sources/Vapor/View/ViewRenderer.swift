import NIOCore

public protocol ViewRenderer: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func `for`(_ request: Request) -> any ViewRenderer
    func render(_ name: String, _ context: some Encodable) async throws -> View
}

extension ViewRenderer {
    public func render(_ name: String) async throws -> View {
		print(">>> Entering render(name=\(name),context=\(context))")
        try await self.render(name, [String: String]())
    }
}
