param(
    [Parameter(Mandatory)]
    [string]$taskname,
    [Parameter(Mandatory)]
    [string]$datadir,
    [switch]$atlogon,
    [switch]$atstartup,
    [switch]$starttask
)

. (Join-Path $PSScriptRoot "elevate.ps1")

function New-AzuriteTask($invocation) {
    Push-Location $PSScriptRoot

    [string]$fulldatadir = Resolve-Path $datadir
    [string]$bindir = Resolve-Path "../node_modules/.bin" # yarn creates this for us
    $user = whoami

    $A = New-ScheduledTaskAction -Execute "azurite" -Argument "-l ""$fulldatadir""" -WorkingDirectory $bindir
    $logontype = "Interactive"
    $triggers = @()
    if ($atlogon) {
        $triggers += New-ScheduledTaskTrigger -AtLogOn -User $user
        $logontype = "S4U"  # S4U is the "Don't save password" option
    }
    if ($atstartup) {
        $triggers += New-ScheduledTaskTrigger -AtStartup
        $logontype = "S4U"
    }
    $S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
    $P = New-ScheduledTaskPrincipal -UserId $user -LogonType $logontype

    $taskParams=@{
        TaskName=$taskname;
        Action=$A;
        Settings=$S;
        Principal=$P;
    }
    if ($triggers.Length -gt 0) {
        $taskParams.Trigger=$triggers;
    }

    Try {
        $task=Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue
        if (!$task) {
            $task = Register-ScheduledTask @taskParams -ErrorAction Stop
            Write-Host "Created task $taskname"
        }
        else {
            Set-ScheduledTask -TaskPath $task.TaskPath @taskParams -ErrorAction Stop
            Write-Host "Modified task $taskname"
        }
    }
    Catch [Microsoft.Management.Infrastructure.CimException] {
        Write-Host "Failed - trying with elevated privileges"
        if (Run-Elevated $PSCommandPath $invocation) {

        }
    }
    Catch {
        Write-Host "Failed: $($_.Exception)}"
    }

    Pop-Location

    if ($starttask) {
        $task | Start-ScheduledTask 
    }
}

New-AzuriteTask $MyInvocation