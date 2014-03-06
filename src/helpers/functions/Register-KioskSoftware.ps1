Function Register-KioskSoftware 
{ 
    <# 
    .Synopsis 
        Register a software installed on the kiosk
         
    .Description 
		Sets values in the registry for the software package
		Updates nsclient registry configuration to install checkPackage.cmd scheduled execution for the required package
         
    .Notes 
        Author    : IPM France, Frédéric MOHIER 
        Date      : 8/1/2014 
        Version   : 1.6
         
        #Requires -Version 2.0 
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Int 
         
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
         
    .Parameter nscaChecks
        Switch to install NSCA scheduled check (-nsca)
         
    #> 
     
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$True)] [string]$packageName,
        [Parameter(Mandatory=$True)] [string]$packageVersion,
        [Parameter(Mandatory=$True)] [string]$packageDir,
        [Parameter(Mandatory=$True)] [string]$installDir,
        [Parameter(Mandatory=$True)] [string]$packageMainFile,
		[int]$packageCheckPeriod = $global:ksk_checkPeriod,
		[hashtable] $parameters,
		[switch] $nscaChecks = $false
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
		if (-not (Test-Path -path $fCheckInstalled)) { 
			$fCheckInstalled = '' 
		}
		$fCheckOk = Join-Path -Path (Join-Path -Path $packageDir "content") "checkOk.cmd"
		if (-not (Test-Path -path $fCheckOk)) { 
			$fCheckOk = '' 
		}
		$fTestModule = Join-Path -Path (Join-Path -Path $packageDir "content") "testModule.cmd"
		if (-not (Test-Path -path $fTestModule)) { 
			$fTestModule = '' 
		}
		$copyChecks = $false
		if ($copyChecks) {
			$fCheckInstalled2 = "checkInstalled_"+$packageName+".cmd"
			$fCheckInstalled2 = Join-Path $global:IPM_KSK_MON_CHECKS_DIR $fCheckInstalled2
			Copy-Item -Path (Join-Path -Path (Join-Path -Path $packageDir "content") "checkInstalled.cmd") -Destination $fCheckInstalled2 -ErrorAction SilentlyContinue
			$fCheckOk2 = "checkOk_"+$packageName+".cmd"
			$fCheckOk2 = Join-Path $global:IPM_KSK_MON_CHECKS_DIR $fCheckOk2
			Copy-Item -Path (Join-Path -Path (Join-Path -Path $packageDir "content")  "checkOk.cmd") -Destination $fCheckOk2 -ErrorAction SilentlyContinue
		}

		# NSClient Configuration
		Write-Host "$($MyInvocation.MyCommand.Name):: installing check command ..."
		$registryPath='HKLM:\SOFTWARE\NSClient++';
		if (-not(Test-Path -path (Join-Path $registryPath "settings/external scripts/wrapped scripts"))) { New-Item (Join-Path $registryPath "settings/external scripts/wrapped scripts") -ItemType directory }
		Set-ItemProperty -Path (Join-Path $registryPath "settings/external scripts/wrapped scripts") -Name "check_$packageName" -Value "ipm-Kiosks\checkPackage.ps1 status $packageName -ca `$ARG1`$" -Force
		
		# Declare True to install NSCA scheduled check ...
		if ($nscaChecks) {
			Write-Host "$($MyInvocation.MyCommand.Name):: installing NSCA scheduled check ..."
			New-Item -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Force
			Set-ItemProperty -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Name 'alias' -Value "nsca-$packageName" -Force
			Set-ItemProperty -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Name 'command' -Value "check_$packageName" -Force
			$value=%{'{0}s' -f $packageCheckPeriod}
			Set-ItemProperty -Path (Join-Path $registryPath "settings/scheduler/schedules/check_$packageName") -Name 'interval' -Value $value -Force
		}
		
		
		# Starting monitoring agent service
		# Write-Host "$($MyInvocation.MyCommand.Name):: starting monitoring agent service ..."
		# $serviceName = "nscp"
		# Set-Service $serviceName -startuptype Automatic
		# Start-Service $serviceName
		
		
		# Registering software installation (global values ...)
		Set-ItemProperty -Path $global:IPM_KSK_PKG_SOFTWARE -Name "Package $packageName" -Value "$packageVersion"
		
		# Registering software installation
		$regKiosk = Join-Path $global:IPM_KSK_PKG_SOFTWARE $packageName
		
		Write-Host "$($MyInvocation.MyCommand.Name):: setting software configuration in $IPM_KSK_PKG_SOFTWARE ..."
		if (-not(Test-Path -path $global:IPM_KSK_PKG_SOFTWARE)) { New-Item $global:IPM_KSK_PKG_SOFTWARE -ItemType directory }
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
			Write-Host "$($MyInvocation.MyCommand.Name):: setting extra parameters in $IPM_KSK_PKG_SOFTWARE\$packageName ..."
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