function Add-RebootJob {
    [CmdletBinding()]

    #requires -version 3

    param (
        [Parameter(
            Position=0,
            ParameterSetName="AsScriptBlock"
        )]
        [scriptblock]$PSScriptBlock,

        [Parameter(
            Position=0,
            ParameterSetName="AsRawJob"
        )]
        [string]$Execute,
        [Parameter(
            Position=1,
            ParameterSetName="AsRawJob"
        )]
        [string]$Argument

    )

    Begin {
        Write-Verbose "[Add-RebootJob] - Starting..."
        $isScriptBlock = $false
        $isRaw = $false
        if ($PSCmdlet.ParameterSetName -eq "AsScriptBlock") {$isScriptBlock = $true;Write-Verbose "[Add-RebootJob] - Defined PS Script Block"}
        if ($PSCmdlet.ParameterSetName -eq "AsRawJob") {$isRaw = $true;Write-Verbose "[Add-RebootJob] - Defined Raw Command"}
    }

    Process {
        $description = "This job was created with 'Add-RebootJob' using the toolset from NRException, Documentation can be found here: https://github.com/NRException/PSRunAfterReboot. If this machine has rebooted since this task was created, you may delete it :)"

        if($isScriptBlock) {
            $jobName = ("RJ-S-{0}" -f (New-Guid))
            Write-Verbose ("[Add-RebootJob] - Calculated job name is {0}" -f $jobName)
            Write-Verbose "[Add-RebootJob] - Creating script job..."
            Write-Verbose ("[Add-RebootJob] - Parameter Set: 0: -Execute powershell.exe 1: -Command '-ScriptBlock {0}'" -f ($PSScriptBlock))

            #Define Task parameters, inject auto delete action.
            $a = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-Command `"{0}`"" -f ($PSScriptBlock))
            $ab = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-Command `"{0}`"" -f ("Unregister-ScheduledTask -TaskName '$jobName' -Confirm:{0}") -f '$false')
            $t = New-ScheduledTaskTrigger -AtStartup
            $tf = Register-ScheduledTask -Action @($a,$ab) -Trigger $t -TaskName $jobName -Description $description -RunLevel Highest

            #Return
            Write-Output ([PSCustomObject]@{
                TaskName=$tf.TaskName
                State=$tf.State
            })
        } elseif ($isRaw) {
            $jobName = ("RJ-C-{0}" -f (New-Guid))
            Write-Verbose ("[Add-RebootJob] - Calculated job name is {0}" -f $jobName)
            Write-Verbose "[Add-RebootJob] - Creating raw command job..."
            Write-Verbose ("[Add-RebootJob] - Parameter Set: -Execute: {0} -Argument {1}" -f $Execute, $Argument)

            #Define Task parameters, inject auto delete action.
            $a = New-ScheduledTaskAction -Execute $Execute -Argument $Argument
            $ab = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-Command `"{0}`"" -f ("Unregister-ScheduledTask -TaskName '$jobName' -Confirm:{0}") -f '$false')
            $t = New-ScheduledTaskTrigger -AtStartup
            $tf = Register-ScheduledTask -Action @($a,$ab) -Trigger $t -TaskName $jobName -Description $description -RunLevel Highest

            #Return
            Write-Output ([PSCustomObject]@{
                TaskName=$tf.TaskName
                State=$tf.State
            })
        }
    }

    End {
        Write-Verbose "[Add-RebootJob] - Exiting..."
    }
}

function Remove-RebootJob {
    [CmdletBinding()]

    #requires -version 3

    param (
        [Parameter(
            Position=0
        )]
        [string]$TaskName

    )

    Begin {
        Write-Verbose "[Remove-RebootJob] - Starting..."
        if($TaskName -contains "RJ-S") {Write-Verbose "Looking for Script Block reboot job..."}
        if($TaskName -contains "RJ-C") {Write-Verbose "Looking for file reboot job..."}
    }

    Process {
        Unregister-ScheduledTask -TaskName $TaskName
    }

    End {
        Write-Verbose "[Remove-RebootJob] - Exiting..."
    }
}

function Get-RebootJob {
    [CmdletBinding()]

    #requires -version 3

    param (

    )

    Begin {
        Write-Verbose "[Get-RebootJob] - Starting..."
    }

    Process {
        $schtask = Get-ScheduledTask | Where-Object {$_.TaskName -match "RJ-"}
        foreach ($t in $schtask) {
            $tasktype = $null
            if($t.TaskName -match "RJ-S") {
                $tasktype = "ScriptBlock"
            } elseif ($t.TaskName -match "RJ-C") {
                $tasktype = "RawCommand"
            } else {
                $tasktype = "Unknown"
            }

            Write-Output ([PSCustomObject]@{
                TaskName = $t.TaskName
                State = $t.State
                Type = $tasktype
            })
        }
    }

    End {
        Write-Verbose "[Get-RebootJob] - Exiting..."
    }
}

Export-ModuleMember -Function 'Add-RebootJob'
Export-ModuleMember -Function 'Remove-RebootJob'
Export-ModuleMember -Function 'Get-RebootJob'