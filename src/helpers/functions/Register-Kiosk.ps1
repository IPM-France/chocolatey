Function Get-Device
{
    # Parameters ...
    Param(
	   [string]$DeviceType
    )
    
    if ($DeviceType.Trim().Length -eq 0) {
	   return ''
    }

	# carte CNAM JNAF93
<#    $CatalogueDevices = @{
      Son = 'Realtek High Definition Audio';
      NetworkLan = 'Intel(R) 82579LM Gigabit Network Connection';
      NetworkWifi = 'Intel(R) Centrino(R) Advanced-N 6205';
      Ecran = 'Generic PnP Monitor'
    }
#>
	# carte NC9F6-H61
    $CatalogueDevices = @{
      Son = 'Realtek High Definition Audio';
      NetworkLan = 'Realtek PCIe GBE Family Controller';
      NetworkWifi = 'Intel(R) Centrino(R) Advanced-N 6205';
      Ecran = 'Generic PnP Monitor'
    }
                        
    $CatalogueDevices.$DeviceType
}
Function Register-Kiosk
{ 
    <# 
    .Synopsis 
        Register a package installed on the kiosk
         
    .Description 
		Sets values in the registry for the package
		Updates nsclient registry configuration to install checkPackage.cmd scheduled execution for the required package
         
    .Notes 
        Author    : IPM France, Frédéric MOHIER 
        Date      : 8/1/2014 
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
         
    .Parameter packageDir
        Specifies the package Chocolatey directory.
         
    .Parameter installDir
        Specifies the package installation directory.
         
    .Parameter packageMainFile
        Specifies the package main program file.
         
    .Parameter packageCheckPeriod
        Specifies the package check period. Default is 3600 for checking once each hour.
         
    .Parameter parameters
        Extra parameters to store in package registry.
         
    #> 
     
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$True)] [bool]$isHardwarePackage,
        [Parameter(Mandatory=$True)] [string]$packageName,
        [Parameter(Mandatory=$True)] [string]$packageVersion,
        [Parameter(Mandatory=$True)] [string]$packageDir,
        [Parameter(Mandatory=$True)] [string]$installDir,
        [Parameter(Mandatory=$True)] [string]$packageMainFile,
		[int]$packageCheckPeriod = $global:ksk_checkPeriod,
		[hashtable] $parameters
    ) 
     
    Begin 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"} 
         
    Process 
    {
        Write-Host "$($MyInvocation.MyCommand.Name):: Registering package: $packageName" 
		
		# Check kiosk configuration (monitoring)
		if (-not (Test-KioskConfiguration 3)) { Return 0 }

		# Stopping monitoring agent service
		# Write-Host "$($MyInvocation.MyCommand.Name):: stopping monitoring agent service ..."
		# $serviceName = "nscp"
		# Set-Service $serviceName -startuptype Automatic
		# Stop-Service $serviceName
		
		# Installing check handler
		Write-Host "$($MyInvocation.MyCommand.Name):: installing check handler ..."
		$fCheckInstalled = Join-Path -Path (Join-Path -Path $packageDir "content") "checkInstalled.cmd"
		if (-not (Test-Path -path $fCheckInstalled))
        { 
		  $fCheckInstalled = Join-Path -Path (Join-Path -Path $packageDir "content") "checkInstalled.ps1"
		  if (-not (Test-Path -path $fCheckInstalled))
          {
			$fCheckInstalled = '' 
          }
		}

		$fCheckOk = Join-Path -Path (Join-Path -Path $packageDir "content") "checkOk.cmd"
		if (-not (Test-Path -path $fCheckOk))
        { 
		  $fCheckOk = Join-Path -Path (Join-Path -Path $packageDir "content") "checkOk.ps1"
		  if (-not (Test-Path -path $fCheckOk))
          {
			$fCheckOk = '' 
          }
		}

		$fTestModule = Join-Path -Path (Join-Path -Path $packageDir "content") "testModule.cmd"
		if (-not (Test-Path -path $fTestModule))
        { 
		  $fTestModule = Join-Path -Path (Join-Path -Path $packageDir "content") "testModule.ps1"
		  if (-not (Test-Path -path $fTestModule))
          { 
			$fTestModule = '' 
          }
		}
        
		# NSClient Configuration
		Write-Host "$($MyInvocation.MyCommand.Name):: installing check command ..."
		$registryPath='HKLM:\SOFTWARE\NSClient++';
		if (-not(Test-Path -path (Join-Path $registryPath "settings/external scripts/wrapped scripts"))) { New-Item (Join-Path $registryPath "settings/external scripts/wrapped scripts") -ItemType directory }
		Set-ItemProperty -Path (Join-Path $registryPath "settings/external scripts/wrapped scripts") -Name "check_$packageName" -Value "ipm-Kiosks\checkPackage.ps1 status $packageName -ca `$ARG1`$" -Force
		
		# Install NSCA scheduled check ...
		Write-Host "$($MyInvocation.MyCommand.Name):: installing NSCA scheduled check ..."
		New-Item -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Force
		Set-ItemProperty -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Name 'alias' -Value "nsca-$packageName" -Force
		Set-ItemProperty -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Name 'command' -Value "check_$packageName" -Force
		$value=%{'{0}s' -f $packageCheckPeriod}
		Set-ItemProperty -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Name 'interval' -Value $value -Force
		
		
		# Starting monitoring agent service
		# Write-Host "$($MyInvocation.MyCommand.Name):: starting monitoring agent service ..."
		# $serviceName = "nscp"
		# Set-Service $serviceName -startuptype Automatic
		# Start-Service $serviceName
		
		if ($isHardwarePackage) {
            $packageType = $global:IPM_KSK_PKG_HARDWARE
        } else {
            $packageType = $global:IPM_KSK_PKG_SOFTWARE
        }
		
		# Registering package installation (global values ...)
		Set-ItemProperty -Path $packageType -Name "Package $packageName" -Value "$packageVersion"
		
		# Registering package installation
		$regKiosk = Join-Path $packageType $packageName
		
		Write-Host "$($MyInvocation.MyCommand.Name):: setting package configuration in $packageType ..."
		if (-not(Test-Path -path $packageType)) { New-Item $packageType -ItemType directory }
		if (-not(Test-Path -path $regKiosk)) { New-Item $regKiosk -ItemType directory }
		Set-ItemProperty -Path $regKiosk -Name "Package" -Value "$packageName"
		Set-ItemProperty -Path $regKiosk -Name "Version" -Value "$packageVersion"
		$dhInstallation = Get-Date -Format $global:ksk_dateFormat
		Set-ItemProperty -Path $regKiosk -Name "Installation date" -Value "$dhInstallation"
		Set-ItemProperty -Path $regKiosk -Name "Installation directory" -Value "$installDir"
		Set-ItemProperty -Path $regKiosk -Name "Main program file" -Value "$packageMainFile"
		Set-ItemProperty -Path $regKiosk -Name "Check installed script" -Value "$fCheckInstalled"
		Set-ItemProperty -Path $regKiosk -Name "Check status script" -Value "$fCheckOk"
		Set-ItemProperty -Path $regKiosk -Name "Test module script" -Value "$fTestModule"
		Set-ItemProperty -Path $regKiosk -Name "Installed" -Value 0 -Type DWord
		Set-ItemProperty -Path $regKiosk -Name "Status" -Value 0 -Type DWord

		if ($parameters) {
			Write-Host "$($MyInvocation.MyCommand.Name):: setting extra parameters in $packageType\$packageName ..."
			foreach($key in $($parameters.keys)){ 
				Write-Host "$($MyInvocation.MyCommand.Name):: extra configuration parameter '$key' = " $parameters[$key]
				$value = $parameters[$key]
				if ($value.GetType().Fullname -eq "System.Int32") {
					Set-ItemProperty -Path $regKiosk -Name "$key" -Value $value -Type DWord
				} else {
					Set-ItemProperty -Path $regKiosk -Name "$key" -Value $value
				}
			}
		}
		
        Write-Host "$($MyInvocation.MyCommand.Name):: $packageName registered." 
        Return 1
    } 
         
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"} 
}