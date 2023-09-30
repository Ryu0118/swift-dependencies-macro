import DependenciesMacro
import DependenciesMacroPlugin
import MacroTesting
import XCTest

final class DependenciesMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: ["Dependencies": DependenciesMacro.self, "DependencyValue": DependencyValuesMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testDiagnostic() {
        assertMacro {
            """
            @Dependencies
            class Test {}
            """
        } matches: {
            """
            @Dependencies
            class Test {}
            ┬────
            ╰─ 🛑 Dependencies Macro can only be applied to struct.
            """
        }
        assertMacro {
            """
            @Dependencies
            enum Test {}
            """
        } matches: {
            """
            @Dependencies
            enum Test {}
            ┬───
            ╰─ 🛑 Dependencies Macro can only be applied to struct.
            """
        }
        assertMacro {
            """
            @Dependencies
            actor Test {}
            """
        } matches: {
            """
            @Dependencies
            actor Test {}
            ┬────
            ╰─ 🛑 Dependencies Macro can only be applied to struct.
            """
        }
    }

    func testMacro() {
        assertMacro {
            """
            @Dependencies
            public struct TestClient {
                let a: String
                let b: () -> Void
                let c: @Sendable () -> Void
                let d: @Sendable () async -> Void
                let e: @Sendable () async throws -> Void
                let f: @Sendable (String) async throws -> String
                let g: @Sendable (_ arg: String) async throws -> String
                var h: @Sendable (_ arg1: String, _ arg2: String) async throws -> String
                var i: @Sendable (String, Int) async throws -> String
            }
            """
        } matches: {
            #"""
            public struct TestClient {
                let a: String
                let b: () -> Void
                let c: @Sendable () -> Void
                let d: @Sendable () async -> Void
                let e: @Sendable () async throws -> Void
                let f: @Sendable (String) async throws -> String
                let g: @Sendable (_ arg: String) async throws -> String
                var h: @Sendable (_ arg1: String, _ arg2: String) async throws -> String
                var i: @Sendable (String, Int) async throws -> String
            }

            extension TestClient: TestDependencyKey {
                public static let testValue = TestClient(
                    a: unimplemented("\(Self.self).a"),
                    b: unimplemented("\(Self.self).b"),
                    c: unimplemented("\(Self.self).c"),
                    d: unimplemented("\(Self.self).d"),
                    e: unimplemented("\(Self.self).e"),
                    f: unimplemented("\(Self.self).f"),
                    g: unimplemented("\(Self.self).g"),
                    h: unimplemented("\(Self.self).h"),
                    i: unimplemented("\(Self.self).i")
                )
            }
            """#
        }

        assertMacro {
            """
            @DependencyValue(TestClient.self)
            public extension DependencyValues {}
            """
        } matches: {
            """
            public extension DependencyValues {

                var testClient: TestClient {
                    get {
                        self [TestClient.self]
                    }
                    set {
                        self [TestClient.self] = newValue
                    }
                }}
            """
        }
    }
}
