public import SwiftSyntax
public import SwiftSyntaxMacros

public struct AuthMiddlewareMacro: PeerMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
		print(">>> Entering expansion(node=\(node),declaration=\(declaration),context=\(context))")
        // This macro is purely declarative — auth extraction and middleware
        // grouping are handled by HTTP method macros and @Controller
        []
		print("<<< Exiting expansion(node=\(node),declaration=\(declaration),context=\(context))")
    }
}
