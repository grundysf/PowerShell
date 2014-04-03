$ErrorActionPreference = "silentlycontinue"
Import-Module activedirectory

(Get-ADUser -Identity username –Properties MemberOf | Select MemberOf).MemberOf | Get-ADGroup -Properties ManagedBy | Select Name, ManagedBy, Distinguishedname, GroupCategory |
Where-Object {
$_.Distinguishedname -notlike "*Unity*" -and $_.Distinguishedname -notlike "*DynastyGroups*" -and $_.name -notlike "*Technical Library*" }|
ForEach-Object {
$result = New-Object PSObject
Add-Member -input $result NoteProperty 'Managed By' ((Get-ADUser -Identity $_.ManagedBy).givenName + ' ' + ((Get-ADUser -Identity $_.ManagedBy).surName))
Add-Member -input $result NoteProperty 'Group Name' $_.Name
$filter = [scriptblock]::create("distinguishedname -eq '$($_.ManagedBy)'")
$Manager = Get-ADUser -Filter $filter -Properties Mail
Add-Member -input $result NoteProperty 'Email' (Get-ADUser -Identity $_.ManagedBy -Properties mail).Mail
Add-Member -input $result NoteProperty 'Group Type' $_.GroupCategory
Write-Output $result
} | select 'Email','Group Name','Managed By','Group Type' | Export-Csv -NoTypeInformation c:\temp\output.csv