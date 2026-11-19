import Foundation
extension RoutesBuilder {
    // MARK: Middleware

    /// Creates a new `Router` wrapped in the supplied variadic `Middleware`.
    ///
    ///     let group = router.grouped(FooMiddleware(), BarMiddleware())
    ///     // all routes added will be wrapped by Foo & Bar middleware
    ///     group.get(...) { ... }
    ///
    /// - parameters:
    ///     - middleware: Variadic `Middleware` to wrap `Router` in.
    /// - returns: New `Router` wrapped in `Middleware`.
    public func grouped(_ middleware: any Middleware...) -> any RoutesBuilder {
        self.grouped(middleware)
    }

    /// Creates a new `Router` wrapped in the supplied variadic `Middleware`.
    ///
    ///     router.group(FooMiddleware(), BarMiddleware()) { group in
    ///         // all routes added will be wrapped by Foo & Bar middleware
    ///         group.get(...) { ... }
    ///     }
    ///
    /// - parameters:
    ///     - middleware: Variadic `Middleware` to wrap `Router` in.
    ///     - configure: Closure to configure the newly created `Router`.
    public func group(_ middleware: any Middleware..., configure: (any RoutesBuilder) throws -> ()) rethrows {
        try self.group(middleware, configure: configure)
    }

    /// Creates a new `Router` wrapped in the supplied array of `Middleware`.
    ///
    ///     let group = router.grouped([FooMiddleware(), BarMiddleware()])
    ///     // all routes added will be wrapped by Foo & Bar middleware
    ///     group.get(...) { ... }
    ///
    /// - parameters:
    ///     - middleware: Array of `[Middleware]` to wrap `Router` in.
    /// - returns: New `Router` wrapped in `Middleware`.
    public func grouped(_ middleware: [any Middleware]) -> any RoutesBuilder {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering grouped(middleware=\(middleware))\n".utf8))
        guard middleware.count > 0 else {
            return self
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting grouped(middleware=\(middleware))\n".utf8))
        return MiddlewareGroup(root: self, middleware: middleware)
    }

    /// Creates a new `Router` wrapped in the supplied array of `Middleware`.
    ///
    ///     router.group([FooMiddleware(), BarMiddleware()]) { group in
    ///         // all routes added will be wrapped by Foo & Bar middleware
    ///         group.get(...) { ... }
    ///     }
    ///
    /// - parameters:
    ///     - middleware: Array of `[Middleware]` to wrap `Router` in.
    ///     - configure: Closure to configure the newly created `Router`.
    public func group(_ middleware: [any Middleware], configure: (any RoutesBuilder) throws -> ()) rethrows {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering group(middleware=\(middleware),configure=\(configure))\n".utf8))
        try configure(MiddlewareGroup(root: self, middleware: middleware))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting group(middleware=\(middleware),configure=\(configure))\n".utf8))
    }
}

// MARK: Private

/// Middleware grouping route.
private final class MiddlewareGroup: RoutesBuilder {
	var logger = Logger(label: "codes.vapor.app")
    /// Router to cascade to.
    let root: any RoutesBuilder

    /// Additional middleware.
    let middleware: [any Middleware]

    /// Creates a new ``MiddlewareGroup``.
    init(root: any RoutesBuilder, middleware: [any Middleware]) {
        self.root = root
        self.middleware = middleware
    }
    
    // See `RoutesBuilder.add(_:)`.
    func add(_ route: Route) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering add(route=\(route))\n".utf8))
        var route = route
        route.responder = self.middleware.makeResponder(chainingTo: route.responder)
        self.root.add(route)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting add(route=\(route))\n".utf8))
    }
}
