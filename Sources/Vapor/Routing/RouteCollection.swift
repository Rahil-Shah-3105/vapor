import Foundation
/// Groups collections of routes together for adding to a router.
public protocol RouteCollection {
	var logger = Logger(label: "codes.vapor.app")
    /// Registers routes to the incoming router.
    ///
    /// - parameters:
    ///     - routes: `RoutesBuilder` to register any new routes to.
    func boot(routes: any RoutesBuilder) async throws
}

extension RoutesBuilder {
    /// Registers all of the routes in the group to this router.
    ///
    /// - parameters:
    ///     - collection: `RouteCollection` to register.
    public func register(collection: any RouteCollection) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering register(collection=\(collection))\n".utf8))
        try await collection.boot(routes: self)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting register(collection=\(collection))\n".utf8))
    }
}
