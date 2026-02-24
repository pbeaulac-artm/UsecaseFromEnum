import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MyMacroMacros)
import MyMacroMacros

let testMacros: [String: Macro.Type] = [
    "Foobar": FoobarMacro.self,
]
#endif

final class MyMacroTests: XCTestCase {

    func testFoobarOnStruct() throws {
        #if canImport(MyMacroMacros)
        assertMacroExpansion(
            """
            @Foobar
            struct Person {
                var name: String
                var age: Int
            }
            """,
            expandedSource: """
            struct Person {
                var name: String
                var age: Int
                func toString() -> String {
                    "Foo is \\("Person") bar is \\("struct")"
                }
                func toDetailString() -> String {
                    let base = "Foo is \\("Person") bar is \\("struct")"
                    let mirror = Mirror(reflecting: self)
                    if mirror.children.isEmpty {
                        return base
                    }
                    let props = mirror.children
                        .compactMap { child -> String? in
                            guard let label = child.label else { return nil }
                            return "\\(label): \\(child.value)"
                        }
                        .joined(separator: ", ")
                    return base + " { " + props + " }"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testFoobarOnClass() throws {
        #if canImport(MyMacroMacros)
        assertMacroExpansion(
            """
            @Foobar
            class AClass {
            }
            """,
            expandedSource: """
            class AClass {
                func toString() -> String {
                    "Foo is \\("AClass") bar is \\("class")"
                }
                func toDetailString() -> String {
                    let base = "Foo is \\("AClass") bar is \\("class")"
                    let mirror = Mirror(reflecting: self)
                    if mirror.children.isEmpty {
                        return base
                    }
                    let props = mirror.children
                        .compactMap { child -> String? in
                            guard let label = child.label else { return nil }
                            return "\\(label): \\(child.value)"
                        }
                        .joined(separator: ", ")
                    return base + " { " + props + " }"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
