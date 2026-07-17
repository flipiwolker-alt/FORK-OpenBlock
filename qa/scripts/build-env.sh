# Source this before any npm/build command: `source "E:/Загрузки/claude/build-env.sh"`
# Redirects ALL caches/temp off the full C: drive and puts portable Node 16 first on PATH.
BASE="E:/Загрузки/claude"
# PATH must use POSIX form: a Windows "E:/..." entry breaks on the drive-letter colon.
export PATH="/e/Загрузки/claude/node16:$PATH"
export NPM_CONFIG_CACHE="$BASE/.npm-cache"
export npm_config_cache="$BASE/.npm-cache"
export TEMP="$BASE/.tmp"
export TMP="$BASE/.tmp"
export ELECTRON_CACHE="$BASE/.cache-electron"
export electron_config_cache="$BASE/.cache-electron"
export ELECTRON_BUILDER_CACHE="$BASE/.cache-eb"
export npm_config_devdir="$BASE/.node-gyp"
# Node 16 has OpenSSL 1.1.1 so the legacy flag is unnecessary, but harmless as a safety net:
export NODE_OPTIONS="--max-old-space-size=4096"
mkdir -p "$BASE/.npm-cache" "$BASE/.tmp" "$BASE/.cache-electron" "$BASE/.cache-eb" "$BASE/.node-gyp"
echo "[build-env] node=$(node -v)  npm=$(npm -v)  cache=$NPM_CONFIG_CACHE"
