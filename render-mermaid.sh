#!/bin/bash
# Script to render Mermaid diagrams to PNG/SVG

echo "Installing Mermaid CLI..."
npm install -g @mermaid-js/mermaid-cli

echo ""
echo "Rendering diagrams..."
echo ""

# Create output directory
mkdir -p rendered-diagrams

# Example: Render a specific diagram
# mmdc -i input.mmd -o output.png

echo "✅ Installation complete!"
echo ""
echo "To render a diagram:"
echo "1. Extract Mermaid code to a .mmd file"
echo "2. Run: mmdc -i diagram.mmd -o diagram.png"
echo ""
echo "Example:"
echo "  mmdc -i system-context.mmd -o rendered-diagrams/system-context.png"
