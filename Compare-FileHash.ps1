<#
.SYNOPSIS
Checks a file against a hash checksum to confirm it is complete and hasn't been altered.

.DESCRIPTION
Checks a file against a hash checksum to confirm it is complete and hasn't been altered.
It can input either a static hash to test against or a file containing the expected hash
and filename with each file on its own line in the format:
<hash> *<filename>

.PARAMETER Path
Path and filename of the file to test the hash for.

.PARAMETER TestHash
A static hash to test the Path file against.

.PARAMETER TestHashFile
The path and filename of a hash file. The hash file should contain the hash for multiple files with each file on a separate line in the format:
<hash> *<filename>

.PARAMETER HashAlgorithm
OPTIONAL The hash algorthim to check. Valid options are SHA512, SHA256, SHA1, and MD5. If not provided, SHA256 will be used.

.PARAMETER Verbose
OPTIONAL If provided, all output will be a string for console output and will include the hashes.

.INPUTS
None. You cannot pipe objects to Compare-FileHash.

.OUTPUTS
System.Boolean. True if the calculated hash matches the supplied hash, otherwise False.

If -Verbose is provided all output will be System.String, is intended for console output, and will include the hashes.

.EXAMPLE
PS> Compare-FileHash.ps1 -Path 'C:\temp\ubuntu-21.04-desktop-amd64.iso' -TestHash 'fa95fb748b34d470a7cfa5e3c1c8fa1163e2dc340cd5a60f7ece9dc963ecdf88'
True

.EXAMPLE
PS> Compare-FileHash.ps1 -Path 'C:\temp\ubuntu-21.04-desktop-amd64.iso' -TestHashFile 'C:\temp\SHA256SUMS.txt' -Verbose
Hash                                                             InputFrom
----                                                             ---------
fa95fb748b34d470a7cfa5e3c1c8fa1163e2dc340cd5a60f7ece9dc963ecdf88 InputFile
FA95FB748B34D470A7CFA5E3C1C8FA1163E2DC340CD5A60F7ECE9DC963ECDF88 Calculated From File


Matched: True

.LINK
https://github.com/jondle/Compare-FileHash
#>
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