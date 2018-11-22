<#
.SYNOPSIS
    Takes a QRCode object and formats it for output on the screen.

.DESCRIPTION
    Uses line drawing to convert a QRCode for display on the screen.

.PARAMETER QRCode
    A QRCode output from ConvertTo-QRCode

.PARAMETER TopPadding
    The ammount of padding to put around the code.

.PARAMETER SidePadding
    The ammount of padding to put around the code. You may need to add padding depending on the font used in your terminal.

.PARAMETER CharacterWidth
    The number of characters to use to output each block of the QRCode.

.PARAMETER Invert
    The default PowerShell console is light text on a dark background. If you are using dark text on a light background
    you will need to invert the output so the barcode is the correct color.
#>
function Format-QRCode {
	param(
		[Parameter(ValueFromPipeline=$true,Mandatory=$true)]
		[ZXing.QrCode.Internal.QRCode]$QRCode,
		
		[Parameter(Mandatory=$false)]
		$TopPadding = 2,
		
		[Parameter(Mandatory=$false)]
		$SidePadding = 2,
		
		[Parameter(Mandatory=$false)]
		$CharacterWidth = 1,
		
		[switch]$Invert
	)
	
	#These seem backwards, but in the default ps console they come out correct (dark bg, light text)
	if($Invert) {
		$BlankChar = " "
		$SolidChar = [string][char]0x2588
		$TopActiveChar = [string][char]0x2580
		$BottomActiveChar = [string][char]0x2584
	} else {
		$BlankChar = [string][char]0x2588
		$SolidChar = " "
		$TopActiveChar = [string][char]0x2584
		$BottomActiveChar = [string][char]0x2580
	}

	$SB = New-Object Text.StringBuilder
	
	1..$TopPadding | %{
		#Write-Host ($BlankChar * ($QRCode.Matrix.Width + $SidePadding + $SidePadding) * $CharacterWidth) -fore black -back white
		$SB.AppendLine($BlankChar * ($QRCode.Matrix.Width + $SidePadding + $SidePadding) * $CharacterWidth) > $null
	}
	for($r = 0; $r -lt $QRCode.Matrix.Height; $r++) {
		$SB.Append($BlankChar * $SidePadding * $CharacterWidth) > $null
		for($c = 0; $c -lt $QRCode.Matrix.Width; $c++) {
			$ThisRowEntry = $QRCode.Matrix.Array[$c][$r]
			if($r -lt $QRCode.Matrix.Height - 1) {
				$NextRowEntry = $QRCode.Matrix.Array[$c][$r + 1]
			} else {
				$NextRowEntry = 0
			}
			
			if($ThisRowEntry -And $NextRowEntry) {
				#Make a solid block
				$Out = $SolidChar
			} elseif ($ThisRowEntry -And !$NextRowEntry) {
				$Out = $TopActiveChar
			} elseif (!$ThisRowEntry -And $NextRowEntry) {
				$Out = $BottomActiveChar
			} else {
				$Out = $BlankChar
			}
			
			$SB.Append($Out) > $null
		}
		$r++
		$SB.AppendLine($BlankChar * $SidePadding * $CharacterWidth) > $null
	}
	1..$TopPadding | %{
		#Write-Host ($BlankChar * ($QRCode.Matrix.Width + $SidePadding + $SidePadding) * $CharacterWidth) -fore black -back white
		$SB.AppendLine($BlankChar * ($QRCode.Matrix.Width + $SidePadding + $SidePadding) * $CharacterWidth) > $null
	}
	$SB.ToString()
}
Export-ModuleMember -Function Format-QRCode