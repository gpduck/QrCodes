<#
.SYNOPSIS
    Search UPCDatabase.com for information on a particular UPC

.DESCRIPTION
    Search UPCDatabase.com for information on a particular UPC

.PARAMETER Upc
    The UPC code to search for.

.PARAMETER ApiKey
    Your API key on upcdatabase.com
#>
function Find-UPC {
    param(
        $Upc,
        $ApiKey = ""
    )
    Invoke-XmlRpcMethod -Url http://www.upcdatabase.com/xmlrpc -MethodName lookup -Parameters @{rpc_key=$ApiKey; upc=$Upc}
}
Export-ModuleMember -Function Find-UPC