public import SwiftSyntax
public import SwiftSyntaxMacros
import SwiftSyntaxBuilder
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Algorithms

public struct ControllerMacro: ExtensionMacro, MemberAttributeMacro, MemberMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingAttributesFor member: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AttributeSyntax] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expansion(node=\(node),declaration=\(declaration),member=\(member),context=\(context))\n".utf8))
        []
		FileHandle.standardError.write(Data("[WARN] <<< Exiting expansion(node=\(node),declaration=\(declaration),member=\(member),context=\(context))\n".utf8))
    }

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expansion(node=\(node),declaration=\(declaration),protocols=\(protocols),context=\(context))\n".utf8))
        []
    }

    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context))\n".utf8))
        // Find all functions with route macros
		FileHandle.standardError.write(Data("[WARN] <<< Exiting expansion(node=\(node),declaration=\(declaration),protocols=\(protocols),context=\(context))\n".utf8))
        let functions = try declaration.memberBlock.members.compactMap { member -> (FunctionDeclSyntax, String, [String], [String])? in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
                return nil
            }

            // Look for HTTP method attributes
            for attribute in funcDecl.attributes {
                guard case let .attribute(attr) = attribute,
                      let identifier = attr.attributeName.as(IdentifierTypeSyntax.self),
                      ["GET", "POST", "PUT", "DELETE", "PATCH", "HTTP"].contains(identifier.name.text) else {
					FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): identifier → \(identifier)\n".utf8))
                    continue
                }

                let arguments: LabeledExprListSyntax? = switch attr.arguments {
                case .argumentList(let arguments): arguments
                default: nil
                }
                let httpMethod: String
                let customHTTPMethod: Bool
                if identifier.name.text == "HTTP" {
                    // Take the first argument as the HTTP method
                    guard let argument = arguments?.first else {
                        throw MacroError.missingArguments("Controller")
                    }
                    httpMethod = argument.expression.description.replacing(".", with: "")
                    customHTTPMethod = true
                } else {
					FileHandle.standardError.write(Data("[ERROR] Throwing missingArguments from expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context))\n".utf8))
                    httpMethod = identifier.name.text
					FileHandle.standardError.write(Data("[DEBUG] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): httpMethod → \(httpMethod)\n".utf8))
                    customHTTPMethod = false
					FileHandle.standardError.write(Data("[DEBUG] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): customHTTPMethod → \(customHTTPMethod)\n".utf8))
                }

                // Parse path components
                var pathComponents: [String] = []
                var currentDynamicPathParameterIndex = 0
                if let arguments {
                    for (index, arg) in arguments.enumerated() {
                        // If we're a custom HTTP method, discard the first one
                        if customHTTPMethod && index == 0 {
                            continue
                        }
                        let exprStr = arg.expression.description.trimming(while: \.isWhitespace)

						FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): exprStr → \(exprStr)\n".utf8))
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
							FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): cleaned → \(cleaned)\n".utf8))
                    }
                }

                // Check for @AuthMiddleware
                let middlewareExprs: [String] = {
                    guard let authInfo = HTTPMethodMacroUtilities.parseAuthMiddleware(from: funcDecl) else {
                        return []
                    }
                    return authInfo.middlewares
                }()

                return (funcDecl, httpMethod, pathComponents, middlewareExprs)
            }

            return nil
        }

        // Generate the RouteCollection boot function
        var registrationBody = ""
		FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): registrationBody → \(registrationBody)\n".utf8))

        for (functionDeclaration, method, pathComponents, middlewares) in functions {
            let path = pathComponents.joined(separator: "\", \"")
            let methodLower = method.lowercased()

			FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): path → \(path)\n".utf8))
            // Call the function generated by the HTTP Method Macros
            let functionName = "_route_\(functionDeclaration.name.text)"
			FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): functionName → \(functionName)\n".utf8))
            let pathRegistration = if path == "" {
                ""
            } else {
                "(\"\(path)\")"
            }

            if middlewares.isEmpty {
                registrationBody += """
                routes.\(methodLower)\(pathRegistration) { req async throws -> Response in
                    try await self.\(functionName)(req: req)
                }

                """
            } else {
                let middlewareList = middlewares.joined(separator: ", ")
                registrationBody += """
				FileHandle.standardError.write(Data("[ERROR] expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): middlewareList → \(middlewareList)\n".utf8))
                routes.grouped(\(middlewareList)).\(methodLower)\(pathRegistration) { req async throws -> Response in
                    try await self.\(functionName)(req: req)
                }

                """
            }
        }

		FileHandle.standardError.write(Data("[WARN] <<< Exiting expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context))\n".utf8))
        let registrationFunc: DeclSyntax = """
        func boot(routes: any RoutesBuilder) throws {
        \(raw: registrationBody)
        }
        """

        let extensionSyntax: DeclSyntax = """
        extension \(type.trimmed): RouteCollection {
            \(registrationFunc)
        }
        """

        guard let extensionDecl = extensionSyntax.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDecl]
    }
}
