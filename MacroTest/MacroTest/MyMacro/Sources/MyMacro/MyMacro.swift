// The Swift Programming Language
// https://docs.swift.org/swift-book

/// Attach `@Foobar` to any class, struct, or enum to automatically generate:
///
/// - `toString() -> String`
///   Returns `"Foo is <TypeName> bar is <class|struct|enum>"`
///
/// - `toDetailString() -> String`
///   Returns the same base string, plus all stored property names and values
///   using `Mirror` at runtime. Example:
///   `"Foo is Person bar is struct { name: Alice, age: 30 }"`
///
/// Example:
/// ```swift
/// @Foobar
/// struct Person {
///     var name: String
///     var age: Int
/// }
///
/// let p = Person(name: "Alice", age: 30)
/// p.toString()       // "Foo is Person bar is struct"
/// p.toDetailString() // "Foo is Person bar is struct { name: Alice, age: 30 }"
/// ```
@attached(member, names: named(toString), named(toDetailString))
public macro Foobar() = #externalMacro(module: "MyMacroMacros", type: "FoobarMacro")
