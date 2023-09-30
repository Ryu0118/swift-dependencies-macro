import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum DependenciesMacroDiagnostic {
    case notStruct
}

extension DependenciesMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case .notStruct:
            "PublicInit Macro can only be applied to struct."
        }
    }

    public var severity: DiagnosticSeverity { .error }

    public var diagnosticID: MessageID {
        switch self {
        case .notStruct:
            MessageID(domain: "DependenciesMacroDiagnostic", id: "notStruct")
        }
    }
}

public extension DependenciesMacro {
    static func decodeExpansion(
        of syntax: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> StructDeclSyntax {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            if let actorDecl = declaration.as(ActorDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependenciesMacroDiagnostic.notStruct.diagnose(at: actorDecl.actorKeyword)
                    ]
                )
            }
            else if let classDecl = declaration.as(ClassDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependenciesMacroDiagnostic.notStruct.diagnose(at: classDecl.classKeyword)
                    ]
                )
            }
            else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        DependenciesMacroDiagnostic.notStruct.diagnose(at: enumDecl.enumKeyword)
                    ]
                )
            }
            else {
                throw DiagnosticsError(
                    diagnostics: [
                        DependenciesMacroDiagnostic.notStruct.diagnose(at: declaration)
                    ]
                )
            }
        }

        return structDecl
    }
}
