function Resolve-PathBetter([string]$path) {
    return  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

Push-Location $PSScriptRoot 

[string]$pidfile = Resolve-PathBetter "./azurite.pid"
if (Test-Path $pidfile) {
    $processid = (Get-Content $pidfile).Trim()
    taskkill /PID $processid
    Remove-Item $pidfile
}

Pop-Location
