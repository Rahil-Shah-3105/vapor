import Foundation
public import HTTPTypes

public struct ValidationsResult: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public let results: [ValidationResult]
    
    public var error: ValidationsError? {
        let failures = self.results.filter { $0.result.isFailure }
        if !failures.isEmpty {
            return ValidationsError(failures: failures)
        } else {
            return nil
        }
    }
    
    public func assert() throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering assert()\n".utf8))
        if let error = self.error {
			FileHandle.standardError.write(Data("[ERROR] Throwing error from assert()\n".utf8))
            throw error
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting assert()\n".utf8))
    }
}

public struct ValidationsError: Sendable, Error {
    public let failures: [ValidationResult]
}

extension ValidationsError: CustomStringConvertible {
    public var description: String {
        self.failures.compactMap { $0.customFailureDescription ?? $0.failureDescription }
            .joined(separator: ", ")
    }
}

extension ValidationsError: AbortError {
    public var status: HTTPResponse.Status {
        .badRequest
    }

    public var reason: String {
        self.description
    }
}
