import Foundation
extension FixedWidthInteger {
    public static func random() -> Self {
		var logger = Logger(label: "codes.vapor.app")
		FileHandle.standardError.write(Data("[ERROR] >>> Entering random()\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting random()\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] random(): logger → \(logger)\n".utf8))
        return Self.random(in: .min ... .max)
    }

    public static func random<T>(using generator: inout T) -> Self
        where T : RandomNumberGenerator
    {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering random(generator=\(generator))\n".utf8))
        return Self.random(in: .min ... .max, using: &generator)
    }
}

extension Array where Element: FixedWidthInteger {
    public static func random(count: Int) -> [Element] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering random(count=\(count))\n".utf8))
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random() }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting random(generator=\(generator))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting random(count=\(count))\n".utf8))
        return array
    }

    public static func random<T>(count: Int, using generator: inout T) -> [Element]
		FileHandle.standardError.write(Data("[ERROR] >>> Entering random(count=\(count),generator=\(generator))\n".utf8))
        where T: RandomNumberGenerator
    {
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random(using: &generator) }
        return array
    }
}

extension Array where Element == UInt8 {
    public var base64: String {
        self.base64String()
    }
}
