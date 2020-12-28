Function Get-ExPerfwiz {
        <#
 
    .SYNOPSIS
    Get information about a data collector set.

    .DESCRIPTION
    Gets information about a data collector set on the local or remote server.

    .PARAMETER Name
    Name of the Data Collector set

    Default ExPerfwiz

    .PARAMETER Server
    Name of the server

    Default LocalHost

    .PARAMETER Quiet
    Suppresses output to the screen

	.OUTPUTS
    Logs all activity into $env:LOCALAPPDATA\ExPefwiz.log file 
	
    .EXAMPLE
    Get info on the default collector set

    Get-ExPerfwiz

    .EXAMPLE
    Get info on a collector set on a remote server

    Get-ExPerfwiz -Name "My Collector Set" -Server RemoteServer-01

    #>
    param (
        [string]
        $Name = "Experfwiz",

        [string]
        $Server = $env:ComputerName,

        [switch]
        $Quiet = $false
    )
    
    Out-LogFile -string ("Getting ExPerfwiz: " + $server) -quiet $Quiet
    
    # Get the experfwiz counter set
    $logman = logman query -name $Name -s $server

    # Convert it to something that will look better in the log file / screen
    # $formatlogman = $logman -join "`n`r" | out-string

    # Now convert $logman to a string
    # [string]$logman = $logman

    # Convert the output of logman into an object
    $logmanObject = New-Object -TypeName PSObject
    
    foreach ($line in $logman){

        $linesplit = $line.split(":").trim()

        switch (($linesplit)[0]) {
            Name {$logmanObject | Add-Member -MemberType NoteProperty -Name $linesplit[0] -Value $linesplit[1] -Force}
            Status {$logmanObject | Add-Member -MemberType NoteProperty -Name $linesplit[0] -Value $linesplit[1]}
            'Root Path' {$logmanObject | Add-Member -MemberType NoteProperty -Name "RootPath" -Value (resolve-path ($linesplit[1] + ":" + $linesplit[2]))}
            Segment {$logmanObject | Add-Member -MemberType NoteProperty -Name $linesplit[0] -Value $linesplit[1]}
            Schedules {$logmanObject | Add-Member -MemberType NoteProperty -Name $linesplit[0] -Value $linesplit[1]}
            'Segment Max Duration' {$logmanObject | Add-Member -MemberType NoteProperty -Name "Duration" -Value (New-TimeSpan -Seconds ([int]($linesplit[1].split(" "))[0]))}
            'Segment Max Size' {$logmanObject | Add-Member -MemberType NoteProperty -Name 'MaxSize' -Value (($linesplit[1].replace(" ",""))/1MB) }
            'Run As' {$logmanObject | Add-Member -MemberType NoteProperty -Name "RunAs" -Value $linesplit[0]}
            'Start Date' {$logmanObject | Add-Member -MemberType NoteProperty -Name "StartDate" -Value $linesplit[1]}
            'Start Time'  {$logmanObject | Add-Member -MemberType NoteProperty -Name "StartTime" -Value ($line.split(" ")[-2] + " " + $line.split(" ")[-1])}
            'End Date' {$logmanObject | Add-Member -MemberType NoteProperty -Name "EndDate" -Value $linesplit[1]}
            'Days'   {$logmanObject | Add-Member -MemberType NoteProperty -Name "Days" -Value $linesplit[1]}
            # Name:                 ExPerfwiz\ExPefwiz
            'Type' {$logmanObject | Add-Member -MemberType NoteProperty -Name "Type" -Value $linesplit[1]}
            'Append' {$logmanObject | Add-Member -MemberType NoteProperty -Name "Append" -Value (Convert-OnOffBool($linesplit[1]))}
            'Circular' {$logmanObject | Add-Member -MemberType NoteProperty -Name "Circular" -Value (Convert-OnOffBool($linesplit[1]))}
            'Overwrite' {$logmanObject | Add-Member -MemberType NoteProperty -Name "Overwrite" -Value (Convert-OnOffBool($linesplit[1]))}
            'Sample Interval' {$logmanObject | Add-Member -MemberType NoteProperty -Name "SampleInterval" -Value (($linesplit[1].split(" "))[0])}
            Default {}
        }

    }

    # Check if we have an error and throw and error if needed.
    If ([string]::isnullorempty(($logman | select-string "Error:"))) {
        Return $logmanObject
    }
    elseif([bool]($logman | Select-String "data collector set was not found")){
        # since we got the data collector set was not found do nothing
    }
    else {
        Out-LogFile "[ERROR] - Unable to Get collector" -quiet $Quiet
        Out-LogFile $logman -quiet $Quiet
        Throw $logman
    }
}