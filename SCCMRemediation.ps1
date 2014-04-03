##################
#Logging
##################

$Logfile = "c:\temp\sccmStatus.log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

##################
#Firewall Status
##################

filter global:get-firewallstatus ([string]$computer = $env:computername)
	{
	if ($_) { $computer = $_ }

	$HKLM = 2147483650

	$reg = get-wmiobject -list -namespace root\default -computer $computer | where-object { $_.name -eq "StdRegProv" }
	$firewallEnabled = $reg.GetDwordValue($HKLM, "System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile","EnableFirewall")

	[bool]($firewallEnabled.uValue)
	}

$firewall = get-firewallstatus

$firewall

LogWrite $firewall

##################
#Site Code Check
##################

$SiteCode = Get-ItemProperty -Path 'hklm:SOFTWARE\Microsoft\SMS\Mobile Client' -Name "AssignedSiteCode" | Select AssignedSiteCode

$regkeypath= "hklm:SOFTWARE\Microsoft\SMS\Mobile Client" 
$value1 = (Get-ItemProperty $regkeypath).AssignedSiteCode -eq "DLB"
If ($value1 -eq $True) 
{

    Write-Host "Exist"

} 
Else 
{
    Write-Host "The value is not DLB attempting a change"
    REG ADD 'HKLM\SOFTWARE\Microsoft\SMS\Mobile Client' /v AssignedSiteCode /t REG_SZ /d DLB
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client" -name "AssignedSiteCode" -Value DLB

}
Write-Host $SiteCode

##################
#Registry Checking
##################

$Pmode = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\CCM\CcmExec" -name ProvisioningMode | Select ProvisioningMode
$TaskExcludes = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\CCM\CcmExec" -name SystemTaskExcludes | Select SystemTaskExcludes


if ( $Pmode -ne 'true') 
  {

    LogWrite "Is set to False"
    
  }

else

  {

    LogWrite "Is set to True, will attempt a change to false"
    REG ADD 'HKLM\SOFTWARE\Microsoft\CCM\CcmExec' /v ProvisioningMode /t REG_SZ /d false
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\CCM\CcmExec" -name "ProvisioningMode" -Value false
    LogWrite "result after attempted change: " $Pmode
    
  }


    clear-itemproperty -path HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -name SystemTaskExcludes 
    LogWrite $TaskExcludes

