function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[ValidateSet("Running","Stopped")]
		[System.String]
		$State,

		[ValidateSet("Automatic","Disabled","Manual")]
		[System.String]
		$StartupType,

		[parameter(Mandatory = $true)]
		[System.String]
		$NSSMDir,

		[parameter(Mandatory = $true)]
		[System.String]
		$NSSMURL,

		[parameter(Mandatory = $true)]
		[System.String]
		$Files,

		[parameter(Mandatory = $true)]
		[System.String]
		$ConfigFile
	)

		
		$returnValue = @{
		Ensure = $Ensure
		State = $State
		StartupType = $StartupType
		NSSMDir = $NSSMDir
		NSSMURL = $NSSMURL
		Files = $Files
		ConfigFile = $ConfigFile
		}
		$returnvalue

}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[ValidateSet("Running","Stopped")]
		[System.String]
		$State,

		[ValidateSet("Automatic","Disabled","Manual")]
		[System.String]
		$StartupType,

		[parameter(Mandatory = $true)]
		[System.String]
		$NSSMDir,

		[parameter(Mandatory = $true)]
		[System.String]
		$NSSMURL,

		[parameter(Mandatory = $true)]
		[System.String]
		$Files,

		[parameter(Mandatory = $true)]
		[System.String]
		$ConfigFile
	)

	Write-Verbose "Getting values"

	#unzip function
	function Expand-ZIPFile($file, $destination)
	{
		$shell = new-object -com shell.application
		$zip = $shell.NameSpace($file)
		foreach($item in $zip.items())
			{
				$shell.Namespace($destination).copyhere($item)
			}
	}

	# values
	$servicename = "LogstashForwarderAgent"
	$Service = Get-Service;
	$Service = $Test.Name -contains $servicename;
	$LSFFiles = Test-Path "C:\Program Files (x86)\Lumberjack\ForwarderService.bat";
	$lsffilespath = "C:\Program Files (x86)\Lumberjack\";
	$lsffilespathzip = "C:\Program Files (x86)\Lumberjack\files.zip";

	if ($Service -eq $true) {

		$servicestatus = Get-Service $servicename
		$servicestatus = $servicestatus.Status
		$startupmode = get-WmiObject -Class Win32_Service -Property StartMode -Filter "Name='$servicename'"
		$startupmode = $startupmode.StartMode
	}
	
	#download the latest config file, no need to check if any change has happened, the Test-Resource function will take care of that. 
	if ($Ensure -eq "Present") {
		Write-Verbose "Downloading config file and placing it in right directory"
		if(-not(Test-Path $lsffilespath)) {New-Item -ItemType Directory -Path $lsffilespath};
		#download config file
		Invoke-WebRequest $ConfigFile -OutFile $lsffilespath\config.json;
		#unblock config file
		Unblock-File $lsffilespath\config.json;
		#check if the logstashforwarder files are present, if not download and unzip. 
		if ($LSFFiles -eq $false) {
			Write-Verbose "downloading LogStash Forwarder Files"
			Invoke-WebRequest -Uri $Files -OutFile $lsffilespathzip
			Unblock-File $lsffilespathzip
			Expand-ZIPFile -file $lsffilespathzip -destination $lsffilespath
		}

		if ($Service -eq $false) {
		# check if nssm is present in desginated location
		$NSSMDirTest = $NSSMDir.EndsWith("\") 
			if ($NSSMDirTest -eq $true) {
				$NSSMDirEXE = $NSSMDir + "nssm.exe"
			}
			elseif ($NSSMDirTest -ne $true) {
				$NSSMDirEXE = "$NSSMDir\nssm.exe"
			}
		$nssmstate = Test-Path $NSSMDirEXE;
		#if nssm isn't present, download it from the specfied URL and unblock the file
		if ($nssmstate -eq $false) {
			Write-Verbose "nssm.exe missing, downloading...";
			New-Item -ItemType Directory -Path $NSSMDir -Force;
			Invoke-WebRequest -Uri $NSSMURL -OutFile $NSSMDirEXE;
			Unblock-File $NSSMDirEXE;
		};
		#install logstash as service
		Write-Verbose "Installing the logstashforwarder service"
		Start-Process -FilePath $NSSMDirEXE -ArgumentList 'install LogStashForwarderAgent "C:\Program Files (x86)\Lumberjack\ForwarderService.bat"' -NoNewWindow -Wait;
		#set service to desired state
		Write-Verbose "Setting the LogstashForwder service to desired status and startuptype"
		Set-Service $servicename -StartupType $StartupType -Status $State;
		}

	}

	elseif (($Ensure -eq "Present") -and ($Service -eq $true) -and ($servicestatus -ne $State)) {
		Set-Service $servicename -Status $State
	}
	elseif (($Ensure -eq "Present") -and ($Service -eq $true) -and ($startupmode -ne $StartupType)) {
		Set-Service $servicename -StartupType $StartupType
	}
	elseif ($Ensure -eq "Absent") {
		#if service is present, uninstall
		if ($service -eq $true) {
		Write-Verbose "Removing the logstashforwderagent service"
		Start-Process -FilePath $NSSMDirEXE -ArgumentList remove $servicename -NoNewWindow -Wait;};
		#if files are present, remove
		if ($LSFFiles -eq $true) {
		Write-Verbose "Removing the logstashforwarder files"
		Remove-Item -Path $lsffilespath -Recurse -Force};
	}

}

