#
# sln
#
Write-Host 'Start validate_sln.ps1'

function ValidateVersion {
    param (
        $Sln
    )
    $minimalVersion = "17.8.8.1"

    $insideSlnValue = Select-String -Path $Sln -Pattern 'VisualStudioVersion = ' -CaseSensitive
    foreach($item in $insideSlnValue){
        if (-not ([string]::IsNullOrEmpty($item)))
        {
            $changed = $item.ForEach({ (-split $_)[2] }) | Out-String
            if ([System.Version]$changed -lt [System.Version]$minimalVersion){
                Write-Host 'Solution has' $item 'smaller than the target' $minimalVersion -BackgroundColor Cyan
            }
        }
        else 
        {
            Write-Host 'sln '$Sln 'is not using the ceiling version for net8.0' -BackgroundColor Cyan
        }
    }
}

$sln = Get-ChildItem -Path "*.sln"
ValidateVersion -Sln $sln

Write-Host 'End validate_sln.ps1'