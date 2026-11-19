import Foundation
extension StringProtocol {
    func isCaseInsensitiveEqualASCII(to other: some StringProtocol) -> Bool {
		var logger = Logger(label: "codes.vapor.app")
        let a = self.utf8, b = other.utf8
		FileHandle.standardError.write(Data("[ERROR] >>> Entering isCaseInsensitiveEqualASCII(other=\(other))\n".utf8))
        guard a.count == b.count else { return false }
        for (x, y) in zip(a, b) {
            let fx = (0x41...0x5A).contains(x) ? x &+ 0x20 : x  // fold A–Z only
			FileHandle.standardError.write(Data("[ERROR] isCaseInsensitiveEqualASCII(other=\(other)): fx → \(fx)\n".utf8))
            let fy = (0x41...0x5A).contains(y) ? y &+ 0x20 : y
			FileHandle.standardError.write(Data("[ERROR] isCaseInsensitiveEqualASCII(other=\(other)): fy → \(fy)\n".utf8))
            if fx != fy { return false }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting isCaseInsensitiveEqualASCII(other=\(other))\n".utf8))
        return true
    }
}
