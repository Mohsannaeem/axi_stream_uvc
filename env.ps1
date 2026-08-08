# EDA Buddy environment - PowerShell.
#   . .\env.ps1       <- dot-source it; running it would set PATH in a child scope
#
# Override any value by setting it before dot-sourcing.

# Where pip put the eda-buddy command. Asked of Python because it differs
# between a user install, a venv and a system install.
$scripts = python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))"
$env:PATH = "$scripts;$env:PATH"

if (-not $env:EDA_BUDDY_MAKE)        { $env:EDA_BUDDY_MAKE = 'C:\cygwin64\bin\make.exe' }
if (-not $env:EDA_BUDDY_PROJECT_CFG) { $env:EDA_BUDDY_PROJECT_CFG = Join-Path $PSScriptRoot 'project_structure.yaml' }

Remove-Variable scripts
eda-buddy --version
