#Function which builds HTML report
#
# Contains CSS for formatting results into tables
#
# Accepts the following mandatory params:
#	$Name = Name of report
#	$Path = Path of report
#	$Contents = HTML objects to be reported on. Each will have their own table in report
#
# Output report includes its creation date as well as machine it was run on.
# Output report name is in format yyyy-MM-dd_HH-mm_<Name>.html
#
#
# Version: 0.1
# Date: 23-JUN-21
#

function New-Report {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory,ValueFromPipeline)]
		[string]$Name,

		[Parameter(Mandatory,ValueFromPipeline)]
		[string]$Path,

		[Parameter(Mandatory,ValueFromPipeline)]
		[string[]]$Contents
	)

#Consider replacing CSS below with a call to an external file
$header = @"
<style>

    h1 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 28px;
    }    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;
    }
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}
    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
}
</style>
"@
		
$Title ="<h1>$Name</h1>"
$Date = "<h2>Creation Date: $(Get-Date)</h2>"
$ComputerName = "<h2>Computer name: $env:computername</h2>"
$FileName = $(Get-Date).ToString("yyyy-MM-dd_HH-mm")+"_$Name"+".html"
$report = ConvertTo-HTML -body "$Title $Date $ComputerName $Contents" -Head $header
$report | Out-File -FilePath $Path$FileName
}
