# EDA Buddy environment - PowerShell.
#   . .\env.ps1       <- dot-source it; running it would set PATH in a child scope
#
# Override any value by setting it before dot-sourcing.

# Where pip installed eda-buddy.exe. Not on PATH by default on a Windows Store
# Python. Override with EDA_BUDDY_BIN for a different interpreter or a venv.
$bin = if ($env:EDA_BUDDY_BIN) { $env:EDA_BUDDY_BIN } else {
    'C:\Users\Lenovo\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts'
}
$env:PATH = "$bin;$env:PATH"

# make is not on PATH on this machine; EDA Buddy shells out to it to execute
# the generated Makefile, so it has to be told where it lives.
if (-not $env:EDA_BUDDY_MAKE)        { $env:EDA_BUDDY_MAKE = 'C:\cygwin64\bin\make.exe' }
if (-not $env:EDA_BUDDY_PROJECT_CFG) { $env:EDA_BUDDY_PROJECT_CFG = Join-Path $PSScriptRoot 'project_structure.yaml' }

Remove-Variable bin
eda-buddy --version
