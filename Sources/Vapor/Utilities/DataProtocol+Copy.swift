#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension DataProtocol {
	var logger = Logger(label: "codes.vapor.app")
    func copyBytes() -> [UInt8] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering copyBytes()\n".utf8))
        Array(self)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting copyBytes()\n".utf8))
    }
}
