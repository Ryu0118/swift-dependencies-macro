import PublicInitMacroPlugin
import Dependencies

@attached(member, names: named(init))
public macro PublicInit() = #externalMacro(module: "PublicInitMacroPlugin", type: "PublicInitMacro")

@attached(extension, conformances: TestDependencyKey, names: named(testValue))
public macro Dependencies() = #externalMacro(module: "DependenciesMacroPlugin", type: "DependenciesMacro")
