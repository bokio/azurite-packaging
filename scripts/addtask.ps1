param(
    [Parameter(Mandatory)]
    [string]$taskname,
    [Parameter(Mandatory)]
    [string]$datadir,
    [switch]$atlogon,
    [switch]$atstartup
)

. (Join-Path $PSScriptRoot "elevate.ps1")

if (Run-Elevated $PSCommandPath $MyInvocation) {
    # This script was already run in an elevated prompt (we can't tell if it failed)
    return
}

function New-AzuriteTask() {
    Push-Location $PSScriptRoot 

    [string]$fulldatadir = Resolve-Path $datadir
    [string]$bindir = Resolve-Path "../node_modules/.bin" # yarn creates this for us
    $user = whoami

    $A = New-ScheduledTaskAction -Execute "azurite" -Argument "-l ""$fulldatadir""" -WorkingDirectory $bindir
    $triggers = @()
    if ($atlogon) {
        $triggers += New-ScheduledTaskTrigger -AtLogOn -User $user
    }
    if ($atstartup) {
        $triggers += New-ScheduledTaskTrigger -AtStartup
    }
    $S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
    $P = New-ScheduledTaskPrincipal -UserId $user -LogonType S4U # S4U is the "Don't save password" option

    $taskParams=@{
        TaskName=$taskname;
        Action=$A;
        Trigger=$triggers;
        Settings=$S;
        Principal=$P;
    }

    $task=Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue
    if (!$task) {
        Write-Host "Creating task $taskname"
        $task = Register-ScheduledTask @taskParams
    }
    else {
        Write-Host "Modifying task $taskname"
        Set-ScheduledTask -TaskPath $task.TaskPath @taskParams 
    }

    Pop-Location
}

New-AzuriteTask