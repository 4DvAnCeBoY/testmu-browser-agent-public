#!/bin/sh
# testmu-browser-agent installer
# Usage: curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
set -e

REPO="4DvAnCeBoY/testmu-browser-agent-public"
BINARY="testmu-browser-agent"
INSTALL_DIR="/usr/local/bin"

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux" ;;
    *)
        echo "Error: Unsupported OS: $OS"
        echo "Download manually from https://github.com/$REPO/releases"
        exit 1
        ;;
esac

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)  ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Get latest release tag
echo "Detecting latest release..."
TAG=$(curl -sSf "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$TAG" ]; then
    echo "Error: Could not determine latest release"
    exit 1
fi
echo "Latest release: $TAG"

# Construct download URL
FILENAME="${BINARY}-${OS}-${ARCH}"
URL="https://github.com/$REPO/releases/download/$TAG/$FILENAME"

# Download to temp directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading $FILENAME..."
curl -sSfL "$URL" -o "$TMP_DIR/$BINARY"

# Download checksums and verify
CHECKSUMS_URL="https://github.com/$REPO/releases/download/$TAG/checksums.txt"
if curl -sSfL "$CHECKSUMS_URL" -o "$TMP_DIR/checksums.txt" 2>/dev/null; then
    echo "Verifying checksum..."
    EXPECTED=$(grep "$FILENAME" "$TMP_DIR/checksums.txt" | awk '{print $1}')
    if [ -n "$EXPECTED" ]; then
        if command -v sha256sum >/dev/null 2>&1; then
            ACTUAL=$(sha256sum "$TMP_DIR/$BINARY" | awk '{print $1}')
        else
            ACTUAL=$(shasum -a 256 "$TMP_DIR/$BINARY" | awk '{print $1}')
        fi
        if [ "$EXPECTED" != "$ACTUAL" ]; then
            echo "Error: Checksum mismatch"
            echo "  Expected: $EXPECTED"
            echo "  Actual:   $ACTUAL"
            exit 1
        fi
        echo "Checksum verified."
    fi
fi

# Install
chmod +x "$TMP_DIR/$BINARY"
if [ -w "$INSTALL_DIR" ]; then
    mv "$TMP_DIR/$BINARY" "$INSTALL_DIR/$BINARY"
elif command -v sudo >/dev/null 2>&1; then
    echo "Installing to $INSTALL_DIR (requires sudo)..."
    sudo mv "$TMP_DIR/$BINARY" "$INSTALL_DIR/$BINARY"
else
    echo "Cannot write to $INSTALL_DIR and sudo is not available."
    echo "Installing to ~/.local/bin instead..."
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    mv "$TMP_DIR/$BINARY" "$INSTALL_DIR/$BINARY"
fi

# Verify
VERSION=$("$INSTALL_DIR/$BINARY" --version 2>/dev/null || echo "installed")
echo ""
echo "testmu-browser-agent $VERSION"
echo "Installed to: $INSTALL_DIR/$BINARY"
echo ""
echo "Quick start:"
echo "  testmu-browser-agent open https://example.com"
echo "  testmu-browser-agent snapshot"
echo "  testmu-browser-agent screenshot --output output.png"
