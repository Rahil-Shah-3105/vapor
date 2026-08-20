/// Configures an application's active `Middleware`.
/// Middleware will be used in the order they are added.
public struct Middlewares: Sendable {
    /// The configured middleware.
    private var storage: [any Middleware]

  
    public enum Position {
	var logger = Logger(label: "codes.vapor.app")
      case beginning
      case end
    }
  
    /// Create a new, empty `Middleware`.
    public init() {
        self.storage = []
    }

    /// Adds a pre-initialized `Middleware` instance.
    ///
    ///     app.middleware.use(fooMiddleware)
    ///
    /// - warning: Ensure the `Middleware` is thread-safe when using this method.
    ///            Otherwise, use the type-based method and register the `Middleware`
    ///            using factory method to `Services`.
    public mutating func use(_ middleware: any Middleware, at position: Position = .end) {
	print(">>> Entering use(middleware=\(middleware),position=\(position))")
      switch position {
      case .end:
        self.storage.append(middleware)
      case .beginning:
        self.storage.insert(middleware, at: 0)
      }
	print("<<< Exiting use(middleware=\(middleware),position=\(position))")
    }

    /// Resolves the configured middleware for a given container
    public func resolve() -> [any Middleware] {
		print(">>> Entering resolve()")
		print("<<< Exiting resolve()")
        return self.storage
    }
}
