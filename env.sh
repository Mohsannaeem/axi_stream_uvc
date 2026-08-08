#!/usr/bin/env bash
# EDA Buddy environment — Git Bash / Cygwin / MSYS.
#
#   . ./env.sh          (source it; do NOT execute it — PATH changes must land
#                        in your current shell, not a child process)
#
# Sets up, for this shell only:
#   PATH                   + the directory holding the `eda-buddy` command
#   EDA_BUDDY_MAKE         make executable, since make is usually not on PATH here
#   EDA_BUDDY_PROJECT_CFG  so commands work from any directory
#
# Everything is derived from this script's own location, so a fresh clone on
# another machine needs no edits. Override any value by exporting it first.

# ── locate ourselves ─────────────────────────────────────────────────────────
# BASH_SOURCE is the script path even when sourced, which $0 is not.
_EB_HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
_EB_ROOT="$(cd "$_EB_HERE/.." && pwd)"

_eb_win2posix() {
    if command -v cygpath >/dev/null 2>&1; then cygpath -u "$1"; else echo "$1"; fi
}

# EDA Buddy runs on native Windows Python, which cannot open /c/... or /d/...
# paths. MSYS and Cygwin often convert these on the way into a native process,
# but the rules differ between them, so convert explicitly instead of relying
# on it. -m gives mixed form (D:/path) — valid for Python and free of the
# backslashes that would need escaping in a shell string.
_eb_posix2win() {
    if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else echo "$1"; fi
}

_eb_warn() { printf '\033[33m[env] %s\033[0m\n' "$1" >&2; }
_eb_ok()   { printf '\033[32m[env] %s\033[0m\n' "$1"; }

# ── 1. put the eda-buddy command on PATH ─────────────────────────────────────
# Ask Python where console scripts land rather than hardcoding a path: the
# answer differs between a user install, a venv, and a system install.
_EB_PY="${EDA_BUDDY_PYTHON:-python}"

if ! command -v "$_EB_PY" >/dev/null 2>&1; then
    _eb_warn "python not found on PATH; set EDA_BUDDY_PYTHON to your interpreter."
else
    _EB_SCRIPTS="$("$_EB_PY" - <<'PY' 2>/dev/null
import os, sysconfig
seen = []
for scheme in ("nt_user", "nt", None):
    try:
        p = sysconfig.get_path("scripts") if scheme is None else sysconfig.get_path("scripts", scheme)
    except Exception:
        continue
    if p and p not in seen:
        seen.append(p)
# Prefer whichever directory actually contains the installed command.
for p in seen:
    if any(os.path.exists(os.path.join(p, n)) for n in ("eda-buddy.exe", "eda-buddy")):
        print(p)
        break
PY
)"

    if [ -n "$_EB_SCRIPTS" ]; then
        _EB_SCRIPTS_POSIX="$(_eb_win2posix "$_EB_SCRIPTS")"
        case ":$PATH:" in
            *":$_EB_SCRIPTS_POSIX:"*) : ;;                       # already present
            *) export PATH="$_EB_SCRIPTS_POSIX:$PATH" ;;
        esac
    else
        _eb_warn "eda-buddy command not found. Install it with:"
        _eb_warn "  pip install -e \"$_EB_ROOT/eda_buddy\""
        _eb_warn "You can still use: python -m eda_buddy ..."
    fi
fi

# ── 2. make ──────────────────────────────────────────────────────────────────
# The generated Makefile needs a POSIX shell, so Cygwin make is the right one
# even when another make is on PATH.
if [ -z "$EDA_BUDDY_MAKE" ]; then
    for _c in /c/cygwin64/bin/make.exe /c/cygwin/bin/make.exe /usr/bin/make; do
        [ -x "$_c" ] && { export EDA_BUDDY_MAKE="$(_eb_posix2win "$_c")"; break; }
    done
    [ -z "$EDA_BUDDY_MAKE" ] && command -v make >/dev/null 2>&1 && \
        export EDA_BUDDY_MAKE="$(_eb_posix2win "$(command -v make)")"
fi
[ -z "$EDA_BUDDY_MAKE" ] && _eb_warn "make not found; set EDA_BUDDY_MAKE or pass --make."

# ── 3. project ───────────────────────────────────────────────────────────────
if [ -z "$EDA_BUDDY_PROJECT_CFG" ]; then
    _EB_CFG="$_EB_ROOT/eda_buddy/project_structure.yaml"
    if [ -f "$_EB_CFG" ]; then
        export EDA_BUDDY_PROJECT_CFG="$(_eb_posix2win "$_EB_CFG")"
    else
        _eb_warn "no project_structure.yaml at $_EB_CFG; pass --project-cfg."
    fi
fi

# ── report ───────────────────────────────────────────────────────────────────
if command -v eda-buddy >/dev/null 2>&1; then
    _eb_ok "eda-buddy    $(eda-buddy --version 2>&1 | tail -1)"
else
    _eb_warn "eda-buddy    not on PATH (use: python -m eda_buddy)"
fi
_eb_ok "make         ${EDA_BUDDY_MAKE:-<unset>}"
_eb_ok "project      ${EDA_BUDDY_PROJECT_CFG:-<unset>}"
echo   "             try: eda-buddy run sanity_regression --comp axi_stream_master_vip -j 3"

unset _EB_HERE _EB_ROOT _EB_PY _EB_SCRIPTS _EB_SCRIPTS_POSIX _EB_CFG _c
unset -f _eb_win2posix _eb_posix2win _eb_warn _eb_ok