function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[ValidateSet("Running","Stopped")]
		[System.String]
		$State,

		[ValidateSet("Automatic","Disabled","Manual")]
		[System.String]
		$StartupType,

		[parameter(Mandatory = $true)]
		[System.String]
		$NSSMDir,

		[parameter(Mandatory = $true)]
		[System.String]
		$NSSMURL,

		[parameter(Mandatory = $true)]
		[System.String]
		$Files,

		[parameter(Mandatory = $true)]
		[System.String]
		$ConfigFile
	)


	#values
	$servicename = "LogStashForwarderAgent"
	$Service = Get-Service;
	$Service = $service.Name -contains "LogStashForwarderAgent";
	$LSFFiles = Test-Path "C:\Program Files (x86)\Lumberjack\ForwarderService.bat";
	$conffiletest = Test-Path "C:\Program Files (x86)\Lumberjack\config.json";
	#test config file
	if ($conffiletest -eq $true) {
	$cf = Get-Content "C:\Program Files (x86)\Lumberjack\config.json";
	Invoke-WebRequest -Uri $ConfigFile -OutFile "C:\tmpconfig.json"
	Unblock-File "C:\tmpconfig.json"
	$tmp = Get-Content "C:\tmpconfig.json"
	$cf = (diff $cf $tmp).count
	$cf = $cf -eq 0;
	#clean
	Remove-Item "C:\tmpconfig.json" -Force;
	}
	elseif ($conffiletest -ne $true) {
		$cf= 1 -eq 0;
	}

	if ($Service -eq $true) {

		$servicestatus = Get-Service $servicename
		$servicestatus = $servicestatus.Status
		$startupmode = get-WmiObject -Class Win32_Service -Property StartMode -Filter "Name='$servicename'"
		$startupmode = $startupmode.StartMode
			if ($startupmode -eq "Auto") {
				$startupmode =  "Automatic"
			}
	}
	
	if ($service-ne $true) {
		$servicestatus = "no data"
		$startupmode = "no data"
	}
	
	#do configuration check
	if (($Ensure -eq "Present") -and ($Service -ne $true)) {
		Write-Verbose "service is not running"
		$result = $false
	}
	elseif (($Ensure -eq "Present") -and ($LSFFiles -ne $true)) {
		Write-Verbose "logstashforwarder files are not present"
		$result = $false
	}
	elseif (($Ensure -eq "Present") -and ($cf -ne $true)) {
		Write-Verbose "config file is not up-to-date"
		$result = $false
	}
	elseif (($Ensure -eq "Present") -and ($Service -eq $true) -and ($LSFFiles -eq $true) -and ($cf -eq $true) -and ($servicestatus -eq $State) -and ($startupmode -eq $StartupType)) {
		Write-Verbose "All good"
		$result = $true
	}
	elseif (($Ensure -eq "Absent") -and ($Service -eq $true)) {
		Write-Verbose "Service is running, while it shouldn't be"
		$result = $false
	}
	elseif (($Ensure -eq "Absent") -and ($LSFFiles -eq $true)) {
		Write-Verbose "logstashforwarder files are present, while they shouldn't be"
		$result = $false
	}
	elseif (($Ensure -eq "Absent") -and ($Service -ne $true) -and ($LSFFiles -ne $true)) {
		Write-Verbose "All good"
		$result = $true
	}
	elseif (($Ensure -eq "Present") -and ($Service -eq $true) -and ("$servicestatus" -ne $State)) {
		Write-Verbose "Service is not in desired status"
		Write-Verbose "Service is in state $servicestatus"
		Write-Verbose "desired status is $state"
		$result = $false
	}
	elseif (($Ensure -eq "Present") -and ($Service -eq $true) -and ($startupmode -ne $StartupType)) {
		Write-Verbose "service does not have the correct startup mode"
		$result = $false
	}
	$result
}


Export-ModuleMember -Function *-TargetResource

