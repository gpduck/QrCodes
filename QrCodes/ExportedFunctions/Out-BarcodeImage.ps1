<#
.SYNOPSIS
    Creates a barcode and saves it as an image file.

.DESCRIPTION
    Uses the ZXing.Net library to create barcodes and save them as image files.

.PARAMETER Content
    The contents of the barcode.  This needs to be valid content for the BarcodeFormat you are writing.

.PARAMETER BarcodeFormat
    One of the barcode formats supported by ZXing.Net

.PARAMETER Options
    Barcode encoding options.

.PARAMETER Path
    The output file to create.

.PARAMETER ImageFormat
    One of the image formats supported by System.Drawing.Imaging

.PARAMETER Width
    The width in pixels of the image file.

.PARAMETER Height
    The height in pixels of the image file.

.PARAMETER Passthrough
    Indicates that the output path should be passed along in the pipeline.
#>
function Out-BarcodeImage {
    param(
        [Parameter(Mandatory=$true)]
        $Content,

        [ZXing.BarcodeFormat]$BarcodeFormat = [ZXing.BarcodeFormat]::QR_Code,

        [ZXing.Common.EncodingOptions]$Options,

        [String]$Path,

        [System.Drawing.Imaging.ImageFormat]$ImageFormat = [System.Drawing.Imaging.ImageFormat]::Png,

        [int]$Width,

        [int]$Height,

        [switch]$Passthrough
    )
    $Writer = New-Object ZXing.BarcodeWriter -Property @{ Format = $BarcodeFormat; Options = $Options }
    if($Width) {
        $Writer.Options.Width = $Width
    }
    if($Height) {
        $Writer.Options.Height = $Height
    }
    try {
        $Bitmap = $Writer.Write($Content)
        $Bitmap.Save($Path, $ImageFormat)
        if($Passthrough) {
            $Path
        }
    } catch {
        Write-Error -Message "Error creating barcode: $($_.Exception.Message)" -Exception $_.Exception
    } finally {
        if($Bitmap) {
            $Bitmap.Dispose()
        }
    }
}
Export-ModuleMember -Function Out-BarcodeImage