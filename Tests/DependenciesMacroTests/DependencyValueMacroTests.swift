import DependenciesMacro
import DependenciesMacroPlugin
import MacroTesting
import XCTest

final class DependencyValueMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: ["DependencyValue": DependencyValuesMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testDiagnostic() {
        assertMacro {
            """
            @DependencyValue(TestClient.self)
            public struct DependencyValues {}
            """
        } matches: {
            """
            @DependencyValue(TestClient.self)
            public struct DependencyValues {}
                   ┬─────
                   ╰─ 🛑 DependencyValue Macro can only be applied to extension.
            """
        }

        assertMacro {
            """
            @DependencyValue(TestClient.self)
            public class DependencyValues {}
            """
        } matches: {
            """
            @DependencyValue(TestClient.self)
            public class DependencyValues {}
                   ┬────
                   ╰─ 🛑 DependencyValue Macro can only be applied to extension.
            """
        }

        assertMacro {
            """
            @DependencyValue(TestClient.self)
            public actor DependencyValues {}
            """
        } matches: {
            """
            @DependencyValue(TestClient.self)
            public actor DependencyValues {}
                   ┬────
                   ╰─ 🛑 DependencyValue Macro can only be applied to extension.
            """
        }

        assertMacro {
            """
            @DependencyValue(TestClient.self)
            public enum DependencyValues {}
            """
        } matches: {
            """
            @DependencyValue(TestClient.self)
            public enum DependencyValues {}
                   ┬───
                   ╰─ 🛑 DependencyValue Macro can only be applied to extension.
            """
        }

        assertMacro {
            """
            @DependencyValue(TestClient.self)
            public extension Test {}
            """
        } matches: {
            """
            @DependencyValue(TestClient.self)
            public extension Test {}
                             ┬───
                             ╰─ 🛑 DependencyValue Macro can only be applied to extension of DependencyValues
            """
        }
    }

    func testMacro() {
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
