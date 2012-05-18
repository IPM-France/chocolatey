function Get-ConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)


    if ($globalConfig -eq '') {
        $globalConfigFile = Join-Path $nugetChocolateyPath chocolatey.yml
        $globalConfig = Get-Yaml -FromFile (Resolve-Path $globalConfigFile)
    }

    if ($userConfig -eq '') {
        #$env:USERPROFILE or $env:HOME
        $userConfigFile = Join-Path $env:USERPROFILE chocolatey.yml
        
        $userConfig = $globalConfig
        if (Test-Path($userConfigFile)) {
            $userConfig = Get-Yaml -FromFile (Resolve-Path $userConfigFile)
        }
    }

    $returnValue = iex "`$userConfig.$configValue"
    write-debug "After checking the user config the value of `'$configValue`' is `'$returnValue`'"
    if ($returnValue -eq $null -or $returnValue -eq '') {
        write-debug "`'$configValue`' not found in the user config file - checking the global config"
        $returnValue = iex "`$globalConfig.$configValue"
        write-debug "After checking the global config the value of `'$configValue`' is `'$returnValue`'"
    }

    if ($returnValue -eq $null) {
        write-error "A configuration value for $configValue was not found"
    }

    $returnValue
}