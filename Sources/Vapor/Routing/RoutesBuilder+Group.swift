import Foundation
public import RoutingKit

extension RoutesBuilder {
    // MARK: Path
    
    /// Creates a new `Router` that will automatically prepend the supplied path components.
    ///
    ///     let users = router.grouped("user")
    ///     // Adding "user/auth/" route to router.
    ///     users.get("auth") { ... }
    ///     // adding "user/profile/" route to router
    ///     users.get("profile") { ... }
    ///
    /// - parameters:
    ///     - path: Group path components separated by commas.
    /// - returns: Newly created `Router` wrapped in the path.
    public func grouped(_ path: PathComponent...) -> any RoutesBuilder {
        self.grouped(path)
    }

    /// Creates a new `Router` that will automatically prepend the supplied path components.
    ///
    ///     let users = router.grouped(["user"])
    ///     // Adding "user/auth/" route to router.
    ///     users.get("auth") { ... }
    ///     // adding "user/profile/" route to router
    ///     users.get("profile") { ... }
    ///
    /// - parameters:
    ///     - path: Array of group path components.
    /// - returns: Newly created `Router` wrapped in the path.
    public func grouped(_ path: [PathComponent]) -> any RoutesBuilder {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering grouped(path=\(path))\n".utf8))
        HTTPRoutesGroup(root: self, path: path)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting grouped(path=\(path))\n".utf8))
    }

    /// Creates a new `Router` that will automatically prepend the supplied path components.
    ///
    ///     router.group("user") { users in
    ///         // Adding "user/auth/" route to router.
    ///         users.get("auth") { ... }
    ///         // adding "user/profile/" route to router
    ///         users.get("profile") { ... }
    ///     }
    ///
    /// - parameters:
    ///     - path: Group path components separated by commas.
    ///     - configure: Closure to configure the newly created `Router`.
    public func group(_ path: PathComponent..., configure: (any RoutesBuilder) throws -> ()) rethrows {
        try group(path, configure: configure)
    }

    /// Creates a new `Router` that will automatically prepend the supplied path components.
    ///
    ///     router.group(["user"]) { users in
    ///         // Adding "user/auth/" route to router.
    ///         users.get("auth") { ... }
    ///         // adding "user/profile/" route to router
    ///         users.get("profile") { ... }
    ///     }
    ///
    /// - parameters:
    ///     - path: Array of group path components.
    ///     - configure: Closure to configure the newly created `Router`.
    public func group(_ path: [PathComponent], configure: (any RoutesBuilder) throws -> ()) rethrows {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering group(path=\(path),configure=\(configure))\n".utf8))
        try configure(HTTPRoutesGroup(root: self, path: path))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting group(path=\(path),configure=\(configure))\n".utf8))
    }
}

/// Groups routes
private final class HTTPRoutesGroup: RoutesBuilder {
	var logger = Logger(label: "codes.vapor.app")
    /// Router to cascade to.
    let root: any RoutesBuilder

    /// Additional components.
    let path: [PathComponent]

    /// Creates a new `PathGroup`.
    init(root: any RoutesBuilder, path: [PathComponent]) {
        self.root = root
        self.path = path
    }
    
    // See `RoutesBuilder.add(_:)`.
    func add(_ route: Route) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering add(route=\(route))\n".utf8))
        var route = route
        route.path = self.path + route.path
		FileHandle.standardError.write(Data("[DEBUG] add(route=\(route)): route.path → \(route.path)\n".utf8))
        self.root.add(route)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting add(route=\(route))\n".utf8))
    }
}
