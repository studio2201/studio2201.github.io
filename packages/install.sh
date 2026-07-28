#!/usr/bin/env bash
# studio2201 install helper
# Usage:
#   curl -fsSL https://studio2201.github.io/packages/install.sh | bash -s -- beam
#   curl -fsSL https://studio2201.github.io/packages/install.sh | bash -s -- --run pad
#   curl -fsSL https://studio2201.github.io/packages/install.sh | sudo bash   # shows catalog
set -euo pipefail

ORG="studio2201"
REGISTRY="ghcr.io/${ORG}"
SITE="https://studio2201.github.io"

# app|port|description
CATALOG=$(cat <<'EOF'
beam|4401|File sharing
pad|4402|Collaborative scratchpad
todo|4403|Task lists
trace|4404|Network / WHOIS / ASN
grid|4405|Kanban
pulse|4406|System metrics
habit|4407|Habit tracker / streaks (planned)
mark|4408|Bookmarks
poll|4409|Polls / quick votes (planned)
probe|4410|Uptime / endpoint health (planned)
snake|4501|Snake game
rustle|4502|Wordle clone
scan|4503|Sector scanner / minesweeper
defend|4504|Space shooter
statesync|4601|Emby/Jellyfin watch-state sync (media)
EOF
)

usage() {
  cat <<EOF
studio2201 install helper

Containers are the supported install path. Native package repos are not
published yet; this script prints (or runs) the official docker command.

Usage:
  $0 [--run] <app>

Examples:
  $0 beam
  $0 --run pad

Catalog:
EOF
  printf '  %-12s %-6s %s\n' "APP" "PORT" "DESCRIPTION"
  while IFS='|' read -r app port desc; do
    [ -n "${app:-}" ] || continue
    printf '  %-12s %-6s %s\n' "$app" "$port" "$desc"
  done <<< "$CATALOG"
  cat <<EOF

Docs: ${SITE}
Org:  https://github.com/${ORG}
EOF
}

lookup() {
  local want="$1"
  while IFS='|' read -r app port desc; do
    [ -n "${app:-}" ] || continue
    if [ "$app" = "$want" ]; then
      echo "$port"
      return 0
    fi
  done <<< "$CATALOG"
  return 1
}

RUN=0
APP=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --run)
      RUN=1
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      APP="$1"
      shift
      ;;
  esac
done

if [ -z "$APP" ]; then
  usage
  exit 0
fi

APP=$(echo "$APP" | tr '[:upper:]' '[:lower:]')

if ! PORT=$(lookup "$APP"); then
  echo "Unknown app: $APP" >&2
  echo >&2
  usage >&2
  exit 1
fi

CONFIG_DIR="${CONFIG_DIR:-/mnt/user/appdata/${APP}}"
IMAGE="${REGISTRY}/${APP}:latest"

CMD=(docker run -d --name "$APP" -p "${PORT}:${PORT}" -v "${CONFIG_DIR}:/config" "$IMAGE")

echo "# studio2201/${APP}  port ${PORT}"
echo "# image: ${IMAGE}"
printf '%q ' "${CMD[@]}"
echo

if [ "$RUN" -eq 1 ]; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found on PATH" >&2
    exit 1
  fi
  echo "→ running…"
  "${CMD[@]}"
  echo "→ open http://localhost:${PORT}"
fi
