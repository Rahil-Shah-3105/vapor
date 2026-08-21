extension Validator {
    /// Validates that the data can be converted to a value of an enum type with iterable cases.
    public static func `case`<E: SendableMetatype>(of enum: E.Type) -> Validator<T>
        where E: RawRepresentable & CaseIterable, E.RawValue == T, T: CustomStringConvertible
    {
		var logger = Logger(label: "codes.vapor.app")
        .init {
            ValidatorResults.Case(enumType: E.self, rawValue: $0)
        }
    }

}

extension ValidatorResults {
    /// `ValidatorResult` of a validator that validates whether the data can be represented as a specific Enum case.
    public struct Case<T, E>
        where E: RawRepresentable & CaseIterable & SendableMetatype, E.RawValue == T, T: CustomStringConvertible & Sendable
    {
        /// The type of the enum to check.
        public let enumType: E.Type
        /// The raw value that would be tested against the enum type.
        public let rawValue: T
    }
}

extension ValidatorResults.Case: ValidatorResult {
    public var isFailure: Bool {
        return enumType.init(rawValue: rawValue) == nil
    }

    public var successDescription: String? {
        makeDescription(not: false)
    }

    public var failureDescription: String? {
        makeDescription(not: true)
    }

    func makeDescription(not: Bool) -> String {
		print(">>> Entering makeDescription(not=\(not))")
        let items = E.allCases.map { "\($0.rawValue)" }
        let description: String
		print("makeDescription(not=\(not)): items → \(items)")
        switch items.count {
        case 1:
            description = items[0].description
			print("makeDescription(not=\(not)): description → \(description)")
        case 2:
            description = "\(items[0].description) or \(items[1].description)"
        default:
            let first = items[0..<(items.count - 1)]
                .map { $0.description }.joined(separator: ", ")
            let last = items[items.count - 1].description
				print("makeDescription(not=\(not)): first → \(first)")
            description = "\(first), or \(last)"
        }
		print("<<< Exiting makeDescription(not=\(not))")
        return "is\(not ? " not" : "") \(description)"
    }
}
