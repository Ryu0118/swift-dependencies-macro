# DependenciesMacro
Macro for convenient use of swift-dependencies

## Usage
```Swift
import Dependencies
import DependenciesMacro

@PublicInit
@Dependencies
public struct TestClient {
    public var request: @Sendable (_ request: Request) -> Void
}

@DependencyValue(TestClient.self)
public extension DependencyValues {}
```
`@PublicInit` is a Member Macro and provides a public initializer.
This macro can be applied only to public structs. <br>
`@Dependencies` is an Extension Macro that can conform TestClient to TestDependencyKey. This macro can also be applied only to structs. <br>
`@DependencyValue` is a Member Macro; by using a Macro for the extension of DependencyValues, you can add a property of the type specified in the argument

In this example, the macro is expanded as follows.
```Swift
public struct TestClient {
    public var request: @Sendable (_ request: Request) -> Void
    public init(
        request: @Sendable @escaping (_ request: Request) -> Void
    ) {
        self.request = request
    }
}
extension TestClient: TestDependencyKey {
    public static let testValue = TestClient(
        request: unimplemented("\(Self.self).request")
    )
}

public extension DependencyValues {
    var testClient: TestClient {
        get {
            self[TestClient.self]
        }
        set {
            self[TestClient.self] = newValue
        }
    }
}
```

## Installation
This library can only be installed from swift package manager.
```Swift
.package(url: "https://github.com/Ryu0118/swift-dependencies-macro", from: "0.2.2")
```
