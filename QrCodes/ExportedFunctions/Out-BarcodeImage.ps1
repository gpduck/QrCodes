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

.EXAMPLE
    Out-BarcodeImage -Content "test string" -Path $pwd\barcode.png

    Creates a QR code and saves it as a PNG file into the local directory.
#>
function Out-BarcodeImage {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Content,

        [ZXing.BarcodeFormat]$BarcodeFormat = [ZXing.BarcodeFormat]::QR_Code,

        [ZXing.Common.EncodingOptions]$Options,

        [String]$Path,

        [System.Drawing.Imaging.ImageFormat]$ImageFormat = [System.Drawing.Imaging.ImageFormat]::Png,

        [int]$Width,

        [int]$Height,

        [switch]$Passthrough
    )
    begin {
        $Folder = Split-Path -Path $Path -Parent
        $File = Split-Path -Path $Path -Leaf
        $Folder = (Resolve-Path -Path $Folder -ErrorAction Stop).Path
        $Path = Join-Path -Path $Folder -ChildPath $File
        $ContentBuilder = New-Object System.Text.StringBuilder
        $Writer = New-Object ZXing.BarcodeWriterPixelData -Property @{ Format = $BarcodeFormat; Options = $Options }
        if($Width -gt $Height) {
            $Size = $Width
        } else {
            $Size = $Height
        }
        if($Size) {
            $Writer.Options.Width = $Size
            $Writer.Options.Height = $Size
        }
    }
    process {
        $ContentBuilder.AppendLine($Content) > $null
    }
    end {
        try {
            $PixelData = $Writer.Write($ContentBuilder.ToString())

            $Height = $PixelData.Height
            $Width = $PixelData.Width
            $PixelCount = $Height * $Width

            $Bitmap = New-Object System.Drawing.Bitmap($Width, $Height)

            for($i = 0; $i -lt $PixelCount; $i++) {
                $A = $PixelData.Pixels[$i * 4 + 3] -bxor 0xff
                $R = $PixelData.Pixels[$i * 4 + 2]
                $G = $PixelData.Pixels[$i * 4 + 1]
                $B = $PixelData.Pixels[$i * 4]

                $X = $i % $Width
                $Y = [Math]::Floor( ($i / $Height) )
                try {
                $Bitmap.SetPixel($X, $Y, [System.Drawing.Color]::FromARGB($A, $R, $G, $B))
                } catch { write-host "$x $y" }
            }

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
}
Export-ModuleMember -Function Out-BarcodeImage