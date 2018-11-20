param(
    [Parameter(Mandatory)]
    [string]$taskname
)

. (Join-Path $PSScriptRoot "elevate.ps1")

$task=Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue
if ($task) {
    Try {        
        if ($task.State -eq "Running") {
            $task | Stop-ScheduledTask
        }
        Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false -ErrorAction Stop
        Write-Output "The task $taskname was removed"
    }
    Catch [Microsoft.Management.Infrastructure.CimException] {
        Write-Host "Failed - trying with elevated privileges"
        if (Run-Elevated $PSCommandPath $MyInvocation) {

        }
    }
}
else {
    Write-Output "The task $taskname could not be found"
}

