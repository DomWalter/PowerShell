#Read in local Shared_Functions.ps1 in order to call New-Report function (won't load on FJ laptop due to restriction)
#. C:\Dev\Shared_Functions.ps1
#
#This script verifies a number of features of a device and compares them to agreed baselines (provided by external XML files)
#The result of each check is converted to HTML and passed to the New-Report function
#
#This script requires a list of software to check to be present in C:\Dev\Software.csv. This must be in format "name","version"
#This script requires a list of ports to check to be present in C:\Dev\Ports.csv. This must be in format "LocalAddress","LocalPort","RemoteAddress","RemotePort","State"
#
#
# Version: 0.1
# Date: 07-JUL-21
#
#TODO - Poss look into turning SW and port checks into functions. 

function Get-SvcAutoNoRun {
#Get automatic services which aren't running
#---------------------------------------------
$StopAutoSvcs = Get-Service |select name, starttype, status| Where {$_.starttype -eq "Automatic" -and $_.status -ne "Running"} | ForEach-Object {"$_ not running"} | ConvertTo-Html -Property @{ l='Stopped Automatic Service Check'; e={ $_ } }

return $StopAutoSvcs
}

function Get-SvcAutoRun {
#Get automatic services which are running
#--------------------------------------------
$RunAutoSvcs = Get-Service |select name, starttype, status| Where {$_.starttype -eq "Automatic" -and $_.status -eq "Running"} | ForEach-Object {"$_ running as expected"}| ConvertTo-Html -Property @{ l='Running Automatic Service Check'; e={ $_ } } 

return $RunAutoSvcs
}


#Read product name and version from CSV and compare with output from Win32_Product
#Converts output into HTML which includes some formatting
#---------------------------------------------------------
$installed = $prodlist = $BadSWResults = $GoodSWResults = $null

$installed = Get-WmiObject -Class Win32_Product

$prodlist = @(Import-CSV "C:\Dev\Software.csv")

#Splits results to allow conditional formatting in HTML report
$GoodSWResults = $prodlist|ForEach-Object {if ($installed.name -contains $_.name -and $installed.version -contains $_.version) {"$_ found"}} | ConvertTo-Html -Property @{ l='Passed Software Check'; e={ $_ }}
$BadSWResults = $prodlist|ForEach-Object {if ($installed.name -notcontains $_.name -or $installed.version -notcontains $_.version) {"$_ NOT found"}}| ConvertTo-Html -Property @{ l='Failed Software Check'; e={ $_ }}


#Read localport and state from CSV and compare with output from Get-NetTCPConnection
#Convert output into HTML which includes some formatting
#--------------------------------------------------- 
$ports = $portlist = $GoodPortResults = $BadPortResults = $null

$ports = Get-NetTCPConnection|select LocalPort,State

$portlist = @(Import-CSV "C:\Dev\ports.csv")

#Splits results to allow conditional formatting in HTML report
$GoodPortResults = $portlist|ForEach-Object {if ($ports.localport -contains $_.localport -and $ports.state -contains $_.state) {"$_ as expected"}} | ConvertTo-Html -Property @{ l='Passed Port Check'; e={ $_ }}
$BadPortResults = $portlist|ForEach-Object {if ($ports.localport -notcontains $_.localport -or $ports.state -notcontains $_.state) {"$_ NOT as expected"}}| ConvertTo-Html -Property @{ l='Failed Port Check'; e={ $_ }}

function Set-HTMLColour {

#Edits HTML based on whether a check was successful or not
#This als removes the leading '@' from each row
#
# Accepts the following mandatory params:
#	$FormatMe = Array to be formatted
#	$Result = Determines whether text will be green (Pass) or red (Fail)
#---------------------------------------------------------

[CmdletBinding()]
	param(
        
		[Parameter(Mandatory,ValueFromPipeline)]
		[string[]]$FormatMe,

        [ValidateSet(”Pass”,”Fail”)]
        [Parameter(Mandatory,ValueFromPipeline)]
		[string]$Result
    )

    if ($Result -eq 'Pass'){foreach ($Line in $FormatMe) {$Line -replace '<td>','<td style="color:#3cb371">' -replace '@',''}}
    elseif ($Result -eq 'Fail'){foreach ($Line in $FormatMe) {$Line -replace '<td>','<td style="color:#FF0000">' -replace '@',''}}

    #return $FormatMe

}

$StopAutoSvcs = Set-HTMLColour "$StopAutoSvcs" "Fail"
$RunAutoSvcs = Set-HTMLColour "$RunAutoSvcs" "Pass" 
$BadPortResults = Set-HTMLColour "$BadPortResults" "Fail"
$GoodPortResults = Set-HTMLColour "$GoodPortResults" "Pass"
$BadSWResults = Set-HTMLColour "$BadSWResults" "Fail"
$GoodSWResults = Set-HTMLColour "$GoodSWResults" "Pass"

#Calls function in Shared_Functions.ps1
New-Report "Laptop_Build_Report" "C:\Dev\" @("$StopAutoSvcs","$RunAutoSvcs","$BadSWResults","$GoodSWResults","$BadPortResults","$GoodPortResults")