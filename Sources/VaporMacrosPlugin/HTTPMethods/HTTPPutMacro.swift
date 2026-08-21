public import SwiftSyntax
public import SwiftSyntaxMacros
import HTTPTypes

public struct HTTPPutMacro: PeerMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
		print(">>> Entering expansion(node=\(node),declaration=\(declaration),context=\(context))")
        try HTTPMethodMacroUtilities.expansion(of: node, providingPeersOf: declaration, in: context, for: .put)
		print("<<< Exiting expansion(node=\(node),declaration=\(declaration),context=\(context))")
    }
}
