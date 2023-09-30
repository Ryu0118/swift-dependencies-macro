import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum DependencyValuesMacroDiagnostic {
    case notExtension
    case notDependencyValues
    case invalidArgument
}

extension DependencyValuesMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case .notExtension:
            "DependencyValue Macro can only be applied to extension."

        case .invalidArgument:
            "Invalid argument."

        case .notDependencyValues:
            "DependencyValue Macro can only be applied to extension of DependencyValues"
        }
    }

    public var severity: DiagnosticSeverity { .error }

    public var diagnosticID: MessageID {
        switch self {
        case .notExtension:
            MessageID(domain: "DependencyValuesMacroDiagnostic", id: "notExtension")

        case .invalidArgument:
            MessageID(domain: "DependencyValuesMacroDiagnostic", id: "invalidArgument")

        case .notDependencyValues:
            MessageID(domain: "DependencyValuesMacroDiagnostic", id: "invalidArgument")
        }
    }
}

public extension DependencyValuesMacro {
    static func decodeExpansion(
        of syntax: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> (decl: ExtensionDeclSyntax, type: String) {
        guard let extensionDecl = declaration.as(ExtensionDeclSyntax.self) else {
            if let actorDecl = declaration.as(ActorDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependencyValuesMacroDiagnostic.notExtension.diagnose(at: actorDecl.actorKeyword)
                    ]
                )
            }
            else if let classDecl = declaration.as(ClassDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependencyValuesMacroDiagnostic.notExtension.diagnose(at: classDecl.classKeyword)
                    ]
                )
            }
            else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependencyValuesMacroDiagnostic.notExtension.diagnose(at: enumDecl.enumKeyword)
                    ]
                )
            }
            else if let structDecl = declaration.as(StructDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependencyValuesMacroDiagnostic.notExtension.diagnose(at: structDecl.structKeyword)
                    ]
                )
            }
            else {
                throw DiagnosticsError(
                    diagnostics: [
                        DependencyValuesMacroDiagnostic.notExtension.diagnose(at: declaration)
                    ]
                )
            }
        }

        guard extensionDecl.extendedType.as(IdentifierTypeSyntax.self)?.name.text == "DependencyValues" else {
            throw DiagnosticsError(
                diagnostics: [
                    DependencyValuesMacroDiagnostic.notDependencyValues.diagnose(at: extensionDecl.extendedType)
                ]
            )
        }

        guard case .argumentList(let arguments) = syntax.arguments,
              let type = arguments.first?.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text,
              arguments.count == 1
        else {
            throw DiagnosticsError(
                diagnostics: [
                    DependencyValuesMacroDiagnostic.invalidArgument.diagnose(at: declaration)
                ]
            )
        }

        return (extensionDecl, type)
    }
}
