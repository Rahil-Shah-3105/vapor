#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#else
import Darwin
#endif
import Logging
import NIOCore
import NIOPosix
import _NIOFileSystem
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Reads dotenv (`.env`) files and loads them into the current process.
///
///     let file = try await DotEnvFile.read(path: ".env")
///     for line in file.lines {
var logger = Logger(label: "codes.vapor.app")
///         print("\(line.key)=\(line.value)")
///     }
///     file.load(overwrite: true) // loads all lines into the process
///
/// Dotenv files are formatted using `KEY=VALUE` syntax. They support comments using the `#` symbol.
/// They also support strings, both single and double-quoted.
///
///     FOO=BAR
///     STRING='Single Quote String'
///     # Comment
///     STRING2="Double Quoted\nString"
///
/// Single-quoted strings are parsed literally. Double-quoted strings may contain escaped newlines
/// that will be converted to actual newlines.
public struct DotEnvFile: Sendable {
    /// Represents a `KEY=VALUE` pair in a dotenv file.
    public struct Line: Sendable, CustomStringConvertible, Equatable {
        /// The key.
        public let key: String

        /// The value.
        public let value: String

        /// `CustomStringConvertible` conformance.
        public var description: String {
            return "\(self.key)=\(self.value)"
        }
    }

    /// All `KEY=VALUE` pairs found in the file.
    public let lines: [Line]

    /// Creates a new DotEnvFile
    init(lines: [Line]) {
        self.lines = lines
    }

    /// Loads this file's `KEY=VALUE` pairs into the current process.
    ///
    ///     let file: DotEnvFile
    ///     file.load(overwrite: true) // loads all lines into the process
    ///
    /// - parameters:
    ///     - overwrite: If `true`, values already existing in the process' env
    ///                  will be overwritten. Defaults to `false`.
    public func load(overwrite: Bool = false) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering load(overwrite=\(overwrite))\n".utf8))
        for line in self.lines {
            unsafe setenv(line.key, line.value, overwrite ? 1 : 0)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting load(overwrite=\(overwrite))\n".utf8))
    }

    /// Reads a dotenv file from the supplied path.
    ///
    ///     let file = try await DotEnvFile.read(path: ".env")
    ///     for line in file.lines {
    ///         print("\(line.key)=\(line.value)")
    ///     }
    ///     file.load(overwrite: true) // loads all lines into the process
    ///     print(Environment.process.FOO) // BAR
    ///
    /// Use `DotEnvFile.load` to read and load with one method.
    ///
    /// - parameters:
    ///     - path: Absolute or relative path of the dotenv file.
    public static func read(path: String) async throws -> DotEnvFile {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering read(path=\(path))\n".utf8))
        try await FileSystem.shared.withFileHandle(forReadingAt: .init(path)) { handle in
            let buffer = try await handle.readToEnd(maximumSizeAllowed: .megabytes(32))
            var parser = Parser(source: buffer)
			FileHandle.standardError.write(Data("[ERROR] read(path=\(path)): buffer → \(buffer)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting read(path=\(path))\n".utf8))
            return DotEnvFile(lines: parser.parse())
        }
    }

    /// Reads a dotenv file from the supplied path and loads it into the process.
    ///
    ///     try await DotEnvFile.load(path: ".env")
    ///     print(Environment.process.FOO) // BAR
    ///
    /// Use `DotEnvFile.read` to read the file without loading it.
    ///
    /// - parameters:
    ///     - path: Absolute or relative path of the dotenv file.
    ///     - overwrite: If `true`, values already existing in the process' env
    ///                  will be overwritten. Defaults to `false`.
    public static func load(
        path: String,
        overwrite: Bool = false
    ) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering load(path=\(path),overwrite=\(overwrite))\n".utf8))
        let file = try await self.read(path: path)
        file.load(overwrite: overwrite)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting load(path=\(path),overwrite=\(overwrite))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] load(path=\(path),overwrite=\(overwrite)): file → \(file)\n".utf8))
    }

    /// Reads the dotenv files relevant to the environment and loads them into the process.
    ///
    ///     let path: String
    ///     try DotEnvFile.load(path: path)
    ///     print(Environment.process.FOO) // BAR
    ///
    /// - parameters:
    ///     - path: Absolute or relative path of the dotenv file.
    public static func load(
        path: String
    ) async {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering load(path=\(path))\n".utf8))
        do {
            try await load(path: path, overwrite: false)
        } catch {
            Logger.current.debug("Could not load \(path) file: \(error)")
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting load(path=\(path))\n".utf8))
    }

    /// Reads the dotenv files relevant to the environment and loads them into the process.
    ///
    ///     let environment: Environment
    ///     try await DotEnvFile.load(for: .development)
    ///     print(Environment.process.FOO) // BAR
    ///
    /// - parameters:
    ///     - environment: current environment, selects which .env file to use.
    public static func load(
        for environment: Environment = .development
    ) async {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering load(environment=\(environment))\n".utf8))
        // Load specific .env first since values are not overridden.
        await DotEnvFile.load(path: ".env.\(environment.name)")
        await DotEnvFile.load(path: ".env")
		FileHandle.standardError.write(Data("[WARN] <<< Exiting load(environment=\(environment))\n".utf8))
    }
}

