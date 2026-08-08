# EDA Buddy environment - PowerShell.
#   . .\env.ps1       <- dot-source it; running it would set PATH in a child scope
#
# Override any value by setting it before dot-sourcing.

$eda = Join-Path (Split-Path -Parent $PSScriptRoot) 'eda_buddy'

$env:PYTHONPATH = if ($env:PYTHONPATH) { "$eda\src;$env:PYTHONPATH" } else { "$eda\src" }

# `eda-buddy` as a function rather than a PATH entry: it needs no pip install of
# EDA Buddy itself, and always runs the source in ..\eda_buddy rather than
# whichever copy pip happened to install elsewhere.
# The dependencies are still needed once:  pip install pyyaml requests
function global:eda-buddy { python -m eda_buddy @args }

# make is not on PATH on this machine; EDA Buddy shells out to it to execute
# the generated Makefile, so it has to be told where it lives.
if (-not $env:EDA_BUDDY_MAKE)        { $env:EDA_BUDDY_MAKE = 'C:\cygwin64\bin\make.exe' }
if (-not $env:EDA_BUDDY_PROJECT_CFG) { $env:EDA_BUDDY_PROJECT_CFG = Join-Path $PSScriptRoot 'project_structure.yaml' }

Remove-Variable eda
eda-buddy --version
