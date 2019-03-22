$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = Join-Path $here "../Release/QrCodes"

Import-module $sut -Force

Describe "QRCodes" {
    It "creates a QR code" {
        $QRCode = "test string" | ConvertTo-QRCode
        $QRCode | Should -Not -Be $null
        $QRCode | Should -BeOfType ZXing.QrCode.Internal.QRCode
    }   
}

Describe "Format-QRCode" {
    It "adds correct padding" {
        $QRCode = "test string" | ConvertTo-QRCode
        $String = $QRCode | Format-QRCode

        $Width = $QRCode.Matrix.Width + 4 + [Environment]::NewLine.Length
        $Height = [Math]::Ceiling($QRCode.Matrix.Height / 2) + 4

        $String.Length | Should -Be ($Width * $Height)
    }
}