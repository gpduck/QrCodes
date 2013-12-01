<#
.SYNOPSIS
    Builds a VCard

.DESCRIPTION
    Uses the data passed in as parameters to build a valid VCard string.

.PARAMETER Name
    The name to be put in the "N" VCard field.
    
.PARAMETER FormattedName
    The name to be put in the "FN" VCard field.

.PARAMETER Nickname
    The name to be put in the "NICKNAME" VCard field.

.PARAMETER Birthday
    The birthday to be put in the "BDAY" VCard field.

.PARAMETER Address
    The address to be put in the "ADR" VCard field.

.PARAMETER Telephone
    The phone number to be put in the "TEL" VCard field.

.PARAMETER Email
    The email address to be put in the "EMAIL" VCard field.
#>
function New-VCard {
    [OutputType([string])]
	param(
		$Name,
		[Parameter(Mandatory=$true)]
		$FormattedName,
		$Nickname,
		$Birthday,
		$Address,
		$Telephone,
		$Email,
		$Title,
		$Organization,
		$Note,
		$Url,
		$Uid,
		$Twitter,
		$Skype,
		$Properties
	)
	process {
		$VCardBuilder = new-object Text.StringBuilder("BEGIN:VCARD`r`nVERSION:4.0`r`n")
		
		$ParameterMapping = @{
			"Name"="N";
			"FormattedName"="FN";
			"Birthday"="BDAY";
			"Address"="ADR";
			"Telephone"="TEL";
			"Organization"="ORG";
			"Twitter"="X-TWITTER";
			"Skype"="X-SKYPE";
		}
		
		$PSBoundParameters.Keys | ?{$_ -ne "Properties"} | %{
			if($ParameterMapping.ContainsKey($_)) {
				$Name = $ParameterMapping[$_]
			} else {
				$Name = $_.ToUpper()
			}
			$Value = $PSBoundParameters[$_]
			$VCardBuilder.AppendLine( ("{0}:{1}" -f $Name, $Value) ) | Out-Null
		}
		if($Properties) {
			$Properties.Keys | %{
				$VcardBuilder.AppendLine( ("{0}:{1}" -f $_, $Properties[$_]) ) | Out-Null
			}
		}
		$VCardBuilder.Append("END:VCARD") | Out-Null
		$VCardBuilder.ToString()
	}
}
Export-ModuleMember -Function New-VCard