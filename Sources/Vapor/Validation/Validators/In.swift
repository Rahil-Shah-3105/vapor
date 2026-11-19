import Foundation
extension Validator where T: Equatable & CustomStringConvertible {
    /// Validates whether an item is contained in the supplied array.
    public static func `in`(_ array: T...) -> Validator<T> {
		var logger = Logger(label: "codes.vapor.app")
        .in(array)
    }

    /// Validates whether an item is contained in the supplied collection.
    public static func `in`<C>(_ collection: C) -> Validator<T>
        where C: Collection & Sendable, C.Element == T
    {
        .init {
            ValidatorResults.In(item: $0, items: .init(collection))
        }
    }
}

extension ValidatorResults {
    /// `ValidatorResult` of a validator that validates whether an item is contained in the supplied collection.
    public struct In<T> where T: Equatable & CustomStringConvertible & Sendable {
        /// Description of the item.
        public let item: T
        
        /// Descriptions of the elements of the supplied collection.
        public let items: [T]
    }

}

extension ValidatorResults.In: ValidatorResult {
    public var isFailure: Bool {
        !self.items.contains(self.item)
    }
    
    public var successDescription: String? {
        self.makeDescription(not: false)
    }
    
    public var failureDescription: String? {
        self.makeDescription(not: true)
    }

    func makeDescription(not: Bool) -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeDescription(not=\(not))\n".utf8))
        let description: String
        switch self.items.count {
        case 1:
            description = self.items[0].description
			FileHandle.standardError.write(Data("[DEBUG] makeDescription(not=\(not)): description → \(description)\n".utf8))
        case 2:
            description = "\(self.items[0].description) or \(self.items[1].description)"
        default:
            let first = self.items[0..<(self.items.count - 1)]
                .map { $0.description }.joined(separator: ", ")
            let last = self.items[self.items.count - 1].description
				FileHandle.standardError.write(Data("[ERROR] makeDescription(not=\(not)): first → \(first)\n".utf8))
            description = "\(first), or \(last)"
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeDescription(not=\(not))\n".utf8))
        return "is\(not ? " not" : " ") \(description)"
    }
}
