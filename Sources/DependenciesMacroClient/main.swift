import DependenciesMacro
import Dependencies

@PublicInit
@Dependencies
public struct TestClient {
    public var request: @Sendable (_ request: String) -> Void
}

@DependencyValue(TestClient.self)
public extension DependencyValues {
}
