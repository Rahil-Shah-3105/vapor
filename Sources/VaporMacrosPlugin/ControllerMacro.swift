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
		print(">>> Entering expansion(node=\(node),declaration=\(declaration),member=\(member),context=\(context))")
        []
		print("<<< Exiting expansion(node=\(node),declaration=\(declaration),member=\(member),context=\(context))")
    }

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
		print(">>> Entering expansion(node=\(node),declaration=\(declaration),protocols=\(protocols),context=\(context))")
        []
    }

    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
		print(">>> Entering expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context))")
        // Find all functions with route macros
		print("<<< Exiting expansion(node=\(node),declaration=\(declaration),protocols=\(protocols),context=\(context))")
        let functions = try declaration.memberBlock.members.compactMap { member -> (FunctionDeclSyntax, String, [String], [String])? in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
				print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): functions → \(functions)")
				print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): funcDecl → \(funcDecl)")
                return nil
            }

            // Look for HTTP method attributes
            for attribute in funcDecl.attributes {
                guard case let .attribute(attr) = attribute,
                      let identifier = attr.attributeName.as(IdentifierTypeSyntax.self),
                      ["GET", "POST", "PUT", "DELETE", "PATCH", "HTTP"].contains(identifier.name.text) else {
					print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): identifier → \(identifier)")
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
					print("Throwing missingArguments from expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context))")
					print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): httpMethod → \(httpMethod)")
					print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): customHTTPMethod → \(customHTTPMethod)")
                    httpMethod = identifier.name.text
                    customHTTPMethod = false
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

						print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): exprStr → \(exprStr)")
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
							print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): cleaned → \(cleaned)")
                    }
                }

                // Check for @AuthMiddleware
                let middlewareExprs: [String] = {
                    guard let authInfo = HTTPMethodMacroUtilities.parseAuthMiddleware(from: funcDecl) else {
						print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): authInfo → \(authInfo)")
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
		print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): registrationBody → \(registrationBody)")

        for (functionDeclaration, method, pathComponents, middlewares) in functions {
            let path = pathComponents.joined(separator: "\", \"")
            let methodLower = method.lowercased()

			print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): path → \(path)")
			print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): methodLower → \(methodLower)")
            // Call the function generated by the HTTP Method Macros
            let functionName = "_route_\(functionDeclaration.name.text)"
			print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): functionName → \(functionName)")
            let pathRegistration = if path == "" {
                ""
            } else {
                "(\"\(path)\")"
				print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): pathRegistration → \(pathRegistration)")
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
				print("expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context)): middlewareList → \(middlewareList)")
                routes.grouped(\(middlewareList)).\(methodLower)\(pathRegistration) { req async throws -> Response in
                    try await self.\(functionName)(req: req)
                }

                """
            }
        }

		print("<<< Exiting expansion(node=\(node),declaration=\(declaration),type=\(type),protocols=\(protocols),context=\(context))")
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
