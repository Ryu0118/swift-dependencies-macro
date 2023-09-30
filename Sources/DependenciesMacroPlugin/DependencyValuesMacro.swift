import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftCompilerPluginMessageHandling

public struct DependencyValuesMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let (_, typeName) = try decodeExpansion(
            of: node,
            attachedTo: declaration,
            in: context
        )

        let variableName = typeName.initialLowerCased()

        return [
            DeclSyntax(
                """
                var \(raw: variableName): \(raw: typeName) {
                    get { self[\(raw: typeName).self] }
                    set { self[\(raw: typeName).self] = newValue }
                }
                """
            )
        ]
    }
}

extension String {
    func initialLowerCased() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}
