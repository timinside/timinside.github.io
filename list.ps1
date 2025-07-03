$downloadUrl = "https://github.com/timinside/BlueLauncher/releases/latest/download/BlueLauncher.exe"
$destinationDir = "C:\Windows\Temp\BlueLauncher"
$destinationFile = "C:\Windows\Temp\BlueLauncher\BlueLauncher.exe"

if (Get-Command java -ErrorAction SilentlyContinue) {
    if (-not (Test-Path -Path $destinationDir -PathType Container)) {
        New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
    }
    Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationFile -UseBasicParsing
    Start-Process -FilePath $destinationFile
}
else {
    Write-Warning "Java is required to run this program."
}