<#
.DESCRIPTION
  Generates a TOTP link for configuring an authenticator app via QR Code.
#>
function New-TotpLink {
  param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $AppName,

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $UserName,

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $Secret
  )
  process {
    $AppName = [System.Web.HttpUtility]::UrlEncode($AppName)
    $UserName = [System.Web.HttpUtility]::UrlEncode($UserName)
    $Secret = [System.Web.HttpUtility]::UrlEncode($Secret)

    "otpauth://totp/${UserName}?secret=${Secret}&issuer=${AppName}"
  }
}
Export-ModuleMember -Function New-TotpLink
