$global:IPM_KSK_REGISTRY = ""
$global:IPM_KSK_CONFIGURATION = "" 

$global:IPM_KSK_DIR_LOGS = ""
$global:IPM_KSK_DIR_CFG = ""
$global:IPM_KSK_DIR_PKG = ""
$global:IPM_KSK_PKG_SERVER = ""
$global:IPM_KSK_PKG_SOFTWARE = ""
$global:IPM_KSK_PKG_HARDWARE = ""

$global:IPM_KSK_SN = ""
$global:IPM_KSK_MODEL = ""
$global:IPM_KSK_TYPE = ""
$global:IPM_KSK_CLIENT = ""
$global:IPM_KSK_SITE = ""
$global:IPM_KSK_GROUP = ""
$global:IPM_KSK_STATUS = ""

$global:IPM_KSK_MON_SERVER = ""
$global:IPM_KSK_MON_CHECKS_DIR = ""
$global:IPM_KSK_MNG_SERVER = ""

$global:ksk_sn = "Serial number"
$global:ksk_model = "Model"
$global:ksk_type = "Type"
$global:ksk_client = "Client"
$global:ksk_site = "Location"
$global:ksk_group = "Group"
$global:ksk_status = "Status"

$global:ksk_checkPeriod = 3600
$global:ksk_dateFormat = "yyyy-MM-dd HH:mm:ss"

# Processor 32 / 64 bits ?
$processor = Get-WmiObject Win32_Processor
$procCount=(Get-WmiObject Win32_ComputerSystem).NumberofProcessors
if ($procCount -eq '1') {
	$global:is64bit = $processor.AddressWidth -eq 64
} else {
	$global:is64bit = $processor[0].AddressWidth -eq 64
}

# Gets the specified registry value or $null if it is missing
function Get-RegistryValue {
	param($regKey, $valueName)
	
	# Write-Debug "Get-RegistryValue:: $regKey -> $valueName"
	$value = Get-ItemProperty -Path $regKey -Name $valueName -ErrorAction SilentlyContinue 
	if (($value -eq $null) -or ($value.Length -eq 0)) {
		return $null
	} else {
		$value = $value.$valueName
		return $value
	}
}

