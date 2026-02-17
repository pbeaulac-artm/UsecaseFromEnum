import Foundation

// Repository protocols
protocol SomeRepo {
    func getSomeRemoteData() -> String
}

protocol AnotherRepo {
    func getAnotherData() -> String
}

// Concrete implementations for SomeRepo
class SomeProdRepo: SomeRepo {
    func getSomeRemoteData() -> String {
        return "Production data from Some API"
    }
}

class SomeDebugRepo: SomeRepo {
    func getSomeRemoteData() -> String {
        return "Debug data from Some API with logging"
    }
}

class SomeMockRepo: SomeRepo {
    func getSomeRemoteData() -> String {
        return "Mock data from Some API"
    }
}

// Concrete implementations for AnotherRepo
class AnotherProdRepo: AnotherRepo {
    func getAnotherData() -> String {
        return "Production data from Another API"
    }
}

class AnotherDebugRepo: AnotherRepo {
    func getAnotherData() -> String {
        return "Debug data from Another API"
    }
}

class AnotherMockRepo: AnotherRepo {
    func getAnotherData() -> String {
        return "Mock data from Another API"
    }
}

// Environment enum that creates the repo instance
enum SomeRepoEnvironment {
    case prod
    case debug
    case mock

    var repo: SomeRepo {
        switch self {
        case .prod:
            return SomeProdRepo()
        case .debug:
            return SomeDebugRepo()
        case .mock:
            return SomeMockRepo()
        }
    }
}

enum AnotherRepoEnvironment {
    case prod
    case debug
    case mock

    var repo: AnotherRepo {
        switch self {
        case .prod:
            return AnotherProdRepo()
        case .debug:
            return AnotherDebugRepo()
        case .mock:
            return AnotherMockRepo()
        }
    }
}

// Use case enum - each case knows which container to use
enum SomeUseCase {

    static func execute(destination: String, time: Int, environment: SomeRepoEnvironment) {
        let repo = environment.repo

        print("mode: \(destination), time: \(time)")
        print("Data: \(repo.getSomeRemoteData())")
    }
}

enum AnotherUseCase {

    static func execute(
        destination: String,
        time: Int,
        environment: AnotherRepoEnvironment = .debug
    ) {
        let repo = environment.repo

        print("mode: \(destination), time: \(time)")
        print("Data: \(repo.getAnotherData())")
    }
}

// Usage
SomeUseCase.execute(destination: "Server A", time: 100, environment: .prod)
SomeUseCase.execute(destination: "Local", time: 50, environment: .debug)

AnotherUseCase.execute(destination: "Server B", time: 200, environment: .mock)
AnotherUseCase.execute(destination: "Remote", time: 75, environment: .prod)
