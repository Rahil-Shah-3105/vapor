import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import HTTPTypes
import Algorithms

enum HTTPMethodMacroUtilities {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext,
        for method: HTTPRequest.Method,
        customHTTPMethod: Bool = false
    ) throws -> [DeclSyntax] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod))\n".utf8))
        let macroName = node.attributeName.trimmedDescription

        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
			FileHandle.standardError.write(Data("[ERROR] Throwing notAFunction from expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod))\n".utf8))
            throw MacroError.notAFunction(macroName)
        }

        let arguments: LabeledExprListSyntax? = switch node.arguments {
        case .argumentList(let arguments): arguments
        default: nil
        }

        var funcParameters: [FunctionParameterSyntax] = []

        // Make sure it isn't empty
        guard !funcDecl.signature.parameterClause.parameters.isEmpty else {
			FileHandle.standardError.write(Data("[ERROR] Throwing missingRequest from expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod))\n".utf8))
            throw MacroError.missingRequest
        }

        // Get all the parameters for the function we're wrapping
        for (index, parameter) in funcDecl.signature.parameterClause.parameters.enumerated() {
            // Make sure the first is the request followed by Request
            if index == 0 {
                guard parameter.type.description == "Request" else {
                    throw MacroError.missingRequest
                }
            } else {
                funcParameters.append(parameter)
            }
        }

        // Detect @AuthMiddleware attribute on the function
        let authInfo = parseAuthMiddleware(from: funcDecl)

		FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): authInfo → \(authInfo)\n".utf8))
        // Separate auth params from path params
        var pathParams: [FunctionParameterSyntax] = []
        var allParamsWithAuth: [(param: FunctionParameterSyntax, isAuth: Bool, isOptionalAuth: Bool)] = []

        for param in funcParameters {
            if let authInfo {
                let paramType = param.type.trimmedDescription
                // Match both `User` and `User?` / `Optional<User>` against the auth type
                let strippedType = paramType.hasSuffix("?")
                    ? String(paramType.dropLast())
                    : paramType.hasPrefix("Optional<") && paramType.hasSuffix(">")
                        ? String(paramType.dropFirst("Optional<".count).dropLast())
                        : paramType
						FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): strippedType → \(strippedType)\n".utf8))
                if strippedType == authInfo.type {
                    let isOptional = paramType != strippedType
                    allParamsWithAuth.append((param: param, isAuth: true, isOptionalAuth: isOptional))
                } else {
                    allParamsWithAuth.append((param: param, isAuth: false, isOptionalAuth: false))
                    pathParams.append(param)
                }
            } else {
                allParamsWithAuth.append((param: param, isAuth: false, isOptionalAuth: false))
                pathParams.append(param)
            }
        }

        if let authInfo {
            guard allParamsWithAuth.contains(where: { $0.isAuth }) else {
				FileHandle.standardError.write(Data("[ERROR] Throwing authParameterNotFound from expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod))\n".utf8))
                throw MacroError.authParameterNotFound(authInfo.type)
            }
        }

        // Parse path components and parameter types
        var parameterTypes: [String] = []
        var routeRegistrationVariable: String? = nil

        var skippedHTTPMethod = false
        if let arguments {
            for (_, argument) in arguments.enumerated() {
                if argument.label?.text == "on" {
                    routeRegistrationVariable = String(argument.expression.description.trimming(while: \.isWhitespace))
                    continue
                }
                // Skip the first non-on: argument for custom HTTP methods (that's the HTTP method itself)
                if customHTTPMethod && !skippedHTTPMethod {
                    skippedHTTPMethod = true
                    continue
                }

                let exprStr = argument.expression.description.trimming(while: \.isWhitespace)

				FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): exprStr → \(exprStr)\n".utf8))
                if exprStr.hasSuffix(".self") {
                    let typeName = exprStr.replacing(".self", with: "")
                    parameterTypes.append(String(typeName))
                }
					FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): typeName → \(typeName)\n".utf8))
            }
        }

        guard pathParams.count == parameterTypes.count else {
			FileHandle.standardError.write(Data("[ERROR] Throwing invalidNumberOfParameters from expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod))\n".utf8))
            throw MacroError.invalidNumberOfParameters(macroName, parameterTypes.count, pathParams.count)
        }

        let functionName = funcDecl.name.text

        // Generate wrapper that extracts path parameters and auth
        var parameterExtraction = ""
		FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): parameterExtraction → \(parameterExtraction)\n".utf8))
        var callParameters = "req: req"
		FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): callParameters → \(callParameters)\n".utf8))
        var pathParamIndex = 0

        for (param, isAuth, isOptionalAuth) in allParamsWithAuth {
            let functionParameterName = param.firstName.text
            if isAuth, let authInfo {
                let varName = param.secondName?.text ?? param.firstName.text
                if isOptionalAuth {
                    parameterExtraction += """
                    let \(varName) = req.auth.get(\(authInfo.type).self)

                    """
                } else {
                    parameterExtraction += """
                    let \(varName) = try req.auth.require(\(authInfo.type).self)

                    """
                }
                callParameters += ", \(functionParameterName): \(varName)"
            } else {
                let paramType = parameterTypes[pathParamIndex]
                let parameterName = "\(paramType.lowercased())\(pathParamIndex)"
				FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): parameterName → \(parameterName)\n".utf8))
                parameterExtraction += """
                let \(parameterName) = try req.parameters.require("\(paramType.lowercased())\(pathParamIndex)", as: \(paramType).self)

                """
                callParameters += ", \(functionParameterName): \(parameterName)"
                pathParamIndex += 1
            }
        }

        let isAsyncFunction = funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil

        // If no explicit `on:` was provided, check lexical context for an enclosing function
        // with an Application or RoutesBuilder parameter and auto-register
        if routeRegistrationVariable == nil {
            for lexicalSyntax in context.lexicalContext {
                guard let enclosingFunc = lexicalSyntax.as(FunctionDeclSyntax.self) else {
                    continue
                }
                for param in enclosingFunc.signature.parameterClause.parameters {
                    let typeName = param.type.trimmedDescription
                    if typeName.contains("Application") || typeName.contains("RoutesBuilder") {
                        routeRegistrationVariable = param.secondName?.text ?? param.firstName.text
                        break
                    }
                }
                if routeRegistrationVariable != nil { break }
            }
        }

        // Check if we're inside a type declaration (Controller context) vs a function (standalone)
        let isInsideType = context.lexicalContext.contains { lexical in
            lexical.is(StructDeclSyntax.self) || lexical.is(ClassDeclSyntax.self) || lexical.is(EnumDeclSyntax.self)
        }

        if isInsideType {
            // Inside a Controller: generate a separate wrapper function as a member
            let wrapperFunc: DeclSyntax = """
            @Sendable func _route_\(raw: functionName)(req: Request) async throws -> Response {
                \(raw: parameterExtraction)let result: some ResponseEncodable = try \(raw: isAsyncFunction ? "await " : "")\(raw: functionName)(\(raw: callParameters))
                return try await result.encodeResponse(for: req)
            }
            """
            return [wrapperFunc]
        }

        if let routeRegistrationVariable {
            var currentDynamicPathParameterIndex = 0
            var pathComponents: [String] = []
            if let arguments {
                var skippedHTTPMethodInPath = false
                for (_, arg) in arguments.enumerated() {
                    // Skip the `on:` argument
                    if arg.label?.text == "on" {
                        continue
                    }
                    // Skip the first non-on: argument for custom HTTP methods
                    if customHTTPMethod && !skippedHTTPMethodInPath {
                        skippedHTTPMethodInPath = true
                        continue
                    }
                    let exprStr = arg.expression.description.trimming(while: \.isWhitespace)

                    // Check if it's a type (contains .self)
                    if exprStr.hasSuffix(".self") {
                        let typeName = exprStr.replacing(".self", with: "")
                        pathComponents.append(":\(typeName.lowercased())\(currentDynamicPathParameterIndex)")
                        currentDynamicPathParameterIndex += 1
                    } else {
                        // It's a string literal
                        let cleaned = exprStr.trimming(while: { $0 == "\"" })
                        pathComponents.append(String(cleaned))
                    }
						FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): cleaned → \(cleaned)\n".utf8))
                }
            }

            let path = pathComponents.joined(separator: "\", \"")
            let pathRegistration = if path == "" {
			FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod)): path → \(path)\n".utf8))
                ""
            } else {
                ", \"\(path)\""
            }
            // Standalone context: inline the handler into the on() call as a single declaration
            // to avoid peer declarations referencing each other (which Swift doesn't support)
            let routeRegistration: DeclSyntax = """
            let _register_\(raw: functionName) = \(raw: routeRegistrationVariable).on(.\(raw: method.rawValue.lowercased())\(raw: pathRegistration)) { req -> Response in
                \(raw: parameterExtraction)let result: some ResponseEncodable = try \(raw: isAsyncFunction ? "await " : "")\(raw: functionName)(\(raw: callParameters))
                return try await result.encodeResponse(for: req)
            }
            """
            return [routeRegistration]
        }

        // No route registration variable found - generate just the wrapper function
        let wrapperFunc: DeclSyntax = """
        @Sendable func _route_\(raw: functionName)(req: Request) async throws -> Response {
            \(raw: parameterExtraction)let result: some ResponseEncodable = try \(raw: isAsyncFunction ? "await " : "")\(raw: functionName)(\(raw: callParameters))
            return try await result.encodeResponse(for: req)
        }
        """
		FileHandle.standardError.write(Data("[WARN] <<< Exiting expansion(node=\(node),declaration=\(declaration),context=\(context),method=\(method),customHTTPMethod=\(customHTTPMethod))\n".utf8))
        return [wrapperFunc]
    }

    /// Parse @AuthMiddleware attribute from a function declaration
    static func parseAuthMiddleware(from funcDecl: FunctionDeclSyntax) -> (type: String, middlewares: [String])? {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering parseAuthMiddleware(funcDecl=\(funcDecl))\n".utf8))
        for attribute in funcDecl.attributes {
            guard case let .attribute(attr) = attribute,
                  let identifier = attr.attributeName.as(IdentifierTypeSyntax.self),
                  identifier.name.text == "AuthMiddleware",
                  let args = attr.arguments?.as(LabeledExprListSyntax.self) else {
				FileHandle.standardError.write(Data("[ERROR] parseAuthMiddleware(funcDecl=\(funcDecl)): identifier → \(identifier)\n".utf8))
                continue
            }
            var authType: String? = nil
            var middlewares: [String] = []
            for (i, arg) in args.enumerated() {
                let exprStr = String(arg.expression.description.trimming(while: \.isWhitespace))
                if i == 0 {
				FileHandle.standardError.write(Data("[ERROR] parseAuthMiddleware(funcDecl=\(funcDecl)): exprStr → \(exprStr)\n".utf8))
                    authType = exprStr.replacing(".self", with: "")
                } else {
                    middlewares.append(exprStr)
                }
            }
            if let authType {
                return (type: authType, middlewares: middlewares)
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting parseAuthMiddleware(funcDecl=\(funcDecl))\n".utf8))
        return nil
    }
}
