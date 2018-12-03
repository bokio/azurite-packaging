param(
    [Parameter(Mandatory)]
    [string]$datadir,
    [switch]$visible,
    [int]$startPort = 10000
)

function Resolve-PathBetter([string]$path) {
    return  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

Push-Location $PSScriptRoot 

Try {
    [string]$fulldatadir = Resolve-PathBetter $datadir
    [string]$bindir = Resolve-PathBetter "../node_modules/.bin" # yarn creates this for us
    [string]$pidfile = Resolve-PathBetter "./azurite.pid"

    # Assume caller hasn't checked that the process isn't already running
    if (Test-Path $pidfile) {
        ./stop.ps1
    }

    if (Test-Path $pidfile) {
        Write-Host "pidfile still exists at $pidfile. Remove manually to continue."
        exit 2
    }

    $azuritebin = "${bindir}/azurite"
    $azuriteargs = @(
        "-l", """$fulldatadir""",
        "--blobPort", $startPort,
        "--queuePort", ($startPort+1),
        "--tablePort", ($startPort+2)
    )

    $winstyle="Hidden"
    if ($visible) {
        $winstyle="Normal"
    }
    $p = Start-Process -FilePath $azuritebin -ArgumentList $azuriteargs -passthru -WindowStyle $winstyle

    Write-Host "Started Azurite"
    $connStr="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;
    AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;
    BlobEndpoint=http://127.0.0.1:$($startPort)/devstoreaccount1;
    TableEndpoint=http://127.0.0.1:($startPort+2)/devstoreaccount1;
    QueueEndpoint=http://127.0.0.1:($startPort+1)/devstoreaccount1;
    "

    $p.Id >$pidfile
    return $connStr
}
Finally {
    Pop-Location
}
