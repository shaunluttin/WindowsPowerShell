# Credit to Briantist of StackOverflow
# http://stackoverflow.com/questions/28663968/run-command-without-adding-it-to-the-history#28664171

function Skip-History {
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

Export-ModuleMember No-History