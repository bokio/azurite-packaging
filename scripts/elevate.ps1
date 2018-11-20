function RecreateArg($key, $value) {
    [string]$k = $key
    [string]$v = $value
    if ($value.GetType().Name -eq 'SwitchParameter') {
        # switch params are special
        if ($value) {
            return "-${k}"
        }
        else {
            return "-${k}:0"
        }
    }
    return @("-${k}", $v)
}

function RecreateArgsList($invocation) {
    # https://rkeithhill.wordpress.com/2013/04/05/powershell-script-that-relaunches-as-admin/
    [string[]]$argList = $invocation.BoundParameters.GetEnumerator() | ForEach-Object { RecreateArg $_.Key $_.Value }
    $argList += $invocation.UnboundArguments
    return $argList
}

function Is-Elevated() {
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    return $myWindowsPrincipal.IsInRole($adminRole)
}

function Run-Elevated($script, $invocation) {

    if (!(Is-Elevated)) {
        [string[]]$argList = @('-File', $script)
        $argList += RecreateArgsList $invocation
        # Re-launch elevated
        Start-Process PowerShell.exe -verb Runas -ArgumentList $argList -Wait -ErrorAction Continue
        return $true
    }

    return $false
}