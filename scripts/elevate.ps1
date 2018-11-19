
function Run-Elevated($script, $invocation) {
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    if (!$myWindowsPrincipal.IsInRole($adminRole)) {
        # https://rkeithhill.wordpress.com/2013/04/05/powershell-script-that-relaunches-as-admin/
        [string[]]$argList = @('-File', $script)
        $argList += $invocation.BoundParameters.GetEnumerator() | ForEach-Object {"-$($_.Key)", "$($_.Value)"}
        $argList += $invocation.UnboundArguments

        # Re-launch elevated
        Start-Process PowerShell.exe -verb Runas -ArgumentList $argList -Wait -ErrorAction Continue
        return $true
    }

    return $false
}