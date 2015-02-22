function No-History {
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$true)][Object]$obj)
    Begin {
        $history = Get-History
    }

    Process { $obj }

    End {
        Clear-History
        $history | Add-History
    }
}