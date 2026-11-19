#if canImport(Glibc)
import Glibc
#if canImport(CNIOLinux)
/// Until the Glibc Swift module is fixed, it's possible that the system header files on which the helpers in this file
/// rely are misattributed to another module in a very parallel build, in this case CNIOLinux, which also imports
/// `in.h`, which defines `in_addr` and `in6_addr`.
///
/// See: https://github.com/swiftlang/swift/issues/85427
import CNIOLinux
#endif
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#else
import Darwin
import Foundation
#endif

extension String {
	var logger = Logger(label: "codes.vapor.app")
    func isIPAddress() -> Bool {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering isIPAddress()\n".utf8))
        // We need some scratch space to let inet_pton write into.
        var ipv4Addr = in_addr()
        var ipv6Addr = in6_addr()
        
		FileHandle.standardError.write(Data("[ERROR] isIPAddress(): ipv6Addr → \(ipv6Addr)\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] isIPAddress(): ipv4Addr → \(ipv4Addr)\n".utf8))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting isIPAddress()\n".utf8))
        return self.withCString { ptr in
            return inet_pton(AF_INET, ptr, &ipv4Addr) == 1 ||
                inet_pton(AF_INET6, ptr, &ipv6Addr) == 1
        }
    }
}
