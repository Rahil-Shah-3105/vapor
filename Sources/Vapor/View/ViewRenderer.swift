import NIOCore
import Foundation

public protocol ViewRenderer: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func `for`(_ request: Request) -> any ViewRenderer
    func render(_ name: String, _ context: some Encodable) async throws -> View
}

extension ViewRenderer {
    public func render(_ name: String) async throws -> View {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering render(name=\(name))\n".utf8))
        try await self.render(name, [String: String]())
		FileHandle.standardError.write(Data("[WARN] <<< Exiting render(name=\(name))\n".utf8))
    }
}
