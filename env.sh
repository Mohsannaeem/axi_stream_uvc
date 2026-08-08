#!/usr/bin/env bash
# EDA Buddy environment — Git Bash / Cygwin.
#   . ./env.sh        <- source it; executing it would set PATH in a child shell
#
# Override any value by exporting it before sourcing.

_here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
_eda="$_here/../eda_buddy"

# Windows-form paths throughout: eda-buddy runs on native Python, which cannot
# open /d/... — and native Python splits PYTHONPATH on ';', not ':'.
export PYTHONPATH="$(cygpath -m "$_eda/src")${PYTHONPATH:+;$PYTHONPATH}"

# `eda-buddy` as a shell function rather than a PATH entry: it needs no pip
# install of EDA Buddy itself, and always runs the source in ../eda_buddy rather
# than whichever copy pip happened to install elsewhere.
# The dependencies are still needed once:  pip install pyyaml requests
eda-buddy() { python -m eda_buddy "$@"; }

# make is not on PATH on this machine; EDA Buddy shells out to it to execute
# the generated Makefile, so it has to be told where it lives.
export EDA_BUDDY_MAKE="${EDA_BUDDY_MAKE:-C:/cygwin64/bin/make.exe}"
export EDA_BUDDY_PROJECT_CFG="${EDA_BUDDY_PROJECT_CFG:-$(cygpath -m "$_here/project_structure.yaml")}"

unset _here _eda
eda-buddy --version