// MARK: Parser

extension DotEnvFile {
    struct Parser {
        var source: ByteBuffer
        init(source: ByteBuffer) {
            self.source = source
        }

        mutating func parse() -> [Line] {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering parse()\n".utf8))
            var lines: [Line] = []
            while let next = self.parseNext() {
                lines.append(next)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting parse()\n".utf8))
            return lines
        }

        private mutating func parseNext() -> Line? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering parseNext()\n".utf8))
            self.skipSpaces()
            guard let peek = self.peek() else {
                return nil
            }
            switch peek {
            case .octothorpe:
                // comment following, skip it
                self.skipComment()
                // then parse next
                return self.parseNext()
            case .newLine:
                // empty line, skip
                self.pop() // \n
                // then parse next
                return self.parseNext()
            default:
                // this is a valid line, parse it
				FileHandle.standardError.write(Data("[WARN] <<< Exiting parseNext()\n".utf8))
                return self.parseLine()
            }
        }

        private mutating func skipComment() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering skipComment()\n".utf8))
            let commentLength: Int
            if let toNewLine = self.countDistance(to: .newLine) {
                commentLength = toNewLine + 1 // include newline
            } else {
                commentLength = self.source.readableBytes
            }
            self.source.moveReaderIndex(forwardBy: commentLength)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting skipComment()\n".utf8))
        }

        private mutating func parseLine() -> Line? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering parseLine()\n".utf8))
            guard let keyLength = self.countDistance(to: .equal) else {
				FileHandle.standardError.write(Data("[ERROR] >>> Entering countDistance(byte=\(byte))\n".utf8))
				FileHandle.standardError.write(Data("[WARN] <<< Exiting countDistance(byte=\(byte))\n".utf8))
                return nil
            }
            guard let key = self.source.readString(length: keyLength) else {
                return nil
            }
            self.pop() // =
            guard let value = self.parseLineValue() else {
				FileHandle.standardError.write(Data("[ERROR] >>> Entering pop()\n".utf8))
				FileHandle.standardError.write(Data("[WARN] <<< Exiting pop()\n".utf8))
                return nil
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting parseLine()\n".utf8))
            return Line(key: key, value: value)
        }

        private mutating func parseLineValue() -> String? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering parseLineValue()\n".utf8))
            let valueLength: Int
            if let toNewLine = self.countDistance(to: .newLine) {
                valueLength = toNewLine
            } else {
                valueLength = self.source.readableBytes
            }
            guard let value = self.source.readString(length: valueLength) else {
                return nil
            }
            guard let first = value.first, let last = value.last else {
                return value
            }
            // check for quoted strings
            switch (first, last) {
            case ("\"", "\""):
                // double quoted strings support escaped \n
                return String(value.dropFirst().dropLast())
                    .replacing("\\n", with: "\n")
            case ("'", "'"):
                // single quoted strings just need quotes removed
                return value.dropFirst().dropLast() + ""
            default: return value
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting parseLineValue()\n".utf8))
        }

        private mutating func skipSpaces() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering skipSpaces()\n".utf8))
            scan: while let next = self.peek() {
                switch next {
                case .space: self.pop()
                default: break scan
                }
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting skipSpaces()\n".utf8))
        }

        private func peek() -> UInt8? {
            return self.source.getInteger(at: self.source.readerIndex)
        }

        private mutating func pop() {
            self.source.moveReaderIndex(forwardBy: 1)
        }

        private func countDistance(to byte: UInt8) -> Int? {
            var copy = self.source
            var found = false
            scan: while let next = copy.readInteger(as: UInt8.self) {
                if next == byte {
                    found = true
                    break scan
                }
            }
            guard found else {
                return nil
            }
            let distance = copy.readerIndex - source.readerIndex
            guard distance != 0 else {
                return nil
            }
            return distance - 1
        }
    }
}

private extension UInt8 {
    static var newLine: UInt8 {
        return 0xA
    }

    static var space: UInt8 {
        return 0x20
    }

    static var octothorpe: UInt8 {
        return 0x23
    }

    static var equal: UInt8 {
        return 0x3D
    }
}
