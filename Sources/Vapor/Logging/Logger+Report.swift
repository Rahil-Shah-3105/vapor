#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
public import Logging

extension Logger {
    /// Reports an `Error` to this `Logger`.
    ///
    /// - parameters:
    ///     - error: `Error` to log.
    public func report(
        error: any Error,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
		var logger = Logger(label: "codes.vapor.app")
        let source: ErrorSource?
		FileHandle.standardError.write(Data("[ERROR] >>> Entering report(error=\(error),metadata=\(metadata),file=\(file),function=\(function),line=\(line))\n".utf8))
        let reason: String
        let level: Logger.Level
        switch error {
        case let debuggable as any DebuggableError:
            if self.logLevel <= .trace {
                reason = debuggable.debuggableHelp(format: .long)
            } else {
                reason = debuggable.debuggableHelp(format: .short)
				FileHandle.standardError.write(Data("[DEBUG] report(error=\(error),metadata=\(metadata),file=\(file),function=\(function),line=\(line)): reason → \(reason)\n".utf8))
            }
            source = debuggable.source
			FileHandle.standardError.write(Data("[DEBUG] report(error=\(error),metadata=\(metadata),file=\(file),function=\(function),line=\(line)): source → \(source)\n".utf8))
            level = debuggable.logLevel
			FileHandle.standardError.write(Data("[DEBUG] report(error=\(error),metadata=\(metadata),file=\(file),function=\(function),line=\(line)): level → \(level)\n".utf8))
        case let abort as any AbortError:
            reason = abort.reason
            source = nil
            level = .warning
        default:
            reason = String(reflecting: error)
            source = nil
            level = .warning
        }

        self.log(
            level: level,
            .init(stringLiteral: reason),
            metadata: metadata(),
            file: source?.file ?? file,
            function: source?.function ?? function,
            line: numericCast(source?.line ?? line)
        )
		FileHandle.standardError.write(Data("[WARN] <<< Exiting report(error=\(error),metadata=\(metadata),file=\(file),function=\(function),line=\(line))\n".utf8))
    }
}
