import DependenciesMacro
import Dependencies

@PublicInit
@Dependencies
public struct TestClient {
    public var request: @Sendable (_ request: String) -> Void
}

public extension DependencyValues {
    var testClient: TestClient {
        get { self[TestClient.self] }
        set { self[TestClient.self] = newValue }
    }
}
