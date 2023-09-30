import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum PublicInitMacroDiagnostic {
    case noExplicitType
    case notStruct
    case notPublic
}

extension PublicInitMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case .noExplicitType:
            "PublicInit Macro required stored properties provide explicit typed annotations."
        case .notStruct:
            "PublicInit Macro can only be applied to struct."
        case .notPublic:
            "PublicInit Macro can only be applied to public struct."
        }
    }

    public var severity: DiagnosticSeverity { .error }

    public var diagnosticID: MessageID {
        switch self {
        case .noExplicitType:
            MessageID(domain: "PublicInitMacroDiagnostic", id: "noExplicitType")
        case .notStruct:
            MessageID(domain: "PublicInitMacroDiagnostic", id: "notStruct")
        case .notPublic:
            MessageID(domain: "PublicInitMacroDiagnostic", id: "notPublic")
        }
    }
}

public extension PublicInitMacro {
    static func decodeExpansion(
        of syntax: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> StructDeclSyntax {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            if let actorDecl = declaration.as(ActorDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        PublicInitMacroDiagnostic.notStruct.diagnose(at: actorDecl.actorKeyword)
                    ]
                )
            }
            else if let classDecl = declaration.as(ClassDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        PublicInitMacroDiagnostic.notStruct.diagnose(at: classDecl.classKeyword)
                    ]
                )
            }
            else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
                throw DiagnosticsError(
                    diagnostics: [
                        PublicInitMacroDiagnostic.notStruct.diagnose(at: enumDecl.enumKeyword)
                    ]
                )
            }
            else {
                throw DiagnosticsError(
                    diagnostics: [
                        PublicInitMacroDiagnostic.notStruct.diagnose(at: declaration)
                    ]
                )
            }
        }

        guard structDecl.modifiers.map(\.name.text).contains("public") else {
            throw DiagnosticsError(
                diagnostics: [
                    PublicInitMacroDiagnostic.notPublic.diagnose(at: declaration)
                ]
            )
        }

        return structDecl
    }
}

struct InsertTypeAnnotationFixItMessage: FixItMessage {
    var message = "Insert type annotation."
    var fixItID = MessageID(
        domain: "PublicInitMacro", id: "type-annotation"
    )
}
