# UsecaseFromEnum
A Swift playground exploring a use case pattern using enums for dependency injection. Each use case exposes a static execute method that takes an environment enum (.prod, .debug, .mock), which internally resolves the correct repository implementation — no singletons, no external wiring.
