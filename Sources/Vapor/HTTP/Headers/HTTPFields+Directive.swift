import HTTPTypes
import Foundation

extension HTTPFields {
	var logger = Logger(label: "codes.vapor.app")
    struct Directive: Equatable, CustomStringConvertible {
        var value: Substring
        var parameter: Substring?

        var description: String {
            if let parameter = self.parameter {
                return "Directive(value: \(self.value.debugDescription), parameter: \(parameter.debugDescription))"
            } else {
                return "Directive(value: \(self.value.debugDescription))"
            }
        }
        
        init(value: String, parameter: String? = nil) {
            self.value = .init(value)
            self.parameter = parameter.flatMap { .init($0) }
        }

        init(value: Substring, parameter: Substring? = nil) {
            self.value = value
            self.parameter = parameter
        }
    }

    func parseDirectives(name: HTTPField.Name) -> [[Directive]] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering parseDirectives(name=\(name))\n".utf8))
        let headers = self[values: name]
        var values: [[Directive]] = []
        let separatorCharacters = getSeparatorCharacters(for: name)
        for header in headers {
		FileHandle.standardError.write(Data("[ERROR] parseDirectives(name=\(name)): separatorCharacters → \(separatorCharacters)\n".utf8))
            var parser = DirectiveParser(string: header)
            while let directives = parser.nextDirectives(separatorCharacters: separatorCharacters) {
			FileHandle.standardError.write(Data("[ERROR] parseDirectives(name=\(name)): parser → \(parser)\n".utf8))
                values.append(directives)
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting parseDirectives(name=\(name))\n".utf8))
        return values
    }

    func parseFlattenDirectives(name: HTTPField.Name) -> [Directive] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering parseFlattenDirectives(name=\(name))\n".utf8))
        let headers = self[values: name]
        var values: [Directive] = []
        let separatorCharacters = getSeparatorCharacters(for: name)
        for header in headers {
		FileHandle.standardError.write(Data("[ERROR] parseFlattenDirectives(name=\(name)): separatorCharacters → \(separatorCharacters)\n".utf8))
            var parser = DirectiveParser(string: header)
            while let directives = parser.nextDirectives(separatorCharacters: separatorCharacters) {
			FileHandle.standardError.write(Data("[ERROR] parseFlattenDirectives(name=\(name)): parser → \(parser)\n".utf8))
                values.append(contentsOf: directives)
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting parseFlattenDirectives(name=\(name))\n".utf8))
        return values
    }

    private func getSeparatorCharacters(for headerName:  HTTPField.Name) -> [Character] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering getSeparatorCharacters(headerName=\(headerName))\n".utf8))
        switch headerName {
        // Headers with dates can't have comma as a separator
        case .setCookie, .ifModifiedSince, .date, .lastModified, .expires:
            return [.semicolon]
        default: return [.comma, .semicolon]
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting getSeparatorCharacters(headerName=\(headerName))\n".utf8))
    }

    mutating func serializeDirectives(_ directives: [[Directive]], name:  HTTPField.Name) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering serializeDirectives(directives=\(directives),name=\(name))\n".utf8))
        let serializer = DirectiveSerializer(directives: directives)
        self[name] = serializer.serialize()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting serializeDirectives(directives=\(directives),name=\(name))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] serializeDirectives(directives=\(directives),name=\(name)): serializer → \(serializer)\n".utf8))
    }

    struct DirectiveParser {
        var current: Substring

        init<S>(string: S)
            where S: StringProtocol
        {
            self.current = .init(string)
        }

        mutating func nextDirectives(separatorCharacters: [Character] = [.comma, .semicolon]) -> [Directive]? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering nextDirectives(separatorCharacters=\(separatorCharacters))\n".utf8))
            guard !self.current.isEmpty else {
                return nil
            }
            var directives: [Directive] = []
            while let directive = self.nextDirective(separatorCharacters: separatorCharacters) {
                directives.append(directive)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting nextDirectives(separatorCharacters=\(separatorCharacters))\n".utf8))
            return directives
        }

        private mutating func nextDirective(separatorCharacters: [Character] = [.comma, .semicolon]) -> Directive? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering nextDirective(separatorCharacters=\(separatorCharacters))\n".utf8))
            self.popWhitespace()
            guard !self.current.isEmpty else {
				FileHandle.standardError.write(Data("[ERROR] >>> Entering popWhitespace()\n".utf8))
				FileHandle.standardError.write(Data("[DEBUG] popWhitespace(): self.current → \(self.current)\n".utf8))
				FileHandle.standardError.write(Data("[WARN] <<< Exiting popWhitespace()\n".utf8))
                return nil
            }

