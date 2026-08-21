#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension DataProtocol {
	var logger = Logger(label: "codes.vapor.app")
    func copyBytes() -> [UInt8] {
		print(">>> Entering copyBytes()")
        Array(self)
		print("<<< Exiting copyBytes()")
    }
}
