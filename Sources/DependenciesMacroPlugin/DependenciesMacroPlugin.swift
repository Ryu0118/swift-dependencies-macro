import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DependenciesMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependenciesMacro.self,
        DependencyValuesMacro.self
    ]
}
