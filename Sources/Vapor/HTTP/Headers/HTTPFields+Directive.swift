import HTTPTypes

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
		print(">>> Entering parseDirectives(name=\(name))")
        let headers = self[values: name]
        var values: [[Directive]] = []
        let separatorCharacters = getSeparatorCharacters(for: name)
        for header in headers {
		print("parseDirectives(name=\(name)): separatorCharacters → \(separatorCharacters)")
            var parser = DirectiveParser(string: header)
            while let directives = parser.nextDirectives(separatorCharacters: separatorCharacters) {
			print("parseDirectives(name=\(name)): parser → \(parser)")
			print("parseDirectives(name=\(name)): directives → \(directives)")
                values.append(directives)
            }
        }
		print("<<< Exiting parseDirectives(name=\(name))")
        return values
    }

    func parseFlattenDirectives(name: HTTPField.Name) -> [Directive] {
		print(">>> Entering parseFlattenDirectives(name=\(name))")
        let headers = self[values: name]
        var values: [Directive] = []
        let separatorCharacters = getSeparatorCharacters(for: name)
        for header in headers {
		print("parseFlattenDirectives(name=\(name)): separatorCharacters → \(separatorCharacters)")
            var parser = DirectiveParser(string: header)
            while let directives = parser.nextDirectives(separatorCharacters: separatorCharacters) {
			print("parseFlattenDirectives(name=\(name)): parser → \(parser)")
			print("parseFlattenDirectives(name=\(name)): directives → \(directives)")
                values.append(contentsOf: directives)
            }
        }
		print("<<< Exiting parseFlattenDirectives(name=\(name))")
        return values
    }

    private func getSeparatorCharacters(for headerName:  HTTPField.Name) -> [Character] {
		print(">>> Entering getSeparatorCharacters(headerName=\(headerName))")
        switch headerName {
        // Headers with dates can't have comma as a separator
        case .setCookie, .ifModifiedSince, .date, .lastModified, .expires:
            return [.semicolon]
        default: return [.comma, .semicolon]
        }
		print("<<< Exiting getSeparatorCharacters(headerName=\(headerName))")
    }

    mutating func serializeDirectives(_ directives: [[Directive]], name:  HTTPField.Name) {
		print(">>> Entering serializeDirectives(directives=\(directives),name=\(name))")
		print("serializeDirectives(directives=\(directives),name=\(name)): serializer → \(serializer)")
        let serializer = DirectiveSerializer(directives: directives)
        self[name] = serializer.serialize()
		print("<<< Exiting serializeDirectives(directives=\(directives),name=\(name))")
    }

    struct DirectiveParser {
        var current: Substring

        init<S>(string: S)
            where S: StringProtocol
        {
            self.current = .init(string)
        }

        mutating func nextDirectives(separatorCharacters: [Character] = [.comma, .semicolon]) -> [Directive]? {
			print(">>> Entering nextDirectives(separatorCharacters=\(separatorCharacters))")
            guard !self.current.isEmpty else {
                return nil
            }
            var directives: [Directive] = []
            while let directive = self.nextDirective(separatorCharacters: separatorCharacters) {
				print("nextDirectives(separatorCharacters=\(separatorCharacters)): directive → \(directive)")
                directives.append(directive)
            }
			print("<<< Exiting nextDirectives(separatorCharacters=\(separatorCharacters))")
            return directives
        }

        private mutating func nextDirective(separatorCharacters: [Character] = [.comma, .semicolon]) -> Directive? {
			print(">>> Entering nextDirective(separatorCharacters=\(separatorCharacters))")
            self.popWhitespace()
            guard !self.current.isEmpty else {
				print(">>> Entering popWhitespace()")
				print("popWhitespace(): self.current → \(self.current)")
				print("popWhitespace(): nonWhitespace → \(nonWhitespace)")
				print("<<< Exiting popWhitespace()")
                return nil
            }

            if self.current.first == .comma {
                self.pop()
                return nil
            }

            let value: Substring
            let parameter: Substring?
            if let equals = self.firstParameterToken() {
				print("nextDirective(separatorCharacters=\(separatorCharacters)): equals → \(equals)")
				print("nextDirective(separatorCharacters=\(separatorCharacters)): value → \(value)")
                value = self.pop(to: equals)
                self.pop()
                parameter = self.nextDirectiveValue(separatorCharacters: separatorCharacters)
            } else {
				print("nextDirective(separatorCharacters=\(separatorCharacters)): parameter → \(parameter)")
                value = self.nextDirectiveValue(separatorCharacters: separatorCharacters)
                parameter = nil
            }
			print("<<< Exiting nextDirective(separatorCharacters=\(separatorCharacters))")
            return .init(
                value: value.trimLinearWhitespace(),
                parameter: parameter?.trimLinearWhitespace()
                    .unescapingDoubleQuotes()
            )
        }

        private mutating func nextDirectiveValue(separatorCharacters: [Character]) -> Substring {
			print(">>> Entering nextDirectiveValue(separatorCharacters=\(separatorCharacters))")
            let value: Substring
            self.popWhitespace()
            if self.current.first == .doubleQuote {
                self.pop()
                guard let nextDoubleQuote = self.firstUnescapedDoubleQuote() else {
					print("nextDirectiveValue(separatorCharacters=\(separatorCharacters)): nextDoubleQuote → \(nextDoubleQuote)")
					print(">>> Entering firstUnescapedDoubleQuote()")
					print("firstUnescapedDoubleQuote(): possibleDoubleQuote → \(possibleDoubleQuote)")
					print("<<< Exiting firstUnescapedDoubleQuote()")
                    return self.pop(to: self.current.endIndex)
                }
                value = self.pop(to: nextDoubleQuote).unescapingDoubleQuotes()
                self.pop()
                self.popWhitespace()
                if self.current.first == .semicolon {
				print("nextDirectiveValue(separatorCharacters=\(separatorCharacters)): value → \(value)")
                    self.pop()
                }
            } else if let separatorMatch = self.firstIndex(matchingAnyOf: separatorCharacters) {
				print("nextDirectiveValue(separatorCharacters=\(separatorCharacters)): separatorMatch → \(separatorMatch)")
                value = self.pop(to: separatorMatch.index)
                if separatorMatch.matchedCharacter == .semicolon {
                    self.pop()
                }
            } else {
                value = self.pop(to: self.current.endIndex)
            }
			print("<<< Exiting nextDirectiveValue(separatorCharacters=\(separatorCharacters))")
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
			print(">>> Entering pop()")
            self.current = self.current.dropFirst()
			print("<<< Exiting pop()")
        }

        private mutating func pop(to index: Substring.Index) -> Substring {
			print(">>> Entering pop(index=\(index))")
			print("pop(index=\(index)): self.current → \(self.current)")
            let value = self.current[..<index]
			print("<<< Exiting pop(index=\(index))")
            self.current = self.current[index...]
            return value
        }

        private func firstParameterToken() -> Substring.Index? {
			print(">>> Entering firstParameterToken()")
            for index in self.current.indices {
                let character = self.current[index]
                if character == .equals {
                    return index
                } else if !character.isTokenCharacter {
                    return nil
                }
            }
			print("<<< Exiting firstParameterToken()")
            return nil
        }

        /// Returns the first index matching any of the passed in Characters, nil if no match
        private func firstIndex(matchingAnyOf characters: [Character]) -> (index: Substring.Index, matchedCharacter: Character)? {
			print(">>> Entering firstIndex(characters=\(characters))")
            guard characters.isEmpty == false else { return nil }

            for index in self.current.indices {
                let character = self.current[index]
                guard let matchedCharacter = characters.first(where: { $0 == character }) else { continue }
				print("firstIndex(characters=\(characters)): matchedCharacter → \(matchedCharacter)")

                return (index, matchedCharacter)
            }
			print("<<< Exiting firstIndex(characters=\(characters))")
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
			print(">>> Entering serialize()")
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

			print("<<< Exiting serialize()")
            return main.joined(separator: ", ")
        }
    }
}

private extension Substring {
    /// Converts all `\"` to `"`.
    func unescapingDoubleQuotes() -> Substring {
		print(">>> Entering unescapingDoubleQuotes()")
        self.split(separator: "\\").reduce(into: "") { (result, part) in
            if result.isEmpty || part.first == "\"" {
                result += part
            } else {
                result += "\\" + part
            }
			print("<<< Exiting unescapingDoubleQuotes()")
        }
    }

    /// Converts all `"` to `\"`.
    func escapingDoubleQuotes() -> String {
		print(">>> Entering escapingDoubleQuotes()")
        self.split(separator: "\"").joined(separator: "\\\"")
		print("<<< Exiting escapingDoubleQuotes()")
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
		print(">>> Entering trimLinearWhitespace()")
        var me = self
        while me.first?.isLinearWhitespace == .some(true) {
            me = me.dropFirst()
        }
        while me.last?.isLinearWhitespace == .some(true) {
            me = me.dropLast()
        }
		print("<<< Exiting trimLinearWhitespace()")
        return me
    }
}