Function Test-KioskConfiguration { 
    <# 
    .Synopsis 
        Check kiosk configuration 
         
    .Description 
		Checks environment and registry variables 
         
    .Notes 
        Author    : IPM France, Frédéric MOHIER 
        Date      : 7/8/2013 
        Version   : 1.2
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Int :
		$true, if all checks are Ok
		$false, if errors were detected
         
    .Parameter checkLevel
        Specifies the check level. Default is 1 for checking only base configuration.
		1 : base configuration (registry set by setKiosk installation)
		2 : identity configuration (registry set by setKiosk usage)
		3 : monitoring configuration (NS Client)
		4 : operating configuration (Fusion)
    #> 
     
    [CmdletBinding()] 
    Param( 
		[int]$checkLevel = 1
    ) 
	

	Write-Host "$($MyInvocation.MyCommand.Name):: checking environment variables ..." 
	if(-not(Test-Path Env:\IPM_KSK_REGISTRY)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: environment variable $IPM_KSK_REGISTRY does not exist ... run setKiosk.cmd to set up !" 
		Return $false
	}
	$IPM_KSK_REGISTRY = "$env:IPM_KSK_REGISTRY"
	$global:IPM_KSK_REGISTRY = $IPM_KSK_REGISTRY
	Write-Debug "$($MyInvocation.MyCommand.Name):: IPM_KSK_REGISTRY environment variable : $IPM_KSK_REGISTRY"
	
	Write-Host "$($MyInvocation.MyCommand.Name):: checking registry variables ..." 
	if (!(Test-Path -path $IPM_KSK_REGISTRY -PathType Container)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry $IPM_KSK_REGISTRY does not exist ... run setKiosk.cmd to set up !" 
		Return $false
	}
	Write-Debug "$($MyInvocation.MyCommand.Name):: IPM_KSK_REGISTRY = $IPM_KSK_REGISTRY"
	
	if (-not (Test-Path -path (Join-Path $IPM_KSK_REGISTRY "configuration") -PathType Container)) { 
		Write-Host "$($MyInvocation.MyCommand.Name):: registry configuration variable is not set ... install setKiosk to set up !" 
		Return $false
	}
	
	Write-Host "$($MyInvocation.MyCommand.Name):: checking registry configuration variables ..." 
	$IPM_KSK_CONFIGURATION = Join-Path $IPM_KSK_REGISTRY "configuration"
	$global:IPM_KSK_CONFIGURATION = $IPM_KSK_CONFIGURATION
	if (-not (Get-ItemProperty -Path $IPM_KSK_CONFIGURATION)) { 
		Write-Host "$($MyInvocation.MyCommand.Name):: registry configuration variable is not available ... install setKiosk to set up !" 
		Return $false
	}
	Write-Debug "$($MyInvocation.MyCommand.Name):: IPM_KSK_CONFIGURATION = $IPM_KSK_CONFIGURATION"
	
	# 
	$IPM_KSK_DIR_LOGS = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_DIR_LOGS"
	if (-not ($IPM_KSK_DIR_LOGS)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry variables not set ... install setKiosk to set up !"
		Return $false
	}
	$global:IPM_KSK_DIR_LOGS = $IPM_KSK_DIR_LOGS
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_DIR_LOGS = $IPM_KSK_DIR_LOGS"
	# 
	$IPM_KSK_DIR_CFG = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_DIR_CFG"
	if (-not ($IPM_KSK_DIR_CFG)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry variables not set ... install setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_DIR_CFG = $IPM_KSK_DIR_CFG
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_DIR_CFG = $IPM_KSK_DIR_CFG"
	# 
	$IPM_KSK_DIR_PKG = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_DIR_PKG"
	if (-not ($IPM_KSK_DIR_PKG)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry variables not set ... install setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_DIR_PKG = $IPM_KSK_DIR_PKG
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_DIR_PKG = $IPM_KSK_DIR_PKG"
	# 
	$IPM_KSK_PKG_SERVER = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_PKG_SERVER"
	if ($IPM_KSK_PKG_SERVER -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry variables not set ... install setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_PKG_SERVER = $IPM_KSK_PKG_SERVER
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_PKG_SERVER = $IPM_KSK_PKG_SERVER"
	# 
	$IPM_KSK_PKG_ROOT = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_PKG_ROOT"
	if ($IPM_KSK_PKG_ROOT -eq $null) {
		Write-Host " - registry variable 'IPM_KSK_PKG_ROOT' not set ... install setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_PKG_ROOT = $IPM_KSK_PKG_ROOT
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_PKG_ROOT = $IPM_KSK_PKG_ROOT"
	#
	$IPM_KSK_PKG_SOFTWARE = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_PKG_SOFTWARE"
	if (-not ($IPM_KSK_PKG_SOFTWARE)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry variables not set ... install setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_PKG_SOFTWARE = $IPM_KSK_PKG_SOFTWARE
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_PKG_SOFTWARE = $IPM_KSK_PKG_SOFTWARE"
	# 
	$IPM_KSK_PKG_HARDWARE = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_PKG_HARDWARE"
	if (-not ($IPM_KSK_PKG_HARDWARE)) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry variables not set ... install setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_PKG_HARDWARE = $IPM_KSK_PKG_HARDWARE
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_PKG_HARDWARE = $IPM_KSK_PKG_HARDWARE"
	Write-Host "$($MyInvocation.MyCommand.Name):: registry configuration variables checked" 
	
	if ($checkLevel -eq 1) {
		Write-Host "$($MyInvocation.MyCommand.Name):: kiosk base configuration is valid." 
		Return $true
	}
	
	# Checking registry identity variables
	Write-Host "$($MyInvocation.MyCommand.Name):: checking registry identity variables ..." 
	$IPM_KSK_SN = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_sn
	if ($IPM_KSK_SN -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_sn' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_SN = $IPM_KSK_SN
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_SN = $IPM_KSK_SN"
	$IPM_KSK_MODEL = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_model
	if ($IPM_KSK_MODEL -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_model' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_MODEL = $IPM_KSK_MODEL
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_MODEL = $IPM_KSK_MODEL"
	$IPM_KSK_TYPE = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_type
	if ($IPM_KSK_TYPE -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_type' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_TYPE = $IPM_KSK_TYPE
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_TYPE = $IPM_KSK_TYPE"
	$IPM_KSK_CLIENT = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_client
	if ($IPM_KSK_CLIENT -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_client' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_CLIENT = $IPM_KSK_CLIENT
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_CLIENT = $IPM_KSK_CLIENT"
	$IPM_KSK_SITE = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_site
	if ($IPM_KSK_SITE -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_site' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_SITE = $IPM_KSK_SITE
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_SITE = $IPM_KSK_SITE"
	$IPM_KSK_GROUP = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_group
	if ($IPM_KSK_GROUP -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_group' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_GROUP = $IPM_KSK_GROUP
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_GROUP = $IPM_KSK_GROUP"
	$IPM_KSK_STATUS = Get-RegistryValue $IPM_KSK_REGISTRY $global:ksk_status
	if ($IPM_KSK_STATUS -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variable '$global:ksk_status' not set ... use setKiosk to set up !" 
		Return $false
	}
	$global:IPM_KSK_STATUS = $IPM_KSK_STATUS
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_STATUS = $IPM_KSK_STATUS"
	Write-Host "$($MyInvocation.MyCommand.Name):: registry identity variables checked" 

	if ($checkLevel -eq 2) {
		Write-Host "$($MyInvocation.MyCommand.Name):: kiosk identity configuration is valid." 
		Return $true
	}
	
	# Checking monitoring agent installation
	Write-Host "$($MyInvocation.MyCommand.Name):: checking monitoring agent installation ..." 
	$IPM_KSK_MON_SERVER = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_MON_SERVER"
	if ($IPM_KSK_MON_SERVER -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry monitoring agent variables (IPM_KSK_MON_SERVER) not set ... install NSClient package to set up !" 
		Return $false
	}
	$global:IPM_KSK_MON_SERVER = $IPM_KSK_MON_SERVER
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_MON_SERVER = $IPM_KSK_MON_SERVER"
	$IPM_KSK_MON_CHECKS_DIR = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_MON_CHECKS_DIR"
	if ($IPM_KSK_MON_CHECKS_DIR -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry monitoring agent variables (IPM_KSK_MON_CHECKS_DIR) not set ... install NSClient package to set up !" 
		Return $false
	}
	$global:IPM_KSK_MON_CHECKS_DIR = $IPM_KSK_MON_CHECKS_DIR
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_MON_CHECKS_DIR = $IPM_KSK_MON_CHECKS_DIR"
	
	if ($checkLevel -eq 3) {
		Write-Host "$($MyInvocation.MyCommand.Name):: kiosk monitoring configuration is valid." 
		Return $true
	}
	
	# Checking management agent installation
	Write-Host "$($MyInvocation.MyCommand.Name):: checking management agent installation ..." 
	$IPM_KSK_MNG_SERVER = Get-RegistryValue $IPM_KSK_CONFIGURATION "IPM_KSK_MNG_SERVER"
	if ($IPM_KSK_MNG_SERVER -eq $null) {
		Write-Host "$($MyInvocation.MyCommand.Name):: registry management agent variables not set ... install Fusion_Inventory package to set up !" 
		Return $false
	}
	$global:IPM_KSK_MNG_SERVER = $1IPM_KSK_MNG_SERVER
	Write-Debug "$($MyInvocation.MyCommand.Name):: kiosk IPM_KSK_MNG_SERVER = $IPM_KSK_MNG_SERVER"
	
	if ($checkLevel -eq 4) {
		Write-Host "$($MyInvocation.MyCommand.Name):: kiosk management configuration is valid." 
		Return $true
	}
	
	Write-Host "$($MyInvocation.MyCommand.Name):: kiosk configuration is valid." 
	Return 0
}