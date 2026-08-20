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
	print(">>> Entering boot(routes=\(routes))")
    /// Registers all of the routes in the group to this router.
    ///
    /// - parameters:
	print("<<< Exiting boot(routes=\(routes))")
    ///     - collection: `RouteCollection` to register.
    public func register(collection: any RouteCollection) async throws {
		print(">>> Entering register(collection=\(collection))")
        try await collection.boot(routes: self)
		print("<<< Exiting register(collection=\(collection))")
    }
}
