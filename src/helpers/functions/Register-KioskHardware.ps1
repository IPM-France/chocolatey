Function Register-KioskHardware 
{ 
    <# 
    .Synopsis 
        Register a hardware installed on the kiosk
         
    .Description 
		Sets values in the registry for the hardware
         
    .Notes 
        Author    : IPM France, Frédéric MOHIER 
        Date      : 8/1/2014 
        Version   : 1.4
         
        #Requires -Version 2.0 
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Int 
         
    .Parameter deviceName
        Specifies the device name.
         
    .Parameter deviceVersion
        Specifies the device version.
         
    .Parameter packageName
        Specifies the package name.
         
    .Parameter PackageVersion (optional)
        Specifies the package version.
         
    .Parameter parameters
        Extra parameters to store in package registry.
         
    #> 
     
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$True)] [string]$deviceName,
        [Parameter(Mandatory=$True)] [string]$deviceVersion,
        [Parameter(Mandatory=$True)] [string]$packageName,
        [Parameter(Mandatory=$False)][string]$packageVersion = "",
		[hashtable] $parameters
    ) 
     
    Begin 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"} 
         
    Process 
    { 
        Write-Host "$($MyInvocation.MyCommand.Name):: Registering hardware: $deviceName" 

		# Check kiosk configuration (identity)
		if (-not (Test-KioskConfiguration 2)) { Return 0 }
		
		# Registering hardware installation (global values ...)
		Set-ItemProperty -Path $global:IPM_KSK_PKG_HARDWARE -Name "Package $deviceName" -Value "$deviceVersion"
		
		# Registering hardware installation
		$regKiosk = Join-Path $global:IPM_KSK_PKG_HARDWARE $packageName
		Write-Host "$($MyInvocation.MyCommand.Name):: setting software configuration in $IPM_KSK_PKG_HARDWARE\$packageName ..."
		if (-not(Test-Path -path $global:IPM_KSK_PKG_HARDWARE)) { New-Item $global:IPM_KSK_PKG_HARDWARE -ItemType directory }
		if (-not(Test-Path -path $regKiosk)) { New-Item $regKiosk -ItemType directory }
		Set-ItemProperty -Path $regKiosk -Name "Package" -Value "$deviceName"
		Set-ItemProperty -Path $regKiosk -Name "Version" -Value "$deviceVersion"
		$dhInstallation = Get-Date -Format $global:ksk_dateFormat
		Set-ItemProperty -Path $regKiosk -Name "Installation date" -Value "$dhInstallation"
		Set-ItemProperty -Path $regKiosk -Name "Installed" -Value 0 -Type DWord
		Set-ItemProperty -Path $regKiosk -Name "Status" -Value 0 -Type DWord
		Set-ItemProperty -Path $regKiosk -Name "swPackage" -Value "$packageName"
		Set-ItemProperty -Path $regKiosk -Name "swVersion" -Value "$packageVersion"

		if ($parameters) {
			Write-Host "$($MyInvocation.MyCommand.Name):: setting extra parameters in $IPM_KSK_PKG_HARDWARE\$packageName ..."
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


		# If associated software package is registered ...
		if (Test-Path -Path (Join-Path $global:IPM_KSK_PKG_SOFTWARE $packageName)) {
			# If exists external test module, register for it ...
			$fTestModule = Get-ItemProperty -Path (Join-Path $global:IPM_KSK_PKG_SOFTWARE $packageName) -Name "Test module script" -ErrorAction SilentlyContinue | Select -exp "Test module script"
			if ($fTestModule) {
				Set-ItemProperty -Path $regKiosk -Name "Test module script" -Value "$fTestModule"
			}
		}

        Write-Host "$($MyInvocation.MyCommand.Name):: $deviceName registered." 
        Return 1
    } 
         
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"} 
}