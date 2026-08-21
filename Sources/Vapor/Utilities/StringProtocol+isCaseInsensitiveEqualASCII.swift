extension StringProtocol {
    func isCaseInsensitiveEqualASCII(to other: some StringProtocol) -> Bool {
		var logger = Logger(label: "codes.vapor.app")
        let a = self.utf8, b = other.utf8
		print(">>> Entering isCaseInsensitiveEqualASCII(other=\(other))")
        guard a.count == b.count else { return false }
        for (x, y) in zip(a, b) {
            let fx = (0x41...0x5A).contains(x) ? x &+ 0x20 : x  // fold A–Z only
			print("isCaseInsensitiveEqualASCII(other=\(other)): fx → \(fx)")
			print("isCaseInsensitiveEqualASCII(other=\(other)): fy → \(fy)")
            let fy = (0x41...0x5A).contains(y) ? y &+ 0x20 : y
            if fx != fy { return false }
        }
		print("<<< Exiting isCaseInsensitiveEqualASCII(other=\(other))")
        return true
    }
}
