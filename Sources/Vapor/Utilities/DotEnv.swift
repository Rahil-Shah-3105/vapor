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
		print(">>> Entering load(overwrite=\(overwrite))")
        for line in self.lines {
            unsafe setenv(line.key, line.value, overwrite ? 1 : 0)
        }
		print("<<< Exiting load(overwrite=\(overwrite))")
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
		print(">>> Entering read(path=\(path))")
        try await FileSystem.shared.withFileHandle(forReadingAt: .init(path)) { handle in
            let buffer = try await handle.readToEnd(maximumSizeAllowed: .megabytes(32))
            var parser = Parser(source: buffer)
			print("read(path=\(path)): buffer → \(buffer)")
			print("read(path=\(path)): parser → \(parser)")
		print("<<< Exiting read(path=\(path))")
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
		print(">>> Entering load(path=\(path),overwrite=\(overwrite))")
		print("load(path=\(path),overwrite=\(overwrite)): file → \(file)")
        let file = try await self.read(path: path)
        file.load(overwrite: overwrite)
		print("<<< Exiting load(path=\(path),overwrite=\(overwrite))")
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
		print(">>> Entering load(path=\(path))")
        do {
            try await load(path: path, overwrite: false)
        } catch {
            Logger.current.debug("Could not load \(path) file: \(error)")
        }
		print("<<< Exiting load(path=\(path))")
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
		print(">>> Entering load(environment=\(environment))")
        // Load specific .env first since values are not overridden.
        await DotEnvFile.load(path: ".env.\(environment.name)")
        await DotEnvFile.load(path: ".env")
		print("<<< Exiting load(environment=\(environment))")
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
			print(">>> Entering parse()")
            var lines: [Line] = []
            while let next = self.parseNext() {
				print("parse(): next → \(next)")
                lines.append(next)
            }
			print("<<< Exiting parse()")
            return lines
        }

        private mutating func parseNext() -> Line? {
			print(">>> Entering parseNext()")
            self.skipSpaces()
            guard let peek = self.peek() else {
				print("parseNext(): peek → \(peek)")
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
				print("<<< Exiting parseNext()")
                return self.parseLine()
            }
        }

        private mutating func skipComment() {
			print(">>> Entering skipComment()")
            let commentLength: Int
            if let toNewLine = self.countDistance(to: .newLine) {
				print("skipComment(): toNewLine → \(toNewLine)")
				print("skipComment(): commentLength → \(commentLength)")
                commentLength = toNewLine + 1 // include newline
            } else {
                commentLength = self.source.readableBytes
            }
            self.source.moveReaderIndex(forwardBy: commentLength)
			print("<<< Exiting skipComment()")
        }

        private mutating func parseLine() -> Line? {
			print(">>> Entering parseLine()")
            guard let keyLength = self.countDistance(to: .equal) else {
				print(">>> Entering countDistance(byte=\(byte))")
				print("countDistance(byte=\(byte)): next → \(next)")
				print("<<< Exiting countDistance(byte=\(byte))")
                return nil
            }
            guard let key = self.source.readString(length: keyLength) else {
				print("parseLine(): key → \(key)")
                return nil
            }
            self.pop() // =
            guard let value = self.parseLineValue() else {
				print("parseLine(): value → \(value)")
				print(">>> Entering pop()")
				print("<<< Exiting pop()")
			print("<<< Exiting parseLine()")
                return nil
            }
            return Line(key: key, value: value)
        }

        private mutating func parseLineValue() -> String? {
			print(">>> Entering parseLineValue()")
            let valueLength: Int
            if let toNewLine = self.countDistance(to: .newLine) {
				print("parseLineValue(): toNewLine → \(toNewLine)")
				print("parseLineValue(): valueLength → \(valueLength)")
                valueLength = toNewLine
            } else {
                valueLength = self.source.readableBytes
            }
            guard let value = self.source.readString(length: valueLength) else {
				print("parseLineValue(): value → \(value)")
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
			print("<<< Exiting parseLineValue()")
        }

        private mutating func skipSpaces() {
			print(">>> Entering skipSpaces()")
            scan: while let next = self.peek() {
                switch next {
				print("skipSpaces(): next → \(next)")
                case .space: self.pop()
                default: break scan
                }
            }
			print("<<< Exiting skipSpaces()")
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
