function Resolve-PathBetter([string]$path) {
    return  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

Push-Location $PSScriptRoot 

[string]$pidfile = Resolve-PathBetter "./azurite.pid"
if (Test-Path $pidfile) {
    $processid = (Get-Content $pidfile).Trim()
    taskkill /T /F /PID $processid # it's beyond me that powershell doesn't ship with a cmdlet that lets you kill a process with its children
    Remove-Item $pidfile
}

Pop-Location
