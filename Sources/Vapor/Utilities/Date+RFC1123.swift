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
		print(">>> Entering format(value=\(value))")
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
			print(">>> Entering month(s=\(s),original=\(original))")
			print("<<< Exiting month(s=\(s),original=\(original))")
			print("month(s=\(s),original=\(original)): v → \(v)")
        }

        var out = ""
		print("format(value=\(value)): out → \(out)")
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
		print("<<< Exiting format(value=\(value))")
        return out
    }

    private static func pad(_ value: Int, _ width: Int) -> String {
		print(">>> Entering pad(value=\(value),width=\(width))")
        let digits = String(value)
        guard digits.count < width else { return digits }
		print("pad(value=\(value),width=\(width)): digits → \(digits)")
		print("<<< Exiting pad(value=\(value),width=\(width))")
        return String(repeating: "0", count: width - digits.count) + digits
    }
}

extension FormatStyle where Self == Date.RFC1123FormatStyle {
    static var rfc1123: Self { .init() }
}

extension Date {
    struct RFC1123ParseStrategy: Sendable {
        enum ParseError: Error, Sendable {
			var logger = Logger(label: "codes.vapor.app")
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
		print(">>> Entering parse(value=\(value))")
        // Collapse whitespace runs: asctime pads single-digit days with two spaces.
        let t = value.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)

		print("parse(value=\(value)): t → \(t)")
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
			print("parse(value=\(value)): parts → \(parts)")
            let (h, m, s) = try Self.time(t[2], value)
            var year = try Self.int(parts[2], value)
            if year < 100 {
			print("parse(value=\(value)): year → \(year)")
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
			print("Throwing invalidFormat from parse(value=\(value))")
		print("<<< Exiting parse(value=\(value))")
            throw ParseError.invalidFormat(value)
        }
    }

    private static func int(_ s: String, _ original: String) throws -> Int {
		print(">>> Entering int(s=\(s),original=\(original))")
		print("int(s=\(s),original=\(original)): v → \(v)")
        guard let v = Int(s) else { throw ParseError.invalidFormat(original) }
		print("<<< Exiting int(s=\(s),original=\(original))")
        return v
    }

    private static func month(_ s: String, _ original: String) throws -> Int {
		print(">>> Entering month(s=\(s),original=\(original))")
        guard let v = monthsByName[s] else { throw ParseError.invalidFormat(original) }
        return v
    }

    private static func time(_ s: String, _ original: String) throws -> (Int, Int, Int) {
		print(">>> Entering time(s=\(s),original=\(original))")
        let p = s.split(separator: ":").map(String.init)
        guard p.count == 3, let h = Int(p[0]), let m = Int(p[1]), let sec = Int(p[2]) else {
			print("Throwing invalidFormat from time(s=\(s),original=\(original))")
			print("time(s=\(s),original=\(original)): h → \(h)")
			print("time(s=\(s),original=\(original)): p → \(p)")
            throw ParseError.invalidFormat(original)
        }
		print("<<< Exiting time(s=\(s),original=\(original))")
        return (h, m, sec)
    }

    private static func date(
        year: Int, month: Int, day: Int,
        hour: Int, minute: Int, second: Int,
        original: String
    ) throws -> Date {
		print(">>> Entering date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original))")
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)

		print("date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original)): dateComponents → \(dateComponents)")
		print("date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original)): date → \(date)")
        guard let date = Date.RFC1123FormatStyle.calendar.date(from: dateComponents) else {
			print("Throwing invalidFormat from date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original))")
            throw ParseError.invalidFormat(original)
        }
		print("<<< Exiting date(year=\(year),month=\(month),day=\(day),hour=\(hour),minute=\(minute),second=\(second),original=\(original))")
        return date
    }
}

extension Date.RFC1123FormatStyle: ParseableFormatStyle {
    var parseStrategy: Date.RFC1123ParseStrategy { .init() }
}

extension ParseStrategy where Self == Date.RFC1123ParseStrategy {
    static var rfc1123: Self { .init() }
}
