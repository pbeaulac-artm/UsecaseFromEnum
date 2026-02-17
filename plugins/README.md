# plsntMUL Plugin

A PlantUML plugin for converting `.plum` files to PNG images.

## Installation

The plugin requires Java to be installed. To set up the plugin:

1. Download PlantUML JAR:
   ```bash
   cd plugins
   curl -L -o plantuml.jar https://github.com/plantuml/plantuml/releases/download/v1.2024.3/plantuml-1.2024.3.jar
   ```

2. The `plsntMUL` script is already included and executable.

## Usage

Convert a `.plum` file to PNG:

```bash
./plugins/plsntMUL <input.plum> [output.png]
```

### Examples

Convert `schema.plum` to `schema.png` in the same directory:
```bash
./plugins/plsntMUL schema.plum
```

Convert `schema.plum` to a specific output location:
```bash
./plugins/plsntMUL schema.plum Resources/schema.png
```

## What is .plum?

`.plum` files are PlantUML diagram source files. PlantUML is a component that allows you to quickly write UML diagrams using a simple and intuitive text-based language.

## Dependencies

- Java Runtime Environment (JRE)
- PlantUML JAR (downloaded during setup)

## Notes

- The PlantUML JAR file is excluded from version control (see `.gitignore`)
- Graphviz is optional but recommended for better diagram rendering
- Without Graphviz, PlantUML will use its built-in rendering engine
