## Description
Checks a file against a hash checksum to confirm it is complete and hasn't been altered.
It can input either a static hash to test against or a file containing the expected hash
and filename with each file on its own line in the format:
\<hash\> \*\<filename\>

See PowerShell help for more details.

`
PS> Get-Help .\Compare-FileHash.ps1
`

### NAME
    Compare-FileHash.ps1

### SYNOPSIS
    Checks a file against a hash checksum to confirm it is complete and hasn't been altered.


### SYNTAX
    Compare-FileHash.ps1 -Path <String> -TestHashFile <String> [-HashAlgorithm <String>]
    [<CommonParameters>]

    Compare-FileHash.ps1 -Path <String> -TestHash <String> [-HashAlgorithm <String>]
    [<CommonParameters>]


### DESCRIPTION
    Checks a file against a hash checksum to confirm it is complete and hasn't been altered.
    It can input either a static hash to test against or a file containing the expected hash
    and filename with each file on its own line in the format:
    <hash> *<filename>


### RELATED LINKS
    https://github.com/jondle/Compare-FileHash

### REMARKS
    To see the examples, type: "get-help .\Compare-FileHash.ps1 -examples".
    For more information, type: "get-help .\Compare-FileHash.ps1 -detailed".
    For technical information, type: "get-help .\Compare-FileHash.ps1 -full".
    For online help, type: "get-help .\Compare-FileHash.ps1 -online"