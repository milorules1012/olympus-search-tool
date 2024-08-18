##	File: whitelist_check.ps1
##	Author: Milo
##	Description: Runs a quick background check on the player for whitelisting

function Get-AcceptableTypes {
    $acceptableTypes = @(
        @{Type = "Steam64ID   "; Example = "76561198071959741"; Color = "Green"},
        @{Type = "IPv4 Addr   "; Example = "91.149.202.94"; Color = "Cyan"},
        @{Type = "Email       "; Example = "admin@olympus-entertainment.com"; Color = "Yellow"}
    )


$text = @"
____ _    _   _ _  _ ___  _  _ ____    ____ ____ ____ ____ ____ _  _    ___ ____ ____ _    
|  | |     \_/  |\/| |__] |  | [__     [__  |___ |__| |__/ |    |__|     |  |  | |  | |    
|__| |___   |   |  | |    |__| ___]    ___] |___ |  | |  \ |___ |  |     |  |__| |__| |___ 

"@
	Write-Host $text -ForegroundColor Red
    foreach ($item in $acceptableTypes) {
        Write-Host ($item.Type + "- " + $item.Example) -ForegroundColor $item.Color
    }

    Write-Host "" -ForegroundColor White
}

function Get-UserInput {	
	param (
		[string]$text
	)
	
	function Select-UserInputData {
		
		param (
			[string]$insert
		)

		$type = "INVALID"

		$regexIPV4 = '^((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})$'
		if ($insert -match $regexIPV4) {
			$type = "IPV4"
			return @($type, $insert, $false)
		}

		$regexUID = '^[7-9]\d{16}$'
		if ($insert -match $regexUID) {
			$type = "UID"
			return @($type, $insert, $false)
		}

		$regexEmail = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
		if ($insert -match $regexEmail) {
			$type = "EMAIL"
			return @($type, $insert, $false)
		}

		Write-Host "Your input was not a type." -ForegroundColor Red
		Write-Host ""

		return @($type, $insert, $true)

	}

	$return = @("", "", $true)
	while ($return[2]) {
		
		$userInput = Read-Host $text
		$return = Select-UserInputData -insert $userInput
		
	}

	return ($return)
}

function Search-InputType {
	param (
		[string]$mode,
		[string]$value
	)

	function Get-ActionCfg {
		param (
			[string]$mode,
			[string]$value
		)

		$return = switch ($mode) {
			"IPV4" {
				@(
					("https://olympus-entertainment.com/admin/?app=core&module=members&controller=ip&ip=" + $value),
					("https://ip-api.com/#" + $value),
					("https://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a" + $value + "&run=toolpage"),
					("https://search.arin.net/rdap/?query=" + $value),
					("https://www.ip-tracker.org/lookup.php?ip=" + $value)
				)
			}
			"UID" {
				@(
					("https://www.battlemetrics.com/rcon/players?filter%5Bsearch%5D=" + $value + "&filter%5Bservers%5D=false&filter%5BplayerFlags%5D=&sort=score&showServers=true&method=full"),
					("https://steamcommunity.com/profiles/" + $value),
					("https://steamid.uk/profile/" + $value),
					("https://stats.olympus-entertainment.com/#/lc/players/" + $value),
					("https://my.gaming-asylum.com/profile/search?pid=" + $value)
				)		
			}
			"EMAIL" {
				$encoded = $value -replace "@", "%40"
				@(
					("https://epieos.com/?q=" + $encoded + "&t=email"),
					("https://intelx.io/?s=" + $encoded)
				)
			}
		}

		return $return
	}

	function New-BrowserSession {
		param (
			[string[]]$actionCfg
		)

		$i = 0
		while ($i -le ($actionCfg.Length)) {
			Start-Process $actionCfg[$i]
			Start-Sleep -Milliseconds 300
			$i = $i + 1
		}
	}

	$actionCfg = Get-ActionCfg -mode $mode -value $value
	New-BrowserSession -actionCfg $actionCfg
}


while ($true) {
	Clear-Host
	Get-AcceptableTypes
	$userData = Get-UserInput "Enter a type you would like to search"
	Search-InputType -mode $userData[0] -value $userData[1]
}
