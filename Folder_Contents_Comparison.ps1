# Function which compares contents of files in two folders.
# The compared files must have the same filename.
# Returns all files, whether they're identical or not.
# If found, returns all differences between files with same filename. This is done using the SideIndicator. 
#
# Accepts the following mandatory params:
#	$folder1 = Path and filename of first folder for comparison
#	$folder2 = Path and filename of second folder for comparison
#
# Usage: 
#   Get-FileDiff 'C:\dev\baseline' 'C:\dev\conf'
#
#
# Version: 0.1
# Date: 15-JUL-21
#

function Get-FileDiff {

#NB - Parts of this had to be commented out as variables not read in correctly when written as an 'advanced function'

	#[CmdletBinding()]
	param(
	#	[Parameter(Mandatory)]
		$folder1,

	#	[Parameter(Mandatory)]
		$folder2

	)

#$folder1 =  "C:\dev\baseline"
#$folder2  = "C:\dev\conf"


# Stop execution if either folder is empty or non-existant.
if (-not(Test-Path $folder1)) {

    Write-Error -Message "First folder given doesn't exist. Aborting" -ErrorAction Stop

}

if (-not(Test-Path $folder2)) {

    Write-Error -Message "Second folder given doesn't exist. Aborting" -ErrorAction Stop

}


if ((gci -path $folder1).Length -eq '0') {
    
    Write-Error -Message "First folder given is empty. Aborting" -ErrorAction Stop
}

if ((gci -path $folder2).Length -eq '0') {
    
    Write-Error -Message "Second folder given is empty. Aborting" -ErrorAction Stop
}




# Get all files under $folder1, filter out directories
    $firstFolder = Get-ChildItem -Recurse $folder1 | Where-Object { -not $_.PsIsContainer }


write-host "Output from comparison of files in" $folder1 "and" $folder2":" -ForegroundColor Yellow
write-host "'<=' means data found in" $folder1 "files only. '=>' means data found in" $folder2 "files only" -ForegroundColor Yellow
write-host "----------------------------------------------------------------------------------------------------`n" -ForegroundColor Yellow

$firstFolder | ForEach-Object {

    # Check if the file, from $folder1, exists with the same path under $folder2
    If ( Test-Path ( $_.FullName.Replace($folder1, $folder2) ) ) {

        # Compare the contents of the two files...
       
        If ( Compare-Object (Get-Content $_.FullName) (Get-Content $_.FullName.Replace($folder1, $folder2) ) -casesensitive )  {

          # List the paths of the files containing diffs

          $diffs = $_.basename.Replace($folder1, $folder2)
          write-host $diffs -ForegroundColor Red

          # Show differences between files

          compare-object -ReferenceObject (get-content "$folder1\$_") -DifferenceObject (get-content "$folder2\$_") -casesensitive|Format-Table
       
           }

        #Output filename if it matches in both folders
        Else {write-host $_.BaseName "is identical in both folders `n" -ForegroundColor Green}
  
		}
        }       
    }     