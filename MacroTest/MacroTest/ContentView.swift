import SwiftUI
import MyMacro

// MARK: - Example types using @Foobar

@Foobar
class AClass {
    var title: String = "hello"
    var count: Int = 42
}

@Foobar
struct AStruct {
    var name: String = "Alice"
    var age: Int = 30
}

// Simple enum — no associated values
@Foobar
enum SimpleEnum {
    case red, green, blue
}

// Enum with associated values
@Foobar
enum NetworkState {
    case idle
    case loading(progress: Double)
    case failed(code: Int, message: String)
}

// MARK: - View

struct ContentView: View {

    let classInstance = AClass()
    let structInstance = AStruct()
    let simpleEnum = SimpleEnum.red
    let enumWithValues = NetworkState.loading(progress: 0.75)
    let enumWithMultipleValues = NetworkState.failed(code: 404, message: "Not found")

    var body: some View {
        List {
            Section("toString()") {
                Text(classInstance.toString())
                Text(structInstance.toString())
                Text(simpleEnum.toString())
                Text(enumWithValues.toString())
            }
            Section("toDetailString()") {
                Text(classInstance.toDetailString())
                Text(structInstance.toDetailString())
                Text(simpleEnum.toDetailString())
                Text(enumWithValues.toDetailString())
                Text(enumWithMultipleValues.toDetailString())
            }
        }
        .navigationTitle("@Foobar Macro")
    }
}

#Preview {
    ContentView()
}
