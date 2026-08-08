# EDA Buddy environment - PowerShell.
#
#   . .\env.ps1         (dot-source it; running it as .\env.ps1 sets the
#                        variables in a child scope that dies immediately)
#
# Sets up, for this session only:
#   PATH                   + the directory holding the `eda-buddy` command
#   EDA_BUDDY_MAKE         make executable, since make is usually not on PATH
#   EDA_BUDDY_PROJECT_CFG  so commands work from any directory
#
# Everything is derived from this script's own location, so a fresh clone on
# another machine needs no edits. Pre-set any variable to override it.

$ErrorActionPreference = 'Continue'

# $PSScriptRoot is the script's directory even when dot-sourced.
$ebHere = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$ebRoot = Split-Path -Parent $ebHere

function Write-EbOk   { param($m) Write-Host "[env] $m" -ForegroundColor Green }
function Write-EbWarn { param($m) Write-Host "[env] $m" -ForegroundColor Yellow }

# -- 1. put the eda-buddy command on PATH ------------------------------------
# Ask Python where console scripts land rather than hardcoding a path: the
# answer differs between a user install, a venv, and a system install.
$ebPython = if ($env:EDA_BUDDY_PYTHON) { $env:EDA_BUDDY_PYTHON } else { 'python' }

if (-not (Get-Command $ebPython -ErrorAction SilentlyContinue)) {
    Write-EbWarn "python not found on PATH; set EDA_BUDDY_PYTHON to your interpreter."
} else {
    $probe = @'
import os, sysconfig
seen = []
for scheme in ("nt_user", "nt", None):
    try:
        p = sysconfig.get_path("scripts") if scheme is None else sysconfig.get_path("scripts", scheme)
    except Exception:
        continue
    if p and p not in seen:
        seen.append(p)
for p in seen:
    if any(os.path.exists(os.path.join(p, n)) for n in ("eda-buddy.exe", "eda-buddy")):
        print(p)
        break
'@
    $ebScripts = ($probe | & $ebPython - 2>$null | Select-Object -First 1)

    if ($ebScripts) {
        $ebScripts = $ebScripts.Trim()
        if (($env:PATH -split ';') -notcontains $ebScripts) {
            $env:PATH = "$ebScripts;$env:PATH"
        }
    } else {
        Write-EbWarn "eda-buddy command not found. Install it with:"
        Write-EbWarn "  pip install -e `"$ebRoot\eda_buddy`""
        Write-EbWarn "You can still use: python -m eda_buddy ..."
    }
}

# -- 2. make -----------------------------------------------------------------
# The generated Makefile needs a POSIX shell, so Cygwin make is the right one
# even when another make is on PATH.
if (-not $env:EDA_BUDDY_MAKE) {
    foreach ($c in @('C:\cygwin64\bin\make.exe', 'C:\cygwin\bin\make.exe', 'C:\msys64\usr\bin\make.exe')) {
        if (Test-Path $c) { $env:EDA_BUDDY_MAKE = $c; break }
    }
    if (-not $env:EDA_BUDDY_MAKE) {
        $onPath = Get-Command make -ErrorAction SilentlyContinue
        if ($onPath) { $env:EDA_BUDDY_MAKE = $onPath.Source }
    }
}
if (-not $env:EDA_BUDDY_MAKE) { Write-EbWarn "make not found; set EDA_BUDDY_MAKE or pass --make." }

# -- 3. project --------------------------------------------------------------
if (-not $env:EDA_BUDDY_PROJECT_CFG) {
    $ebCfg = Join-Path $ebRoot 'eda_buddy\project_structure.yaml'
    if (Test-Path $ebCfg) {
        $env:EDA_BUDDY_PROJECT_CFG = $ebCfg
    } else {
        Write-EbWarn "no project_structure.yaml at $ebCfg; pass --project-cfg."
    }
}

# -- report ------------------------------------------------------------------
if (Get-Command eda-buddy -ErrorAction SilentlyContinue) {
    Write-EbOk ("eda-buddy    " + (eda-buddy --version))
} else {
    Write-EbWarn "eda-buddy    not on PATH (use: python -m eda_buddy)"
}
$mk = if ($env:EDA_BUDDY_MAKE) { $env:EDA_BUDDY_MAKE } else { '<unset>' }
$pc = if ($env:EDA_BUDDY_PROJECT_CFG) { $env:EDA_BUDDY_PROJECT_CFG } else { '<unset>' }
Write-EbOk "make         $mk"
Write-EbOk "project      $pc"
Write-Host "             try: eda-buddy run sanity_regression --comp axi_stream_master_vip -j 3"

Remove-Variable ebHere, ebRoot, ebPython, ebScripts, ebCfg, probe, mk, pc, c, onPath -ErrorAction SilentlyContinue
