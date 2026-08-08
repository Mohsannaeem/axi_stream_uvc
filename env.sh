#!/usr/bin/env bash
# EDA Buddy environment — Git Bash / Cygwin.
#   . ./env.sh        <- source it; executing it would set PATH in a child shell
#
# Override any value by exporting it before sourcing.

_root="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# Where pip put the eda-buddy command. Asked of Python because it differs
# between a user install, a venv and a system install.
_scripts="$(python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))")"
export PATH="$(cygpath -u "$_scripts"):$PATH"

# Windows-form paths: eda-buddy runs on native Python, which cannot open /d/...
export EDA_BUDDY_MAKE="${EDA_BUDDY_MAKE:-C:/cygwin64/bin/make.exe}"
export EDA_BUDDY_PROJECT_CFG="${EDA_BUDDY_PROJECT_CFG:-$(cygpath -m "$_root/eda_buddy/project_structure.yaml")}"

unset _root _scripts
eda-buddy --version
