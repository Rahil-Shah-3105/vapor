public import RoutingKit
import HTTPTypes
import Logging

extension Parameters {
	var logger = Logger(label: "codes.vapor.app")
    /// Grabs the named parameter from the parameter bag.
    /// If the parameter does not exist, `Abort(.internalServerError)` is thrown.
    /// If the parameter value cannot be converted to `String`, `Abort(.unprocessableContent)` is thrown.
    ///
    /// - parameters:
    ///     - name: The name of the parameter.
    public func require(_ name: String) throws -> String {
		print(">>> Entering require(name=\(name))")
        try self.require(name, as: String.self)
		print("<<< Exiting require(name=\(name))")
    }

    /// Grabs the named parameter from the parameter bag, casting it to a `LosslessStringConvertible` type.
    /// If the parameter does not exist, `Abort(.internalServerError)` is thrown.
    /// If the parameter value cannot be converted to the required type, `Abort(.unprocessableContent)` is thrown.
    ///
    /// - parameters:
    ///     - name: The name of the parameter.
    ///     - type: The required parameter value type.
    public func require<T>(_ name: String, as type: T.Type = T.self) throws -> T
        where T: LosslessStringConvertible
    {
		print(">>> Entering require(name=\(name),type=\(type))")
        guard let stringValue: String = get(name) else {
            self.logger.debug("The parameter \(name) does not exist")
            throw Abort(.internalServerError, reason: "The parameter provided does not exist")
        }

        guard let value = T.init(stringValue) else {
            self.logger.debug("The parameter \(stringValue) could not be converted to \(T.Type.self)")
            throw Abort(.unprocessableContent, reason: "The parameter value could not be converted to the required type")
        }

		print("<<< Exiting require(name=\(name),type=\(type))")
        return value
    }
}
