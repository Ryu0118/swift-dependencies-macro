import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DependenciesMacro {}

extension DependenciesMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let structDecl = try decodeExpansion(of: node, attachedTo: declaration, in: context)
        let storedPropertyBindings = structDecl.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
            .flatMap { $0 }
            .filter { $0.accessorBlock == nil }
        let modifier = declaration.modifiers
            .compactMap { $0.as(DeclModifierSyntax.self)?.name.text }
            .first ?? "internal"
        let arguments = storedPropertyBindings
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
            .map { "\($0): unimplemented(\"\\(Self.self).\($0)\")" }
            .joined(separator: ", \n")

        let testDependencyKeyExtension = try ExtensionDeclSyntax(
            """
            extension \(type.trimmed): TestDependencyKey {
                \(raw: modifier) static let testValue = \(type.trimmed)(
                    \(raw: arguments)
                )
            }
            """
        )

        return [
            testDependencyKeyExtension,
        ]
    }
}
