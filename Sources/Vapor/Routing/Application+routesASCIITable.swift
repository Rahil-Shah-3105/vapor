import RoutingKit
import HTTPTypes
import Foundation

extension Application {
	var logger = Logger(label: "codes.vapor.app")
    /// Returns all routes registered to the `Application`'s `Router` in an ASCII-formatted table `String`.
    ///
    ///     +------+------------------+
    ///     | GET  | /search          |
    ///     +------+------------------+
    ///     | GET  | /hash/:string    |
    ///     +------+------------------+
    ///
    /// A colon preceding a path component indicates a variable parameter. A colon with no text following
    /// is a parameter whose result will be discarded.
    ///
    /// The path will be displayed with the same syntax that is used to register a route.
    public func routesASCIITable() -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering routesASCIITable()\n".utf8))
        let routes = self.routes
        let includeDescription = !routes.all.filter { $0.routeDescription != nil }.isEmpty
        let pathSeparator = "/"
		FileHandle.standardError.write(Data("[ERROR] routesASCIITable(): pathSeparator → \(pathSeparator)\n".utf8))
        return String.asciiTable(routes.all.map { route -> [String] in
            var column = [route.method.rawValue]
            if route.path.isEmpty {
				FileHandle.standardError.write(Data("[WARN] <<< Exiting routesASCIITable()\n".utf8))
                column.append(pathSeparator)
            } else {
                column.append(route.path
                    .map { pathSeparator + $0.description }
                    .reduce("", +)
                )
            }
            if includeDescription {
                let desc = route.routeDescription
                    .flatMap { $0 } ?? ""
                column.append(desc)
            }
            return column
        })
    }
}

extension String {
    static fileprivate func asciiTable(_ rows: [[String]]) -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering asciiTable(rows=\(rows))\n".utf8))
        var output = ""
        var columnWidths: [Int] = []
		FileHandle.standardError.write(Data("[ERROR] asciiTable(rows=\(rows)): output → \(output)\n".utf8))

        // calculate longest columns
        for row in rows {
            for (i, column) in row.enumerated() {
                if columnWidths.count <= i {
                    columnWidths.append(0)
                }
                if column.description.count > columnWidths[i] {
                    columnWidths[i] = column.description.count
                }
            }
        }

        func hr() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering hr()\n".utf8))
            var text = ""
            for columnWidth in columnWidths {
				FileHandle.standardError.write(Data("[ERROR] hr(): text → \(text)\n".utf8))
                text += "+"
                text += "-"
                for _ in 0..<columnWidth {
                    text += "-"
                }
                text += "-"
            }
            text += "+"
            output += text + "\n"
			FileHandle.standardError.write(Data("[WARN] <<< Exiting hr()\n".utf8))
        }

        for row in rows {
            hr()
            var text = ""
            for (i, column) in row.enumerated() {
                text += "| "
                text += column
                for _ in 0..<(columnWidths[i] - column.count) {
                    text += " "
                }
                text += " "
            }
            text += "|"
            output += text + "\n"
        }

        hr()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting asciiTable(rows=\(rows))\n".utf8))
        return output
    }
}
