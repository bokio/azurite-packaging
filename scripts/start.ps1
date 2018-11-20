param(
    [Parameter(Mandatory)]
    [string]$datadir,
    [switch]$visible
)

Push-Location $PSScriptRoot 

function Resolve-PathBetter([string]$path) {
    return  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

[string]$fulldatadir = Resolve-PathBetter $datadir
[string]$bindir = Resolve-PathBetter "../node_modules/.bin" # yarn creates this for us
[string]$pidfile = Resolve-PathBetter "./azurite.pid"

# Assume caller has checked that the process isn't already running
Remove-Item -path $pidfile -force 2>$null -ErrorAction SilentlyContinue
$azuritebin = "${bindir}/azurite"
$azuriteargs = @("-l", """$fulldatadir""")

$winstyle="Hidden"
if ($visible) {
    $winstyle="Normal"
}
$p = Start-Process -FilePath $azuritebin -ArgumentList $azuriteargs -passthru -WindowStyle $winstyle

Pop-Location

Write-Host "Started Azurite"
$p.Id >$pidfile
return $p
