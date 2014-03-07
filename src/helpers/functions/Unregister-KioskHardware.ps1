Function Unregister-KioskHardware 
{ 
    <# 
    .Synopsis 
        Unregister a hardware installed on the kiosk
         
    .Description 
		Sets values in the registry for the hardware (installed = 0)
         
    .Notes 
        Author    : IPM France, Frédéric MOHIER 
        Date      : 27/7/2013 
        Version   : 1.1
         
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
    #> 
     
    [CmdletBinding()] 
    # Param( 
        # [ValidateNotNullOrEmpty()] 
        # [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})] 
        # [Parameter(ValueFromPipeline=$True,Mandatory=$True)] 
        # [string]$deviceName 
    # ) 
    Param( 
        [Parameter(Mandatory=$True)] [string]$deviceName,
        [Parameter(Mandatory=$True)] [string]$deviceVersion,
        [Parameter(Mandatory=$True)] [string]$packageName,
        [Parameter(Mandatory=$False)][string]$packageVersion = ""
    ) 
     
    Begin 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"} 
         
    Process 
    { 
        Write-Host "$($MyInvocation.MyCommand.Name):: Unregistering package: $deviceName" 

		# Check kiosk configuration (identity)
		if (-not (Test-KioskConfiguration 2)) { Return 0 }
		
		# Unregistering hardware installation
		$regKiosk = Join-Path $global:IPM_KSK_PKG_HARDWARE $packageName
		#$dhInstallation = Get-Date -Format $global:ksk_dateFormat
		#Set-ItemProperty -Path $regKiosk -Name "Uninstallation date" -Value "$dhInstallation"
		#Set-ItemProperty -Path (Join-Path $global:IPM_KSK_PKG_HARDWARE $deviceName) -Name "Installed" -Value -1 -Type DWord
		Remove-Item -Path $regKiosk -recurse

        Write-Host "$($MyInvocation.MyCommand.Name):: $deviceName unregistered." 
        Return 1
    } 
         
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"} 
}