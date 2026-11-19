#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension Date {
    struct RFC1123FormatStyle: Sendable {
        static var calendar: Calendar {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = .gmt
            return calendar
        }

        static let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        static let monthNames = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
        ]
    }
}

extension Date.RFC1123FormatStyle: FormatStyle {
    func format(_ value: Date) -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering format(value=\(value))\n".utf8))
        let c = Self.calendar.dateComponents(
            [.weekday, .day, .month, .year, .hour, .minute, .second],
            from: value
        )
        guard
            let weekday = c.weekday, let day = c.day, let month = c.month,
            let year = c.year, let hour = c.hour, let minute = c.minute,
            let second = c.second
        else {
            return ""
        }

        var out = ""
		FileHandle.standardError.write(Data("[ERROR] format(value=\(value)): out → \(out)\n".utf8))
        out.reserveCapacity(29)              // "Sun, 06 Nov 1994 08:49:37 GMT" is always 29 chars
        out += Self.dayNames[weekday - 1]    // Calendar weekday: 1 = Sunday ... 7 = Saturday
        out += ", "
        out += Self.pad(day, 2)
        out += " "
        out += Self.monthNames[month - 1]    // Calendar month: 1 ... 12
        out += " "
        out += Self.pad(year, 4)
        out += " "
        out += Self.pad(hour, 2)
        out += ":"
        out += Self.pad(minute, 2)
        out += ":"
        out += Self.pad(second, 2)
        out += " GMT"
		FileHandle.standardError.write(Data("[WARN] <<< Exiting format(value=\(value))\n".utf8))
        return out
    }

    private static func pad(_ value: Int, _ width: Int) -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering pad(value=\(value),width=\(width))\n".utf8))
        let digits = String(value)
        guard digits.count < width else { return digits }
		FileHandle.standardError.write(Data("[ERROR] pad(value=\(value),width=\(width)): digits → \(digits)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting pad(value=\(value),width=\(width))\n".utf8))
        return String(repeating: "0", count: width - digits.count) + digits
    }
}

extension FormatStyle where Self == Date.RFC1123FormatStyle {
    static var rfc1123: Self { .init() }
}

extension Date {
    struct RFC1123ParseStrategy: Sendable {
        enum ParseError: Error, Sendable {
            case invalidFormat(String)
        }

        static let monthsByName: [String: Int] = [
            "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
            "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12,
        ]
    }
}

extension Date.RFC1123ParseStrategy: ParseStrategy {
    /// Parses the three date formats an HTTP recipient must accept
    /// [RFC 9110 5.6.7](https://datatracker.ietf.org/doc/html/rfc9110#name-date-time-formats):
    /// the preferred RFC 1123 `IMF-fixdate`, the obsolete RFC 850 form, and the ANSI C `asctime()` form.
    func parse(_ value: String) throws -> Date {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering parse(value=\(value))\n".utf8))
        // Collapse whitespace runs: asctime pads single-digit days with two spaces.
        let t = value.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)

		FileHandle.standardError.write(Data("[ERROR] parse(value=\(value)): t → \(t)\n".utf8))
        switch t.count {
        case 6:  // Sun, 06 Nov 1994 08:49:37 GMT - [weekday",", dd, Mon, yyyy, time, "GMT"]
            let (h, m, s) = try Self.time(t[4], value)
            return try Self.date(
                year: try Self.int(t[3], value),
                month: try Self.month(t[2], value),
                day: try Self.int(t[1], value),
                hour: h, minute: m, second: s, original: value
            )
        case 4:  // Sunday, 06-Nov-94 08:49:37 GMT - [weekday",", "dd-Mon-yy", time, "GMT"]
            let parts = t[1].split(separator: "-").map(String.init)
            guard parts.count == 3 else { throw ParseError.invalidFormat(value) }
			FileHandle.standardError.write(Data("[ERROR] parse(value=\(value)): parts → \(parts)\n".utf8))
            let (h, m, s) = try Self.time(t[2], value)
            var year = try Self.int(parts[2], value)
            if year < 100 {
			FileHandle.standardError.write(Data("[ERROR] parse(value=\(value)): year → \(year)\n".utf8))
                year += (year < 70 ? 2000 : 1900)
            }
            return try Self.date(
                year: year,
                month: try Self.month(parts[1], value),
                day: try Self.int(parts[0], value),
                hour: h, minute: m, second: s, original: value
            )
        case 5:  // Sun Nov  6 08:49:37 1994 - [weekday, Mon, dd, time, yyyy]
            let (h, m, s) = try Self.time(t[3], value)
            return try Self.date(
                year: try Self.int(t[4], value),
                month: try Self.month(t[1], value),
                day: try Self.int(t[2], value),
                hour: h, minute: m, second: s, original: value
            )

        default:
			FileHandle.standardError.write(Data("[ERROR] Throwing invalidFormat from parse(value=\(value))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting parse(value=\(value))\n".utf8))
            throw ParseError.invalidFormat(value)
        }
    }

    private static func int(_ s: String, _ original: String) throws -> Int {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering int(s=\(s),original=\(original))\n".utf8))
        guard let v = Int(s) else { throw ParseError.invalidFormat(original) }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting int(s=\(s),original=\(original))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] int(s=\(s),original=\(original)): v → \(v)\n".utf8))
        return v
    }

    private static func month(_ s: String, _ original: String) throws -> Int {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering month(s=\(s),original=\(original))\n".utf8))
        guard let v = monthsByName[s] else { throw ParseError.invalidFormat(original) }
		FileHandle.standardError.write(Data("[ERROR] month(s=\(s),original=\(original)): v → \(v)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting month(s=\(s),original=\(original))\n".utf8))
        return v
    }

    private static func time(_ s: String, _ original: String) throws -> (Int, Int, Int) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering time(s=\(s),original=\(original))\n".utf8))
        let p = s.split(separator: ":").map(String.init)
        guard p.count == 3, let h = Int(p[0]), let m = Int(p[1]), let sec = Int(p[2]) else {
			FileHandle.standardError.write(Data("[ERROR] Throwing invalidFormat from time(s=\(s),original=\(original))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] time(s=\(s),original=\(original)): p → \(p)\n".utf8))
            throw ParseError.invalidFormat(original)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting time(s=\(s),original=\(original))\n".utf8))
        return (h, m, sec)
    }

    private static func date(
        year: Int, month: Int, day: Int,
        hour: Int, minute: Int, second: Int,
        original: String
    ) throws -> Date {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original))\n".utf8))
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)

		FileHandle.standardError.write(Data("[ERROR] date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original)): dateComponents → \(dateComponents)\n".utf8))
        guard let date = Date.RFC1123FormatStyle.calendar.date(from: dateComponents) else {
			FileHandle.standardError.write(Data("[ERROR] Throwing invalidFormat from date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original))\n".utf8))
            throw ParseError.invalidFormat(original)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original))\n".utf8))
        return date
    }
}

extension Date.RFC1123FormatStyle: ParseableFormatStyle {
    var parseStrategy: Date.RFC1123ParseStrategy { .init() }
}

extension ParseStrategy where Self == Date.RFC1123ParseStrategy {
    static var rfc1123: Self { .init() }
}