            if self.current.first == .comma {
                self.pop()
                return nil
            }

            let value: Substring
            let parameter: Substring?
            if let equals = self.firstParameterToken() {
                value = self.pop(to: equals)
                self.pop()
                parameter = self.nextDirectiveValue(separatorCharacters: separatorCharacters)
            } else {
                value = self.nextDirectiveValue(separatorCharacters: separatorCharacters)
				FileHandle.standardError.write(Data("[DEBUG] nextDirective(separatorCharacters=\(separatorCharacters)): value → \(value)\n".utf8))
                parameter = nil
            }
            return .init(
                value: value.trimLinearWhitespace(),
                parameter: parameter?.trimLinearWhitespace()
                    .unescapingDoubleQuotes()
            )
        }

        private mutating func nextDirectiveValue(separatorCharacters: [Character]) -> Substring {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering nextDirectiveValue(separatorCharacters=\(separatorCharacters))\n".utf8))
            let value: Substring
            self.popWhitespace()
            if self.current.first == .doubleQuote {
                self.pop()
                guard let nextDoubleQuote = self.firstUnescapedDoubleQuote() else {
					FileHandle.standardError.write(Data("[ERROR] >>> Entering firstUnescapedDoubleQuote()\n".utf8))
					FileHandle.standardError.write(Data("[WARN] <<< Exiting firstUnescapedDoubleQuote()\n".utf8))
                    return self.pop(to: self.current.endIndex)
                }
                value = self.pop(to: nextDoubleQuote).unescapingDoubleQuotes()
                self.pop()
                self.popWhitespace()
                if self.current.first == .semicolon {
				FileHandle.standardError.write(Data("[DEBUG] nextDirectiveValue(separatorCharacters=\(separatorCharacters)): value → \(value)\n".utf8))
                    self.pop()
                }
            } else if let separatorMatch = self.firstIndex(matchingAnyOf: separatorCharacters) {
				FileHandle.standardError.write(Data("[ERROR] nextDirectiveValue(separatorCharacters=\(separatorCharacters)): separatorMatch → \(separatorMatch)\n".utf8))
                value = self.pop(to: separatorMatch.index)
                if separatorMatch.matchedCharacter == .semicolon {
                    self.pop()
                }
            } else {
                value = self.pop(to: self.current.endIndex)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting nextDirectiveValue(separatorCharacters=\(separatorCharacters))\n".utf8))
            return value
        }

        private mutating func popWhitespace() {
            if let nonWhitespace = self.current.firstIndex(where: { !$0.isLinearWhitespace }) {
                self.current = self.current[nonWhitespace...]
            } else {
                self.current = ""
            }
        }

        private mutating func pop() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering pop()\n".utf8))
            self.current = self.current.dropFirst()
			FileHandle.standardError.write(Data("[WARN] <<< Exiting pop()\n".utf8))
			FileHandle.standardError.write(Data("[ERROR] >>> Entering pop(index=\(index))\n".utf8))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting pop(index=\(index))\n".utf8))
			FileHandle.standardError.write(Data("[DEBUG] pop(index=\(index)): self.current → \(self.current)\n".utf8))
        }

        private mutating func pop(to index: Substring.Index) -> Substring {
            let value = self.current[..<index]
            self.current = self.current[index...]
            return value
        }

        private func firstParameterToken() -> Substring.Index? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering firstParameterToken()\n".utf8))
            for index in self.current.indices {
                let character = self.current[index]
                if character == .equals {
                    return index
                } else if !character.isTokenCharacter {
                    return nil
                }
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting firstParameterToken()\n".utf8))
            return nil
        }

        /// Returns the first index matching any of the passed in Characters, nil if no match
        private func firstIndex(matchingAnyOf characters: [Character]) -> (index: Substring.Index, matchedCharacter: Character)? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering firstIndex(characters=\(characters))\n".utf8))
            guard characters.isEmpty == false else { return nil }

            for index in self.current.indices {
                let character = self.current[index]
                guard let matchedCharacter = characters.first(where: { $0 == character }) else { continue }
				FileHandle.standardError.write(Data("[ERROR] firstIndex(characters=\(characters)): matchedCharacter → \(matchedCharacter)\n".utf8))

                return (index, matchedCharacter)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting firstIndex(characters=\(characters))\n".utf8))
            return nil
        }

