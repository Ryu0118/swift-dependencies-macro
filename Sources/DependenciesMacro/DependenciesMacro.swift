import Dependencies

@attached(member, names: named(init))
public macro PublicInit() = #externalMacro(module: "PublicInitMacroPlugin", type: "PublicInitMacro")

@attached(extension, conformances: TestDependencyKey, names: named(testValue))
public macro Dependencies() = #externalMacro(module: "DependenciesMacroPlugin", type: "DependenciesMacro")

@attached(member, names: arbitrary)
public macro DependencyValue<T: TestDependencyKey>(_ type: T.Type) = #externalMacro(module: "DependenciesMacroPlugin", type: "DependencyValuesMacro")
