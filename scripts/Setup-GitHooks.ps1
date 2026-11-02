# Installs the pre-commit hook (build check).
# Run: powershell -ExecutionPolicy Bypass -File .\scripts\Setup-GitHooks.ps1
$hookDir = Join-Path $PSScriptRoot '..\.git\hooks'
$hookFile = Join-Path $hookDir 'pre-commit'

if (-not (Test-Path $hookDir)) {
    Write-Error 'Could not find .git/hooks directory. Are you in the repository root?'
    exit 1
}

# The hook must start with '#!' in column 0, use LF line endings and have no BOM, otherwise Git cannot start it.
# Quiet output is -v:q. Do NOT use -q: for dotnet build in .NET 10 it means --question and fails whenever a target is not up to date.
$lines = @(
    '#!/bin/sh',
    'echo "========================================"',
    'echo "Running pre-commit .NET build check..."',
    'echo "========================================"',
    'dotnet build src/NetworkWatchdogService/NetworkWatchdogService.csproj -v:q -nologo',
    'if [ $? -ne 0 ]; then',
    '    echo ""',
    '    echo "BUILD FAILED! Commit aborted."',
    '    echo "Please fix the compiler errors above before committing."',
    '    exit 1',
    'fi',
    'echo "Build passed. Proceeding with commit."',
    'exit 0'
)
[System.IO.File]::WriteAllText($hookFile, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Pre-commit hook installed at $hookFile" -ForegroundColor Green