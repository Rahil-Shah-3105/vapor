public import SwiftSyntaxMacros
public import SwiftSyntax
import HTTPTypes
import Foundation

public struct HTTPMethodMacro: PeerMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expansion(node=\(node),declaration=\(declaration),context=\(context))\n".utf8))
        // Get the first parameter for the macro
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
			FileHandle.standardError.write(Data("[ERROR] Throwing missingArguments from expansion(node=\(node),declaration=\(declaration),context=\(context))\n".utf8))
            throw MacroError.missingArguments("Method")
        }

        // Skip the `on:` argument if present to find the HTTP method argument
        let methodArg = arguments.first { arg in
            arg.label?.text != "on"
        }
        guard let methodArg else {
            throw MacroError.missingArguments("Method")
        }

        let methodExpr = methodArg.expression

        // Check if it's a member access (like .get, .post)
        let httpMethod: HTTPRequest.Method
        if let memberAccess = methodExpr.as(MemberAccessExprSyntax.self) {
            let methodName = memberAccess.declName.baseName.text
            guard let httpMethodFound = HTTPRequest.Method(methodName) else {
				FileHandle.standardError.write(Data("[ERROR] Throwing invalidHTTPMethod from expansion(node=\(node),declaration=\(declaration),context=\(context))\n".utf8))
                throw MacroError.invalidHTTPMethod(methodName)
            }
            httpMethod = httpMethodFound
        } else {
            throw MacroError.invalidHTTPMethod(methodExpr.description)
        }

		FileHandle.standardError.write(Data("[WARN] <<< Exiting expansion(node=\(node),declaration=\(declaration),context=\(context))\n".utf8))
        return try HTTPMethodMacroUtilities.expansion(of: node, providingPeersOf: declaration, in: context, for: httpMethod, customHTTPMethod: true)
    }
}

