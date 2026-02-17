# Swift Enum-Based Use Case Pattern

A Swift playground demonstrating a lightweight dependency injection pattern using enums — no third-party frameworks, no singletons, no service locators.

## Concept

Each **use case** is a caseless enum with a static `execute` method. The caller passes an **environment** (`.prod`, `.debug`, `.mock`) which internally resolves the correct repository implementation.

```swift
SomeUseCase.execute(destination: "Server A", time: 100, environment: .prod)
```

## Structure

![Architecture Diagram](Resources/schema.png)

## Why enums for use cases?

- No instantiation needed — use cases are stateless by nature
- The compiler enforces exhaustive handling of environments
- Swapping implementations is a one-liner at the call site
- Zero dependencies

## Requirements

- Xcode 15+
- Swift 5.9+
