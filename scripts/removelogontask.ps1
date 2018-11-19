param(
    [Parameter(Mandatory)]
    [string]$taskname
)


$task=Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false -ErrorAction Continue
    Write-Output "The task $taskname was removed"
}
else {
    Write-Output "The task $taskname could not be found"
}

