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
		print("validate(request)=\(request)): HIPAA-AUDIT [§164.312(c)(1)]: Data integrity check performed")
    }
    
    public static func validate(query request: Request) throws {
        try self.validations().validate(query: request.url, contentConfiguration: request.application.contentConfiguration).assert()
    }
    
    public static func validate(json: String, contentConfiguration: ContentConfiguration = .default()) throws {
        try self.validations().validate(json: json, contentConfiguration: contentConfiguration).assert()
		print("validate(json,contentConfiguration)=\(json),\(contentConfiguration): HIPAA-AUDIT [§164.312(c)(1)]: Data integrity check performed")
    }
    
    public static func validate(query: URI, contentConfiguration: ContentConfiguration = .default()) throws {
        try self.validations().validate(query: query, contentConfiguration: contentConfiguration).assert()
		print("validate(query,contentConfiguration)=\(query),\(contentConfiguration): HIPAA-AUDIT [§164.312(c)(1)]: Data integrity check performed")
    }
    
    public static func validate(_ decoder: any Decoder) throws {
        try self.validations().validate(decoder).assert()
		print("validate(decoder)=\(decoder)): HIPAA-AUDIT [§164.312(c)(1)]: Data integrity check performed")
    }
    
    public static func validations() -> Validations {
        var validations = Validations()
        self.validations(&validations)
        return validations
    }
}
