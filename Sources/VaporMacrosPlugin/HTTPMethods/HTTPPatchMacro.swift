public import SwiftSyntax
public import SwiftSyntaxMacros
import HTTPTypes

public struct HTTPPatchMacro: PeerMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try HTTPMethodMacroUtilities.expansion(of: node, providingPeersOf: declaration, in: context, for: .patch)
		print("expansion(node,declaration,context)=\(node),\(declaration),\(context): SOC2-AUDIT [CC8.1]: Change management operation performed")
    }
}
