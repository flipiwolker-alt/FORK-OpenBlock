#!/bin/sh
# Compiles the same ESP32 sketch twice — from an ASCII install path and from a Cyrillic one.
# The Cyrillic run is expected to fail with "Failed to get path name".
#
# Usage: sh scripts/repro-cyrillic.sh <ascii-install> <cyrillic-install>
#   e.g. sh scripts/repro-cyrillic.sh "E:/openblock-desktop" "E:/уавцуа/OpenBlockDesktop"
set -u

ASCII_INSTALL="${1:-}"
CYR_INSTALL="${2:-}"
if [ -z "$ASCII_INSTALL" ] || [ -z "$CYR_INSTALL" ]; then
    echo "usage: $0 <ascii-install> <cyrillic-install>" >&2
    exit 2
fi

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKETCH="$REPO/sketches/cyr_blink"
FQBN="esp32:esp32:esp32"
WORK="${TMPDIR:-/tmp}/ob-repro"
mkdir -p "$WORK"

# arduino-cli reads the toolchain from directories.data, so pointing it at each install
# is what actually varies between the two runs.
run_case() {
    label="$1"
    install="$2"
    cli="$install/tools/Arduino/arduino-cli.exe"

    echo "=============================================================="
    echo "[$label] install: $install"

    if [ ! -f "$cli" ]; then
        echo "[$label] SKIP — arduino-cli.exe not found at $cli"
        return 0
    fi

    cfg="$WORK/acli-$label.yaml"
    cat > "$cfg" <<EOF
board_manager:
    additional_urls:
        - https://espressif.github.io/arduino-esp32/package_esp32_index.json
directories:
    data: $install/tools/Arduino
    downloads: $install/tools/Arduino/staging
    user: $install/tools/Arduino
logging:
    level: info
EOF

    # Capture to a file rather than piping: after a pipe, $? is tail's status, not the compiler's.
    log="$WORK/$label.log"
    "$cli" compile --config-file "$cfg" --fqbn "$FQBN" \
        --build-path "$WORK/build-$label" "$SKETCH" > "$log" 2>&1
    status=$?
    tail -15 "$log"

    if [ $status -eq 0 ]; then
        echo "[$label] RESULT: compiled OK"
    else
        echo "[$label] RESULT: FAILED (exit $status)"
    fi
    return 0
}

run_case ascii "$ASCII_INSTALL"
run_case cyr "$CYR_INSTALL"

echo "=============================================================="
echo "Expected: ascii compiles, cyr fails with 'Failed to get path name'."
