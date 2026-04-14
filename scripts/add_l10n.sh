#!/usr/bin/env bash
# Usage: ./scripts/add_l10n.sh <key> "<en_value>" "<es_value>"
# Example: ./scripts/add_l10n.sh profileTitle "Profile" "Perfil"

set -euo pipefail

# ── Validation ──────────────────────────────────────────────────────────────
if [ $# -ne 3 ]; then
  echo "Usage: $0 <key> \"<en_value>\" \"<es_value>\""
  echo "Example: $0 profileTitle \"Profile\" \"Perfil\""
  exit 1
fi

KEY="$1"
EN_VALUE="$2"
ES_VALUE="$3"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ARB_EN="$PROJECT_DIR/lib/l10n/app_en.arb"
ARB_ES="$PROJECT_DIR/lib/l10n/app_es.arb"

# ── Check key doesn't already exist ─────────────────────────────────────────
if grep -q "\"$KEY\"" "$ARB_EN"; then
  echo "❌  Key '$KEY' already exists in app_en.arb"
  exit 1
fi

# ── Escape double quotes inside values for JSON ──────────────────────────────
EN_ESCAPED="${EN_VALUE//\"/\\\"}"
ES_ESCAPED="${ES_VALUE//\"/\\\"}"

# ── Insert before the last closing brace in each .arb ───────────────────────
# Adds a trailing comma to the previous last entry, then appends the new key.
insert_key() {
  local file="$1"
  local value="$2"

  # Add comma to the line just before the final `}`
  # (only if it doesn't already end with a comma or `{`)
  perl -i -0pe 's/((?!.*,\s*\n\s*\})[^\n]+)(\n\s*\}\s*$)/\1,\n  "'"$KEY"'": "'"$value"'"\2/' "$file"
}

insert_key "$ARB_EN" "$EN_ESCAPED"
insert_key "$ARB_ES" "$ES_ESCAPED"

# ── Regenerate Dart files ────────────────────────────────────────────────────
echo "🔄  Running flutter gen-l10n..."
cd "$PROJECT_DIR"
flutter gen-l10n --suppress-warnings 2>/dev/null || flutter gen-l10n

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "✅  Added '$KEY' to both .arb files and regenerated localizations."
echo "    en: \"$EN_VALUE\""
echo "    es: \"$ES_VALUE\""
