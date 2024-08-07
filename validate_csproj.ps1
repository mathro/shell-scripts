#
# csproj has <TargetFramework>net8.0</TargetFramework>
# csproj has <Nullable>enable</Nullable>
#
Write-Host 'Start validate_csproj.ps1'

function ValidateTargetFramework {
    param (
        $Csproj
    )

    $insideCsprojValue = Select-String -Path $csproj -Pattern '<TargetFramework>net8.0</TargetFramework>' -CaseSensitive
    if (-not ([string]::IsNullOrEmpty($insideCsprojValue)))
    {
    }
    else 
    {
        Write-Host 'csproj '$csproj 'is not net8.0' -BackgroundColor Red
    }
}

function HasSatelliteResourceLanguage {
    param (
        $Csproj
    )

    $hasSatellite = Select-String -Path $csproj -Pattern '<SatelliteResourceLanguages>en</SatelliteResourceLanguages>' -CaseSensitive
    $isExe = Select-String -Path $csproj -Pattern '<OutputType>Exe</OutputType>' -CaseSensitive
    $isLib = Select-String -Path $csproj -Pattern '<OutputType>Library</OutputType>' -CaseSensitive
    $isExe
    $isLib
    if (-not [string]::IsNullOrEmpty($isLib) -or -not ([string]::IsNullOrEmpty($hasSatellite)))
    {
    } 
    elseif (([string]::IsNullOrEmpty($hasSatellite)) -and -not ([string]::IsNullOrEmpty($isExe)))
    {
        Write-Host 'csproj '$csproj 'does not have SatelliteResourceLanguage property' -BackgroundColor Yellow
    }
    else 
    {
        Write-Host 'csproj '$csproj 'does not have SatelliteResourceLanguage property' -BackgroundColor Yellow
    }
}

function ValidateNullableEnable {
    param (
        $Csproj
    )

    $insideCsprojValue = Select-String -Path $csproj -Pattern '<Nullable>enable</Nullable>' -CaseSensitive
    if (-not ([string]::IsNullOrEmpty($insideCsprojValue)))
    {
    }
    else 
    {
        Write-Host 'csproj '$csproj 'nullable context is not enabled.' -BackgroundColor Yellow
    }
}

function ValidateLangVersion {
    param (
        $Csproj
    )

    $insideCsprojValue = Select-String -Path $csproj -Pattern '<LangVersion>' -CaseSensitive
    if ([string]::IsNullOrEmpty($insideCsprojValue))
    {
    }
    else 
    {
        Write-Host 'csproj '$csproj 'has LangVersion property.' -BackgroundColor Cyan
    }
}

function HasUndesiredPackages {
    param (
        $Csproj
    )
    $undesiredPckgs = 'mmm.abc','mmm.def'
    foreach($pck in $undesiredPckgs){
        $insideCsprojPckName = Select-String -Path $csproj -Pattern $pck -CaseSensitive
        if ([string]::IsNullOrEmpty($insideCsprojPckName))
        {
        }
        else 
        {
            Write-Host 'csproj '$csproj 'has deprecated package' $pck -BackgroundColor Yellow
        }
    }
}

function HasUndesiredPackagesVersion {
    param (
        $Csproj
    )
    $undesiredPckgs = @()
    $undesiredPckgs += New-object psobject @{
        Name = 'mmm.abc'
        Version = '8.0.7'
    }
    $undesiredPckgs += New-object psobject @{
        Name = 'mmm.def'
        Version = '1.0.7'
    }
    foreach($pck in $undesiredPckgs){
        $insideCsprojName = Select-String -Path $csproj -Pattern $pck.Name -CaseSensitive 
        $insideCsprojVersion = $insideCsprojName | Select-String -Pattern 'Version=' -CaseSensitive 
        
        if ([string]::IsNullOrEmpty($insideCsprojName) -or [string]::IsNullOrEmpty($insideCsprojVersion))
        {
        }
        else 
        {
            $woop = $insideCsprojVersion.ForEach({ (-split $_)[3] })
            $zoop = $woop.split('"')
            if ([System.Version]$zoop[1] -le [System.Version]$pck.Version){
                Write-Host 'csproj '$csproj 'has deprecated package' $pck.Name $zoop[1]. 'target version is greater than' $pck.Version -BackgroundColor Yellow
            }
        }
    }
}

function IsPackageReferenceSorted {
    param (
        $Csproj
    )

    $includes = (Get-Content $csproj) | Select-String 'Include=(.*?)Version=' -CaseSensitive

    if (-not [string]::IsNullOrEmpty($includes))
    {
        Write-host $Csproj 'now it is wip time' -BackgroundColor Green
        $sorted = $includes | Sort-Object
        if ($inclues -ne $sorted){
            Write-Host 'csproj '$csproj 'has package references that need to be sorted' -BackgroundColor Green
            $includes
        }
    }
    else 
    {
    }
}

$csprojAll = Get-ChildItem -Recurse -Path "*.csproj"
foreach ($csproj in $csprojAll)
{
    ValidateTargetFramework -Csproj $csproj
    ValidateNullableEnable -Csproj $csproj
    ValidateLangVersion -Csproj $csproj
    HasUndesiredPackages -Csproj $csproj
    HasUndesiredPackagesVersion -Csproj $csproj
    IsPackageReferenceSorted -Csproj $csproj
    HasSatelliteResourceLanguage -Csproj $csproj
    # IsUsingSorted -Csproj $csproj
    # NullForgiving
}

Write-Host 'End validate_csproj.ps1'