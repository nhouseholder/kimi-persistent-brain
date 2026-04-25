#!/bin/bash
set -e

echo "=== kimi-persistent-brain installer ==="

# Check deps
echo "Checking dependencies..."

if ! command -v engram &>/dev/null; then
    echo "Installing engram..."
    brew tap gentleman-programming/tap
    brew install engram
else
    echo "✓ engram already installed"
fi

if ! command -v cgc &>/dev/null; then
    echo "Installing CodeGraphContext..."
    if command -v uv &>/dev/null; then
        uv tool install codegraphcontext
    elif command -v pipx &>/dev/null; then
        pipx install codegraphcontext
    else
        echo "ERROR: Need uv or pipx to install CGC. Install uv: https://docs.astral.sh/uv/"
        exit 1
    fi
else
    echo "✓ CodeGraphContext already installed"
fi

# Install skills
SKILLS_DIR="${HOME}/.kimi/skills"
REPO_SKILLS="$(dirname "$0")/skills"

mkdir -p "$SKILLS_DIR"

echo "Installing skills to $SKILLS_DIR..."
for skill in "$REPO_SKILLS"/*; do
    if [ -d "$skill" ]; then
        name=$(basename "$skill")
        cp -r "$skill" "$SKILLS_DIR/"
        echo "  ✓ $name"
    fi
done

# Check config
echo ""
echo "Checking Kimi config..."
CONFIG="${HOME}/.kimi/config.toml"
if [ -f "$CONFIG" ]; then
    if grep -q "merge_all_available_skills = true" "$CONFIG"; then
        echo "  ✓ merge_all_available_skills = true"
    else
        echo "  ⚠️ Add 'merge_all_available_skills = true' to $CONFIG"
    fi
else
    echo "  ⚠️ No config.toml found. Create one with:"
    echo "     merge_all_available_skills = true"
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Next steps:"
echo "1. Add MCP servers to ~/.kimi/mcp.json:"
echo '   {"
echo '     "mcpServers": {"
echo '       "engram": { "command": "engram", "args": ["mcp"] },"
echo '       "codegraphcontext": {"
echo '         "command": "cgc", "args": ["mcp", "start"],"
echo '         "env": { "CGC_PROJECT_ROOT": "/path/to/project" }"
echo '       }"
echo '     }"
echo '   }'
echo ""
echo "2. Copy AGENTS.md to your project root"
echo ""
echo "3. Start Kimi CLI in your project — skills auto-load"
