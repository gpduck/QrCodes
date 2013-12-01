<#
.SYNOPSIS
    Converts input to a QRCode object.

.DESCRIPTION
    Uses the ZXing.Net library to convert input to a QRCode object.

.PARAMETER InputObject
    The data to encode into a QRCode

.PARAMETER ErrorCorrection
    The ammount of redundant data to include in the QRCode for error correction.

.EXAMPLE
    ConvertTo-QRCode -InputObject "http://www.example.com" | Format-QRCode

    This converts the URL to a QRCode an then uses the Format-QRCode function to output the code on the screen.
#>
function ConvertTo-QRCode {
	param(
		[Parameter(ValueFromPipeline=$true,Mandatory=$true)]
		$InputObject,
		
        [ValidateSet("H","L","M","Q")]
		[Parameter(Mandatory=$false)]
		$ErrorCorrection = "M"
	)
	process {
		[ZXing.QrCode.Internal.Encoder]::Encode($InputObject, [ZXing.QrCode.Internal.ErrorCorrectionLevel]::$ErrorCorrection)
	}
}
Export-ModuleMember -Function ConvertTo-QrCode