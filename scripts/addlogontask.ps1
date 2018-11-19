param(
    [Parameter(Mandatory)]
    [string]$taskname,
    [Parameter(Mandatory)]
    [string]$datadir
)

. (Join-Path $PSScriptRoot "elevate.ps1")

if (Run-Elevated $PSCommandPath $MyInvocation) {
    # This script was already (attempted to) run in an elevated prompt
    return
}

function New-AzuriteTask() {
    Push-Location $PSScriptRoot 

    # https://www.vistax64.com/threads/cmdlet-using-getresolvedproviderpathfrompspath-vs-getunresolvedproviderpathfrompspath.16340/
    # This is beyond stupid
    $fulldatadir = $executionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($datadir)
    $bindir = $executionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("../node_modules/.bin")

    $A = New-ScheduledTaskAction -Execute "azurite" -Argument "-l ""$fulldatadir""" -WorkingDirectory $bindir
    $T = New-ScheduledTaskTrigger -AtLogOn -User $(whoami)
    $S = New-ScheduledTaskSettingsSet -Hidden 
    $P = New-ScheduledTaskPrincipal -UserId "LOCALSERVICE" -LogonType ServiceAccount
    #$P = New-ScheduledTaskPrincipal -UserId $(whoami) -LogonType Password

    $task=Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue

    if (!$task) {
        Write-Host "Creating task $taskname"
        $task = Register-ScheduledTask -TaskName $taskname -Action $A -Trigger $T -Settings $S -Principal $P
    }
    else {
        Write-Host "Modifying task $taskname"
        Set-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Action $A -Trigger $T -Settings $S -Principal $P
    }

    Pop-Location
}

New-AzuriteTask