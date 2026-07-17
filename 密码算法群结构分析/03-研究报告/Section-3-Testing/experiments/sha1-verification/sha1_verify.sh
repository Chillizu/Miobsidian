#!/usr/bin/env bash
# SHA-1 collision verification using the SHAttered public collision pair.
# Downloads the two colliding PDFs from shattered.io and checks that their
# SHA-1 digests are identical, demonstrating that SHA-1 is broken in practice.

set -euo pipefail

URL1="https://shattered.io/static/shattered-1.pdf"
URL2="https://shattered.io/static/shattered-2.pdf"
FILE1="shattered-1.pdf"
FILE2="shattered-2.pdf"

echo "Downloading SHAttered collision PDFs..."

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed." >&2
    exit 1
fi

if [ ! -f "$FILE1" ]; then
    curl -L -o "$FILE1" "$URL1" || { echo "Download failed — run with network connectivity" >&2; exit 1; }
fi

if [ ! -f "$FILE2" ]; then
    curl -L -o "$FILE2" "$URL2" || { echo "Download failed — run with network connectivity" >&2; exit 1; }
fi

echo "Computing SHA-1 hashes..."

if command -v sha1sum >/dev/null 2>&1; then
    HASH1=$(sha1sum "$FILE1" | awk '{print $1}')
    HASH2=$(sha1sum "$FILE2" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
    HASH1=$(shasum -a 1 "$FILE1" | awk '{print $1}')
    HASH2=$(shasum -a 1 "$FILE2" | awk '{print $1}')
else
    echo "Error: neither sha1sum nor shasum is available." >&2
    exit 1
fi

echo "SHA-1($FILE1) = $HASH1"
echo "SHA-1($FILE2) = $HASH2"

if [ "$HASH1" = "$HASH2" ]; then
    echo "Collision: VERIFIED"
else
    echo "Collision verification FAILED — unexpected" >&2
    exit 1
fi

# Expected hash (from Stevens et al. CRYPTO 2017): 38762cf7f55934b34d179ae6a4c80cadccbb7f0a
# Warn if the public files have changed.
EXPECTED="38762cf7f55934b34d179ae6a4c80cadccbb7f0a"
if [ "$HASH1" = "$EXPECTED" ]; then
    echo "Matches published SHAttered digest: $EXPECTED"
else
    echo "Warning: hash differs from the published SHAttered digest."
    echo "         Expected: $EXPECTED"
    echo "         Got:      $HASH1"
fi
