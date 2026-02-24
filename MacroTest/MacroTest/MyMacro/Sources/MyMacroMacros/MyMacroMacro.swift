import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `@Foobar` attached macro.
///
/// When applied to a class, struct, or enum, it injects:
///   - `toString() -> String` returning "Foo is <TypeName> bar is <class|struct|enum>"
///   - `toDetailString() -> String`:
///       - class/struct: base string + stored property names/values via Mirror
///       - enum: base string + active case name + any associated values
public struct FoobarMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Determine the type name and kind from the syntax tree at compile time
        let typeName: String
        let typeKind: String

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            typeName = classDecl.name.text
            typeKind = "class"
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            typeName = structDecl.name.text
            typeKind = "struct"
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            typeName = enumDecl.name.text
            typeKind = "enum"
        } else {
            throw MacroExpansionErrorMessage("@Foobar can only be applied to a class, struct, or enum")
        }

        // The base string is fixed at compile time — embed it as a literal in the generated code
        let baseString = "Foo is \(typeName) bar is \(typeKind)"

        // toString() — returns the fixed base string
        let toString: DeclSyntax = """
            func toString() -> String {
                \(raw: "\"\(baseString)\"")
            }
            """

        // toDetailString() differs for enums vs class/struct:
        //
        // Enums: Mirror(reflecting:) only sees *associated values* of the current case,
        //        NOT which case is active. We use String(describing: self) for the case name.
        //
        // Class/struct: Mirror walks stored properties to show "name: value" pairs.
        let toDetailString: DeclSyntax

        if typeKind == "enum" {
            toDetailString = """
                func toDetailString() -> String {
                    let base = \(raw: "\"\(baseString)\"")
                    let described = String(describing: self)
                    let mirror = Mirror(reflecting: self)
                    if mirror.children.isEmpty {
                        return base + " (case: " + described + ")"
                    }
                    let associated = mirror.children
                        .map { child -> String in
                            if let label = child.label {
                                return "\\(label): \\(child.value)"
                            }
                            return String(describing: child.value)
                        }
                        .joined(separator: ", ")
                    return base + " (case: " + described + ", values: " + associated + ")"
                }
                """
        } else {
            toDetailString = """
                func toDetailString() -> String {
                    let base = \(raw: "\"\(baseString)\"")
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
                """
        }

        return [toString, toDetailString]
    }
}

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FoobarMacro.self,
    ]
}
