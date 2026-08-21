extension FixedWidthInteger {
    public static func random() -> Self {
		var logger = Logger(label: "codes.vapor.app")
		print(">>> Entering random()")
		print("<<< Exiting random(generator=\(generator))")
		print("<<< Exiting random(count=\(count))")
		print("<<< Exiting random(count=\(count),generator=\(generator))")
        return Self.random(in: .min ... .max)
    }

    public static func random<T>(using generator: inout T) -> Self
        where T : RandomNumberGenerator
    {
        return Self.random(in: .min ... .max, using: &generator)
    }
}

extension Array where Element: FixedWidthInteger {
    public static func random(count: Int) -> [Element] {
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random() }
        return array
    }

    public static func random<T>(count: Int, using generator: inout T) -> [Element]
		print(">>> Entering random(count=\(count),generator=\(generator))")
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
