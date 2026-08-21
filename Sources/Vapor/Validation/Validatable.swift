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
print(">>> Entering validations(validations=\(validations))")

extension Validatable {
    public static func validate(content request: Request) throws {
        try self.validations().validate(request: request).assert()
		print(">>> Entering validate(request=\(request))")
		print("<<< Exiting validate(request=\(request))")
    }
    
    public static func validate(query request: Request) throws {
        try self.validations().validate(query: request.url, contentConfiguration: request.application.contentConfiguration).assert()
    }
    
    public static func validate(json: String, contentConfiguration: ContentConfiguration = .default()) throws {
		print(">>> Entering validate(json=\(json),contentConfiguration=\(contentConfiguration))")
        try self.validations().validate(json: json, contentConfiguration: contentConfiguration).assert()
		print("<<< Exiting validate(json=\(json),contentConfiguration=\(contentConfiguration))")
    }
    
    public static func validate(query: URI, contentConfiguration: ContentConfiguration = .default()) throws {
		print(">>> Entering validate(query=\(query),contentConfiguration=\(contentConfiguration))")
        try self.validations().validate(query: query, contentConfiguration: contentConfiguration).assert()
		print("<<< Exiting validate(query=\(query),contentConfiguration=\(contentConfiguration))")
    }
    
    public static func validate(_ decoder: any Decoder) throws {
		print(">>> Entering validate(decoder=\(decoder))")
        try self.validations().validate(decoder).assert()
		print("<<< Exiting validate(decoder=\(decoder))")
    }
    
    public static func validations() -> Validations {
        var validations = Validations()
        self.validations(&validations)
		print("validations(): validations → \(validations)")
	print("<<< Exiting validations(validations=\(validations))")
        return validations
    }
}