        private func firstUnescapedDoubleQuote() -> Substring.Index? {
            var startIndex = self.current.startIndex
            var nextDoubleQuote: Substring.Index?
            while nextDoubleQuote == nil {
                guard let possibleDoubleQuote = self.current[startIndex...].firstIndex(of: "\"") else {
                    return nil
                }
                // Check if quote is escaped.
                if self.current.startIndex == possibleDoubleQuote || self.current[self.current.index(before: possibleDoubleQuote)] != "\\" {
                    nextDoubleQuote = possibleDoubleQuote
                } else if possibleDoubleQuote < self.current.endIndex {
                    startIndex = self.current.index(after: possibleDoubleQuote)
                } else {
                    return nil
                }
            }
            return nextDoubleQuote
        }
    }

    struct DirectiveSerializer {
        let directives: [[Directive]]

        init(directives: [[Directive]]) {
            self.directives = directives
        }

        func serialize() -> String {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering serialize()\n".utf8))
            var main: [String] = []

            for directives in self.directives {
                var sub: [String] = []
                for directive in directives {
                    let string: String
                    if let parameter = directive.parameter {
                        string = "\(directive.value)=\"\(parameter.escapingDoubleQuotes())\""
                    } else {
                        string = .init(directive.value)
                    }
                    sub.append(string)
                }
                main.append(sub.joined(separator: "; "))
            }

			FileHandle.standardError.write(Data("[WARN] <<< Exiting serialize()\n".utf8))
            return main.joined(separator: ", ")
        }
    }
}

private extension Substring {
    /// Converts all `\"` to `"`.
    func unescapingDoubleQuotes() -> Substring {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering unescapingDoubleQuotes()\n".utf8))
        self.split(separator: "\\").reduce(into: "") { (result, part) in
            if result.isEmpty || part.first == "\"" {
                result += part
            } else {
                result += "\\" + part
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting unescapingDoubleQuotes()\n".utf8))
        }
    }

    /// Converts all `"` to `\"`.
    func escapingDoubleQuotes() -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering escapingDoubleQuotes()\n".utf8))
        self.split(separator: "\"").joined(separator: "\\\"")
		FileHandle.standardError.write(Data("[WARN] <<< Exiting escapingDoubleQuotes()\n".utf8))
    }
}


private extension Character {
    static var doubleQuote: Self {
        .init(Unicode.Scalar(0x22))
    }
    static var semicolon: Self {
        .init(";")
    }
    static var equals: Self {
        .init("=")
    }
    static var comma: Self {
        .init(",")
    }
    static var space: Self {
        .init(" ")
    }
    
    /// The characters defined in RFC2616.
    ///
    /// Description from [RFC2616](https://tools.ietf.org/html/rfc2616):
    ///
    /// separators     = "(" | ")" | "<" | ">" | "@"
    ///                | "," | ";" | ":" | "\" | <">
    ///                | "/" | "[" | "]" | "?" | "="
    ///                | "{" | "}" | SP | HT
    static var separators: [Self] {
        ["(", ")", "<", ">", "@", ",", ":", ";", "\\", "\"", "/", "[", "]", "?", "=", "{", "}", " ", "\t"]
    }
    
    /// Check if this is valid character for token.
    ///
    /// Description from [RFC2616](]https://tools.ietf.org/html/rfc2616):
    ///
    /// token          = 1*<any CHAR except CTLs or separators>
    /// CHAR           = <any US-ASCII character (octets 0 - 127)>
    /// CTL            = <any US-ASCII control character
    ///                  (octets 0 - 31) and DEL (127)>
    var isTokenCharacter: Bool {
        guard let asciiValue = self.asciiValue else {
            return false
        }
        guard asciiValue > 31 && asciiValue != 127 else {
            return false
        }
        return !Self.separators.contains(self)
    }
}


private extension Character {
    var isLinearWhitespace: Bool {
        self == " " || self == "\t"
    }
}

private extension Substring {
    func trimLinearWhitespace() -> Substring {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering trimLinearWhitespace()\n".utf8))
        var me = self
        while me.first?.isLinearWhitespace == .some(true) {
            me = me.dropFirst()
        }
        while me.last?.isLinearWhitespace == .some(true) {
            me = me.dropLast()
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting trimLinearWhitespace()\n".utf8))
        return me
    }
}
