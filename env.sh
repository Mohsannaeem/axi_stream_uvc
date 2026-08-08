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

# Where pip installed eda-buddy.exe. Not on PATH by default on a Windows Store
# Python. Override with EDA_BUDDY_BIN for a different interpreter or a venv.
_bin="${EDA_BUDDY_BIN:-C:/Users/Lenovo/AppData/Local/Packages/PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0/LocalCache/local-packages/Python312/Scripts}"
export PATH="$(cygpath -u "$_bin"):$PATH"

# make is not on PATH on this machine; EDA Buddy shells out to it to execute
# the generated Makefile, so it has to be told where it lives.
# Windows-form paths: eda-buddy runs on native Python, which cannot open /d/...
export EDA_BUDDY_MAKE="${EDA_BUDDY_MAKE:-C:/cygwin64/bin/make.exe}"
export EDA_BUDDY_PROJECT_CFG="${EDA_BUDDY_PROJECT_CFG:-$(cygpath -m "$_here/project_structure.yaml")}"

unset _here _bin
eda-buddy --version
