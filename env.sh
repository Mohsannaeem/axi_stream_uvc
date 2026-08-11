#!/usr/bin/env bash
# EDA Buddy environment — Git Bash / Cygwin.
#   . ./env.sh        <- source it; executing it would set PATH in a child shell
#
# Override any value by exporting it before sourcing.

# Executing this instead of sourcing it sets PATH in a child shell that exits
# immediately, so the parent shell is left with nothing — and the version line
# below still prints, making it look like it worked. Fail loudly instead.
# This also catches `. .\env.sh` from PowerShell, which hands the file to bash
# as a subprocess.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "[env] env.sh must be SOURCED, not executed." >&2
    echo "[env]   bash/Cygwin :  . ./env.sh" >&2
    echo "[env]   PowerShell  :  . .\\env.ps1     (env.ps1, not env.sh)" >&2
    exit 1
fi

_here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# eda-buddy's console script (eda-buddy.exe on a Windows Store Python) is often not
# on PATH by default, so add its Scripts dir — but only as a guarded fallback:
#   • if eda-buddy is ALREADY runnable (a system/venv install, or a CI-provisioned
#     one), leave PATH alone so we don't shadow it with a per-user path;
#   • only prepend the dir when it actually EXISTS, so a dev-machine default is
#     harmless on other machines / CI agents.
# Override the dir with EDA_BUDDY_BIN. The default below is a dev-machine convenience.
if ! command -v eda-buddy >/dev/null 2>&1; then
    _bin="${EDA_BUDDY_BIN:-C:/Users/Lenovo/AppData/Local/Packages/PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0/LocalCache/local-packages/Python312/Scripts}"
    _binu="$(cygpath -u "$_bin" 2>/dev/null || echo "$_bin")"
    [ -d "$_binu" ] && export PATH="$_binu:$PATH"
    unset _bin _binu
fi

# make is not on PATH on this machine; EDA Buddy shells out to it to execute
# the generated Makefile, so it has to be told where it lives.
# Windows-form paths: eda-buddy runs on native Python, which cannot open /d/...
export EDA_BUDDY_MAKE="${EDA_BUDDY_MAKE:-C:/cygwin64/bin/make.exe}"
export EDA_BUDDY_PROJECT_CFG="${EDA_BUDDY_PROJECT_CFG:-$(cygpath -m "$_here/project_structure.yaml")}"

unset _here

# Friendly confirmation banner. Must NEVER be fatal: env.sh is commonly sourced under
# `set -e` (e.g. CI), and eda-buddy can be present-but-not-runnable in some
# environments — e.g. a per-user Windows Store Python invoked by a service /
# LocalSystem account — where a hard failure here would abort the whole sourcing.
# Skip it when eda-buddy isn't runnable, and swallow any non-zero exit.
if command -v eda-buddy >/dev/null 2>&1; then
    eda-buddy --version || true
fi
