import DependenciesMacro
import PublicInitMacroPlugin
import MacroTesting
import XCTest

final class PublicInitMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: ["PublicInit": PublicInitMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testFixIt() {
        assertMacro(applyFixIts: true) {
            """
            @PublicInit
            public struct Test {
                var a = true
            }
            """
        } matches: {
            """
            @PublicInit
            public struct Test {
                var a : <#Type#> = true
            }
            """
        }
    }

    func testDiagnostic() {
        assertMacro {
            """
            @PublicInit
            struct Test {}
            """
        } matches: {
            """
            @PublicInit
            ╰─ 🛑 PublicInit Macro can only be applied to public struct.
            struct Test {}
            """
        }

        assertMacro {
            """
            @PublicInit
            public final class Test {}
            """
        } matches: {
            """
            @PublicInit
            public final class Test {}
                         ┬────
                         ╰─ 🛑 PublicInit Macro can only be applied to struct.
            """
        }

        assertMacro {
            """
            @PublicInit
            public actor Test {}
            """
        } matches: {
            """
            @PublicInit
            public actor Test {}
                   ┬────
                   ╰─ 🛑 PublicInit Macro can only be applied to struct.
            """
        }

        assertMacro {
            """
            @PublicInit
            public enum Test {}
            """
        } matches: {
            """
            @PublicInit
            public enum Test {}
                   ┬───
                   ╰─ 🛑 PublicInit Macro can only be applied to struct.
            """
        }
    }

    func testMacro() {
        assertMacro {
            """
            @PublicInit
            public struct Test {
                static let staticValue = 0
                let a: String
                let b: () -> Void
                let c: @Sendable () -> Void
                let d: @Sendable () async -> Void
                let e: @Sendable () async throws -> Void
                let f: @Sendable (String) async throws -> String
                let g: @Sendable (_ arg: String) async throws -> String
                var h: @Sendable (_ arg1: String, _ arg2: String) async throws -> String
                var i: @Sendable (String, Int) async throws -> String
                var j: String = ""
            }
            """
        } matches: {
            """
            public struct Test {
                static let staticValue = 0
                let a: String
                let b: () -> Void
                let c: @Sendable () -> Void
                let d: @Sendable () async -> Void
                let e: @Sendable () async throws -> Void
                let f: @Sendable (String) async throws -> String
                let g: @Sendable (_ arg: String) async throws -> String
                var h: @Sendable (_ arg1: String, _ arg2: String) async throws -> String
                var i: @Sendable (String, Int) async throws -> String
                var j: String = ""

                public init(
                    a: String,
                    b: @escaping () -> Void,
                    c: @Sendable @escaping () -> Void,
                    d: @Sendable @escaping () async -> Void,
                    e: @Sendable @escaping () async throws -> Void,
                    f: @Sendable @escaping (String) async throws -> String,
                    g: @Sendable @escaping (_ arg: String) async throws -> String,
                    h: @Sendable @escaping (_ arg1: String, _ arg2: String) async throws -> String,
                    i: @Sendable @escaping (String, Int) async throws -> String,
                    j: String = ""
                ) {
                    self.a = a
                    self.b = b
                    self.c = c
                    self.d = d
                    self.e = e
                    self.f = f
                    self.g = g
                    self.h = h
                    self.i = i
                    self.j = j
                }
            }
            """
        }
    }
}
