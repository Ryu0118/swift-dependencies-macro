import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftCompilerPluginMessageHandling

public struct PublicInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let structDecl = try decodeExpansion(of: node, attachedTo: declaration, in: context)
        let storedPropertyBindings = structDecl.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
            .flatMap { $0 }
            .filter { $0.accessorBlock == nil }
            .compactMap { (binding: PatternBindingSyntax) -> PatternBindingSyntax? in
                guard let typeAnnotation = binding.typeAnnotation else {
                    var newProperty = binding
                    newProperty.typeAnnotation = TypeAnnotationSyntax(
                        type: IdentifierTypeSyntax(name: " <#Type#> ")
                    )
                    context.diagnose(
                        .init(
                            node: binding._syntaxNode,
                            message: PublicInitMacroDiagnostic.noExplicitType,
                            fixIts: [
                                FixIt(
                                    message: InsertTypeAnnotationFixItMessage(),
                                    changes: [
                                        .replace(oldNode: Syntax(binding), newNode: Syntax(newProperty))
                                    ]
                                )
                            ]
                        )
                    )
                    return nil
                }

                if let functionType = typeAnnotation.type.as(FunctionTypeSyntax.self) {
                    return binding.with(
                        \.typeAnnotation,
                         typeAnnotation.with(
                            \.type,
                             TypeSyntax(
                                AttributedTypeSyntax(
                                    attributes: AttributeListSyntax {
                                        AttributeSyntax.escaping
                                    },
                                    baseType: functionType
                                )
                             )
                         )
                    )
                } else if let attributedType = typeAnnotation.type.as(AttributedTypeSyntax.self) {
                    return binding.with(
                        \.typeAnnotation,
                         typeAnnotation.with(
                            \.type,
                             TypeSyntax(
                                attributedType.with(
                                    \.attributes, AttributeListSyntax {
                                        attributedType.attributes
                                        AttributeSyntax.escaping
                                    }
                                )
                             )
                         )
                    )
                } else {
                    return binding
                }
            }

        let arguments = storedPropertyBindings.map(\.description).joined(separator: ", \n")
        let assigns = storedPropertyBindings
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
            .map { "self.\($0) = \($0)" }
            .joined(separator: "\n")

        return [
            DeclSyntax(
                """
                public init(
                    \(raw: arguments)
                ) {
                    \(raw: assigns)
                }
                """
            )
        ]
    }
}

extension AttributeSyntax {
    static let escaping = AttributeSyntax(
        atSign: .atSignToken(),
        attributeName: IdentifierTypeSyntax(
            name: .identifier("escaping",
            trailingTrivia: .space)
        )
    )
}
