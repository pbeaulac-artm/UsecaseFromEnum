import MyMacro

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

let c = AClass()
print(c.toString())         // Foo is AClass bar is class
print(c.toDetailString())   // Foo is AClass bar is class { title: hello, count: 42 }

let s = AStruct()
print(s.toString())         // Foo is AStruct bar is struct
print(s.toDetailString())   // Foo is AStruct bar is struct { name: Alice, age: 30 }

let e1 = SimpleEnum.red
print(e1.toString())        // Foo is SimpleEnum bar is enum
print(e1.toDetailString())  // Foo is SimpleEnum bar is enum (case: red)

let e2 = NetworkState.loading(progress: 0.75)
print(e2.toString())        // Foo is NetworkState bar is enum
print(e2.toDetailString())  // Foo is NetworkState bar is enum (case: loading(progress: 0.75), values: progress: 0.75)

let e3 = NetworkState.failed(code: 404, message: "Not found")
print(e3.toDetailString())  // Foo is NetworkState bar is enum (case: failed(code: 404, message: "Not found"), values: code: 404, message: Not found)
