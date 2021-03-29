﻿Function Stop-ExPerfwiz {
    <#

    .SYNOPSIS
    Stop a data collector set.

    .DESCRIPTION
    Stops a data collector set on the local or remote server.

    .PARAMETER Name
    Name of the data collector set to stop.

    Default Exchange_Perfwiz

    .PARAMETER Server
    Name of the server to stop the collector set on.

    Default LocalHost

	.OUTPUTS
    Logs all activity into $env:LOCALAPPDATA\ExPefwiz.log file

    .EXAMPLE
    Stop the default data collector set on the local server

    Stop-ExPerfwiz

    .EXAMPLE
    Stop a data colletor set on a remote server

    Stop-ExPerfwiz -Name "My Collector Set" -Server RemoteServer-01

    #>
    [cmdletbinding()]
    param (
        [string]
        $Name = "Exchange_Perfwiz",

        [string]
        $Server = $env:ComputerName
    )

    Write-Logfile -string ("Stopping ExPerfwiz: " + $server)

    # Remove the experfwiz counter set
    [string]$logman = logman stop -name $Name -s $server

    # Check if we have an error and throw and error if needed.
    If ([string]::isnullorempty(($logman | select-string "Error:"))) {
        Write-Logfile "ExPerfwiz Stopped"
    }
    else {
        Write-Logfile "[ERROR] - Unable to Stop Collector"
        Write-Logfile $logman
        Throw $logman
    }
}