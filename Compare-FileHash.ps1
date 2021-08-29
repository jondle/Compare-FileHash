[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, ParameterSetName = 'InputHash')]
    [Parameter(Mandatory = $true, ParameterSetName = 'InputFile')]
    [ValidateScript({if (Test-Path $_) {$true} else {throw "Path '$_' is invalid."}})]
    [String]$Path,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'InputHash')]
    [ValidateNotNullOrEmpty()]
    [String]$TestHash,

    [Parameter(Mandatory = $true, ParameterSetName = 'InputFile')]
    [ValidateScript({if (Test-Path $_) {$true} else {throw "Path '$_' is invalid."}})]
    [String]$TestHashFile,
    
    [ValidateSet('SHA512','SHA256','SHA1','MD5')]
    [String]$HashAlgorithm = 'SHA256'
)

Function Get-HashForFileFromFile {
    Param (
        [String]$FileName,
        [String]$HashFile
    )

    [String]$outputHash = $null

    Get-Content $HashFile | ForEach-Object {
        $indexOfSpace = $_.IndexOf(' *')
        $hash = $_.Substring(0, $indexOfSpace)
        $file = $_.Substring($indexOfSpace + 2)

        if ($FileName -eq $file) {
            $outputHash = $hash
        }
    }

    $outputHash
}

Function Get-VerboseOutput {
    Param (
        [String]$ParamSetName,
        [String]$InputHash,
        [String]$CalculatedHash
    )

    $data = @(
        @{InputFrom=$ParamSetName;Hash=$InputHash},
        @{InputFrom='Calculated From File';Hash=$CalculatedHash}) | ForEach-Object { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
#    $obj = New-Object -TypeName psobject
#    $obj | Add-Member -MemberType NoteProperty -Name 'InputFrom' -Value $ParamSetName
#    $obj | Add-Member -MemberType NoteProperty -Name 'Hash' -Value $InputHash
#    $data += $obj

#    $obj = New-Object -TypeName psobject
#    $obj | Add-Member -MemberType NoteProperty -Name 'InputFrom' -Value 'Calculated From File'
#    $obj | Add-Member -MemberType NoteProperty -Name 'Hash' -Value $CalculatedHash
#    $data += $obj

    $data
}

[String]$inputHash = $null

if ($PSCmdlet.ParameterSetName -eq 'InputFile') {
    $fileName = [System.IO.Path]::GetFileName($Path)
    $inputHash = Get-HashForFileFromFile -FileName $fileName -HashFile $TestHashFile

    if ([System.String]::IsNullOrEmpty($inputHash)) {
        throw "Could not find a hash for the file '$fileName' in the hash file '$TestHashFile'."
    }
}
else {
    $inputHash = $TestHash
}

$calculatedHash = Get-FileHash -Path $Path -Algorithm $HashAlgorithm

if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $verboseData = Get-VerboseOutput -ParamSetName $PSCmdlet.ParameterSetName -InputHash $inputHash -CalculatedHash $calculatedHash.Hash
    $verboseData | Out-Host
    "Matched: $($inputHash -eq $calculatedHash.Hash)" | Out-Host
}
else {
    $inputHash -eq $calculatedHash.Hash
}