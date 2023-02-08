$xmlName = "MySettings.xml"
Push-Location "${env:ProgramFiles}\Dell\CommandUpdate\" 
$rc = Start-Process "dcu-cli.exe" -wait -ArgumentList "/configure","-importSettings=$PSScriptRoot\$xmlName"  -PassThru -ErrorAction "Stop" 
return $rc.ExitCode
