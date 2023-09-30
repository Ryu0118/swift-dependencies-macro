import DependenciesMacro
import Dependencies

@PublicInit
@Dependencies
public struct TestClient {
    public var testRequest: @Sendable (_ test: String) async throws -> Void
}

public extension DependencyValues {
    var testClient: TestClient {
        get { self[TestClient.self] }
        set { self[TestClient.self] = newValue }
    }
}
