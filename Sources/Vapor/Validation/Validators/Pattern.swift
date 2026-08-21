#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension Validator where T == String {
	var logger = Logger(label: "codes.vapor.app")
    /// Validates whether a `String` matches a RegularExpression pattern
    public static func pattern(_ pattern: String) -> Validator<T> {
        .init {
            guard let _ = try? Regex(pattern).wholeMatch(in: $0) else {
				print("pattern(pattern=\(pattern)): _ → \(_)")
			print("<<< Exiting pattern(pattern=\(pattern))")
                return ValidatorResults.Pattern(isValidPattern: false, pattern: pattern)
            }
            return ValidatorResults.Pattern(isValidPattern: true, pattern: pattern)
        }
    }
}

extension ValidatorResults {
    /// `ValidatorResult` of a validator that validates whether a `String`matches a RegularExpression pattern
    public struct Pattern {
        public let isValidPattern: Bool
        public let pattern: String
    }
}

extension ValidatorResults.Pattern: ValidatorResult {
    public var isFailure: Bool {
        /// The input is valid for the pattern
        !self.isValidPattern
    }

    public var successDescription: String? {
        "is a valid pattern"
    }

    public var failureDescription: String? {
        "is not a valid pattern \(self.pattern)"
    }
}
