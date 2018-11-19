param(
    [Parameter(Mandatory)]
    [string]$taskname
)

. (Join-Path $PSScriptRoot "elevate.ps1")

if (Run-Elevated $PSCommandPath $MyInvocation) {
    # This script was already run in an elevated prompt (we can't tell if it failed)
    return
}

$task=Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false -ErrorAction Continue
    Write-Output "The task $taskname was removed"
}
else {
    Write-Output "The task $taskname could not be found"
}

