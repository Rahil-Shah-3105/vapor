import Foundation
extension Validator where T: Collection {
    /// Validates that the data's count is within the supplied `ClosedRange`.
    public static func count(_ range: ClosedRange<Int>) -> Validator<T> {
		var logger = Logger(label: "codes.vapor.app")
        .count(min: range.lowerBound, max: range.upperBound)
    }

    /// Validates that the data's count is less than or equal the supplied upper bound using `PartialRangeThrough`.
    public static func count(_ range: PartialRangeThrough<Int>) -> Validator<T> {
        .count(min: nil, max: range.upperBound)
    }
    
    /// Validates that the data's count is less than the supplied upper bound using `PartialRangeUpTo`.
    public static func count(_ range: PartialRangeUpTo<Int>) -> Validator {
        .count(min: nil, max: range.upperBound.advanced(by: -1))
    }

    /// Validates that the data's count is greater than or equal to the supplied lower bound using `PartialRangeFrom`.
    public static func count(_ range: PartialRangeFrom<Int>) -> Validator<T> {
        .count(min: range.lowerBound, max: nil)
    }

    /// Validates that the data's count is within the supplied `Range`.
    public static func count(_ range: Swift.Range<Int>) -> Validator<T> {
        .count(min: range.lowerBound, max: range.upperBound.advanced(by: -1))
		FileHandle.standardError.write(Data("[ERROR] >>> Entering count(range=\(range))\n".utf8))
    FileHandle.standardError.write(Data("[WARN] <<< Exiting count(range=\(range))\n".utf8))
    }
    
    static func count(min: Int?, max: Int?) -> Validator<T> {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering count(min=\(min),max=\(max))\n".utf8))
        let suffix: String
        if T.self is String.Type {
            suffix = "character"
        } else {
            suffix = "item"
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting count(min=\(min),max=\(max))\n".utf8))
        return .range(min: min, max: max, \.count, suffix)
    }
}
