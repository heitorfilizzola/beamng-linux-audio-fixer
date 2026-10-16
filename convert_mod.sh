#!/usr/bin/env bash
# ------------------------------------------------------------
# convert_mod.sh – Automatic fix for BeamNG mod audio issues
# ------------------------------------------------------------
# Usage:   ./convert_mod.sh path/to/mod.zip
# The script:
#   1. Makes a backup of the original zip (adds .bak or timestamp).
#   2. Extracts the zip to a temporary directory.
#   3. Converts every *.wav (ADPCM, etc.) to PCM 16‑bit WAV using ffmpeg.
#   4. Fixes known path mismatches in *.sfxBlend2D.json files (dec → acc).
#   5. Re‑packs the mod, overwriting the original zip.
#   6. Cleans up temporary files.
# ------------------------------------------------------------

set -euo pipefail

# ---------- Helper functions ----------
log() { echo "[${0##*/}] $*"; }

# Ensure required tools are available
for cmd in unzip zip ffmpeg find sed; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found in PATH" >&2
    exit 1
  fi
done

# ---------- Argument handling ----------
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <mod_zip_file>" >&2
  exit 1
fi

ZIP_PATH="$1"
if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Error: file '$ZIP_PATH' does not exist" >&2
  exit 1
fi
if [[ "${ZIP_PATH##*.}" != "zip" ]]; then
  echo "Error: file '$ZIP_PATH' is not a .zip archive" >&2
  exit 1
fi

# ---------- Backup ----------
BACKUP_PATH="${ZIP_PATH}.bak"
if [[ -e "$BACKUP_PATH" ]]; then
  # If a backup already exists, add a timestamp to avoid overwriting
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  BACKUP_PATH="${ZIP_PATH}.bak.${TIMESTAMP}"
fi
log "Creating backup: $BACKUP_PATH"
cp -v "$ZIP_PATH" "$BACKUP_PATH"

# ---------- Extraction ----------
TMP_DIR=$(mktemp -d)
log "Extracting zip to temporary directory: $TMP_DIR"
unzip -q "$ZIP_PATH" -d "$TMP_DIR"

# ---------- Audio conversion ----------
log "Converting WAV files to PCM 16‑bit..."
find "$TMP_DIR" -type f -name "*.wav" -print0 |
while IFS= read -r -d '' wav; do
  tmpfile="${wav}.tmp.wav"
  ffmpeg -y -loglevel error -i "$wav" -c:a pcm_s16le "$tmpfile"
  mv -f "$tmpfile" "$wav"
done
log "Audio conversion finished."

# ---------- JSON path fix (common issue) ----------
log "Fixing possible path mismatches in *.sfxBlend2D.json files..."
# Replace any occurrence of '/dec/EngineLoop_Acc_' with '/acc/EngineLoop_Acc_'
# This is the only pattern we have identified as problematic.
find "$TMP_DIR" -type f -name "*.sfxBlend2D.json" -print0 |
while IFS= read -r -d '' json; do
  if grep -q '/dec/EngineLoop_Acc_' "$json"; then
    sed -i 's|/dec/EngineLoop_Acc_|/acc/EngineLoop_Acc_|g' "$json"
    log "  Fixed paths in $json"
  fi
done

# ---------- Re‑pack the mod ----------
log "Re‑packing the mod into original zip location..."
# Move to the temporary directory to create a clean zip without leading path components
pushd "$TMP_DIR" >/dev/null
zip -r -q "$ZIP_PATH" . -x "*__MACOSX*"
popd >/dev/null

# ---------- Cleanup ----------
log "Cleaning up temporary files"
rm -rf "$TMP_DIR"

log "Mod processing complete. Original backup stored at: $BACKUP_PATH"
exit 0
