#!/usr/bin/env bash
# Prints the Build Roadmap note for the current repo at session start.
# Only repos in the ShipBots catalog have a note, so personal projects print nothing.
# Never blocks: any failure prints nothing and exits 0.
#
# It sends ONE thing: the repo name (owner/repo), plus your GitHub sign-in so the
# warehouse back end knows you are on the ShipBots team. Nothing else leaves your
# computer. The note itself is built from GitHub by the ShipBots repo, not from chats.
ROADMAP_URL="${ROADMAP_URL:-https://warehouse-portal-ship-bots.vercel.app}"

command -v gh >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0
TOKEN="$(gh auth token 2>/dev/null)" || exit 0
[ -n "$TOKEN" ] || exit 0

DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
REMOTE="$(git -C "$DIR" remote get-url origin 2>/dev/null)" || exit 0
REPO="$(printf '%s' "$REMOTE" | sed -E 's#^(git@|ssh://git@|https://)([^/:]+)[/:]##; s#\.git$##')"
case "$REPO" in */*) ;; *) exit 0 ;; esac

# -f: any HTTP error (404 for a repo with no note, 401, 500) prints nothing.
NOTE="$(curl -fsS --max-time 8 -H "Authorization: Bearer $TOKEN" -H "Accept: text/plain" \
  "$ROADMAP_URL/api/roadmap-context?repo=$REPO" 2>/dev/null)" || exit 0
[ -n "$NOTE" ] || exit 0

# The note is plain text. If the server ever answers in JSON ({"text": "..."}),
# pull the text out; if that is not possible, print nothing rather than raw JSON.
case "$NOTE" in
  "{"*)
    command -v node >/dev/null 2>&1 || exit 0
    NOTE="$(printf '%s' "$NOTE" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);process.stdout.write(String(j.text||""))}catch{}})' 2>/dev/null)"
    [ -n "$NOTE" ] || exit 0
    ;;
  "<"*) exit 0 ;;  # an HTML page (sign-in screen) is never a note
esac
printf '%s\n' "$NOTE"
exit 0
