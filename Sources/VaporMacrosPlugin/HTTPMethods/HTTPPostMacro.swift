public import SwiftSyntaxMacros
public import SwiftSyntax
import HTTPTypes

public struct HTTPPostMacro: PeerMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
		print(">>> Entering expansion(node=\(node),declaration=\(declaration),context=\(context))")
        try HTTPMethodMacroUtilities.expansion(of: node, providingPeersOf: declaration, in: context, for: .post)
		print("<<< Exiting expansion(node=\(node),declaration=\(declaration),context=\(context))")
    }
}
