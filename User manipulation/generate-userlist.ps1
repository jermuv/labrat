param ($FirstFile, $LastFile, $count)

if ($count.length -eq 0) { $count = 10 }
$canproceed=$true

#region checking parameteres
# checking if parameters are valid
if ($FirstFile.length -eq 0) {
    write-host "Parameter -firstfile <filename> needed"
    $canproceed=$false
}

if ($LastFile.length -eq 0) {
    write-host "Parameter -lastfile <filename> needed"
    $canproceed=$false
}
#endregion (checking parameteres)

if (!($canproceed)) { write-host "Usage: .\generate-userlist.ps1 -firstfile <filename> -lastfile <filename> -count 10" }

#region checking if files exists
if ($canproceed) {
    write-host "proceeding..."
    if (!(test-path -path $FirstFile)) {
        write-host "Firstfile not found"
        $canproceed=$false
    }
    if (!(test-path -path $LastFile)) {
        write-host "lastfile not found"
        $canproceed=$false
    }
}
#endregion checking if files..

$a = 0
do {
    $a = $a+1
    write-output "$a"
} while ($a -le $count-1)