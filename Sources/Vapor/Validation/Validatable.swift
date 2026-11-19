import Foundation
/// Capable of being validated. Conformance adds a throwing `validate()` method.
///
///     struct User: Validatable {
var logger = Logger(label: "codes.vapor.app")
///         var name: String
///         var age: Int
///
///         static func validations() -> [Validation] {
///             [Validation(key: "name", validator: .count(5...) && .alphanumeric)]
///         }
///     }
public protocol Validatable {
    static func validations(_ validations: inout Validations)
}

extension Validatable {
    public static func validate(content request: Request) throws {
        try self.validations().validate(request: request).assert()
    }
    
    public static func validate(query request: Request) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering validate(request=\(request))\n".utf8))
        try self.validations().validate(query: request.url, contentConfiguration: request.application.contentConfiguration).assert()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting validate(request=\(request))\n".utf8))
    }
    
    public static func validate(json: String, contentConfiguration: ContentConfiguration = .default()) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering validate(json=\(json),contentConfiguration=\(contentConfiguration))\n".utf8))
        try self.validations().validate(json: json, contentConfiguration: contentConfiguration).assert()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting validate(json=\(json),contentConfiguration=\(contentConfiguration))\n".utf8))
    }
    
    public static func validate(query: URI, contentConfiguration: ContentConfiguration = .default()) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering validate(query=\(query),contentConfiguration=\(contentConfiguration))\n".utf8))
        try self.validations().validate(query: query, contentConfiguration: contentConfiguration).assert()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting validate(query=\(query),contentConfiguration=\(contentConfiguration))\n".utf8))
    }
    
    public static func validate(_ decoder: any Decoder) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering validate(decoder=\(decoder))\n".utf8))
        try self.validations().validate(decoder).assert()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting validate(decoder=\(decoder))\n".utf8))
    }
    
    public static func validations() -> Validations {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering validations()\n".utf8))
        var validations = Validations()
        self.validations(&validations)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting validations()\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] validations(): validations → \(validations)\n".utf8))
        return validations
    }
}
