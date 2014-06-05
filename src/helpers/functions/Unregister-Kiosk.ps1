Function Unregister-Kiosk 
{ 
    <# 
    .Synopsis 
        Unregister a package installed on the kiosk
         
    .Description 
		Sets values in the registry for the package (installed = 0)
        Removes checkInstalled.cmd and checkOk.cmd files in the NS Client script library
		Updates nsclient registry configuration to remove checkOk.cmd scheduled execution
         
    .Notes 
        Author    : IPM France, Frédéric MOHIER 
        Date      : 27/7/2013 
        Version   : 1.0
         
        #Requires -Version 2.0 
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Int 

	.Parameter isHardwarePackage
        Specifies if the package is hardware.
         
    .Parameter packageName
        Specifies the package name.
         
    .Parameter PackageVersion
        Specifies the package version.
         
    #> 
     
    [CmdletBinding()] 
    # Param( 
        # [ValidateNotNullOrEmpty()] 
        # [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})] 
        # [Parameter(ValueFromPipeline=$True,Mandatory=$True)] 
        # [string]$packageName 
    # ) 
    Param( 
        [Parameter(Mandatory=$True)] [string]$isHardwarePackage,
        [Parameter(Mandatory=$True)] [string]$packageName,
        [Parameter(Mandatory=$True)] [string]$packageVersion
    ) 
     
    Begin 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"} 
         
    Process 
    { 
        Write-Host "$($MyInvocation.MyCommand.Name):: Unregistering package: $packageName" 

		# Check kiosk configuration (monitoring)
		if (-not (Test-KioskConfiguration 3)) { Return 0 }

		# Removing check handler
		# Write-Host "$($MyInvocation.MyCommand.Name):: uninstalling check handler ..."
		# $fCheckInstalled2 = "checkInstalled_"+$packageName+".cmd"
		# $fCheckInstalled2 = Join-Path $global:IPM_KSK_MON_CHECKS_DIR $fCheckInstalled2
		# if (Test-Path -Path $fCheckInstalled2) { Remove-Item $fCheckInstalled2 -Force }
		# $fCheckOk2 = "checkOk_"+$packageName+".cmd"
		# $fCheckOk2 = Join-Path $global:IPM_KSK_MON_CHECKS_DIR $fCheckOk2
		# if (Test-Path -Path $fCheckOk2) { Remove-Item $fCheckOk2 -Force }
		
		# NSClient Configuration
		Write-Host "$($MyInvocation.MyCommand.Name):: uninstalling scheduled check ..."
		$registryPath='HKLM:\SOFTWARE\NSClient++';
		Remove-Item -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -ErrorAction SilentlyContinue

		Write-Host "$($MyInvocation.MyCommand.Name):: uninstalling check command ..."
		# Remove-Item -Path (Join-Path $registryPath "settings/external scripts/scripts") -Value "check_$packageName" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path (Join-Path $registryPath "settings/external scripts/scripts") -Name "check_$packageName" -ErrorAction SilentlyContinue

		if ($isHardwarePackage) {
            $packageType = $global:IPM_KSK_PKG_HARDWARE
        } else {
            $packageType = $global:IPM_KSK_PKG_SOFTWARE
        }
		
		# Unregistering package installation
		$regKiosk = Join-Path $packageType $packageName
		#$dhInstallation = Get-Date -Format $global:ksk_dateFormat
		#Set-ItemProperty -Path $regKiosk -Name "Uninstallation date" -Value "$dhInstallation"
		#Set-ItemProperty -Path $regKiosk -Name "Installed" -Value -1 -Type DWord
		Remove-Item -Path $regKiosk -recurse

        Write-Host "$($MyInvocation.MyCommand.Name):: $packageName unregistered." 
        Return 1
    } 
         
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"} 
}