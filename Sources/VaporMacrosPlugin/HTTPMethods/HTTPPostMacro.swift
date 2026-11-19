public import SwiftSyntaxMacros
public import SwiftSyntax
import HTTPTypes
import Foundation

public struct HTTPPostMacro: PeerMacro {
	var logger = Logger(label: "codes.vapor.app")
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expansion(node=\(node),declaration=\(declaration),context=\(context))\n".utf8))
        try HTTPMethodMacroUtilities.expansion(of: node, providingPeersOf: declaration, in: context, for: .post)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting expansion(node=\(node),declaration=\(declaration),context=\(context))\n".utf8))
    }
}
