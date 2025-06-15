param(
    [switch]$Force
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Progress {
    param(
        [int]$PercentComplete,
        [string]$Status,
        [string]$Activity = "Software by BlueZero"
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    Write-Host "[$PercentComplete%] $Status" -ForegroundColor Cyan
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        return $true
    }
    catch {
        Write-Host "Download error $Url : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Get-UserConfirmation {
    param([string]$Message)
    $choice = Read-Host "$Message (y/n)"
    return ($choice -eq 'y' -or $choice -eq 'Y' -or $choice -eq 'yes' -or $choice -eq 'Yes')
}

function Check-Java {
    try {
        $javaVersion = & java -version 2>&1
        if ($javaVersion -match "1\.8\.0" -or $javaVersion -match "version `"8") {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Install-Java {
    Write-Host "Downloading Java Runtime Environment 8..." -ForegroundColor White
    
    Show-Progress -PercentComplete 10 -Status "Downloading Java 8..."
    $javaUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245060_d3c52aa6bfa54d3ca74e617f18309292"
    $javaPath = "C:\Windows\Temp\jre-8-windows-x64.exe"
    
    if (Download-File -Url $javaUrl -OutputPath $javaPath) {
        Show-Progress -PercentComplete 50 -Status "Installing Java 8..."
        try {
            Start-Process -FilePath $javaPath -ArgumentList "/s" -Wait
            Remove-Item -Path $javaPath -Force -ErrorAction SilentlyContinue
            Show-Progress -PercentComplete 100 -Status "Java 8 installed!"
            Write-Host "Java successfully installed!" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "Java installation error. Try installing manually from java.com" -ForegroundColor Red
            Remove-Item -Path $javaPath -Force -ErrorAction SilentlyContinue
            return $false
        }
    } else {
        Write-Host "Failed to download Java. Install Java 8 manually from java.com" -ForegroundColor Red
        return $false
    }
}

function Restart-Explorer {
    Write-Host "Restarting Windows Explorer..." -ForegroundColor White
    try {
        # Завершаем процесс explorer.exe
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        # Запускаем explorer.exe заново
        Start-Process -FilePath "explorer.exe"
        Start-Sleep -Seconds 3
        Write-Host "Windows Explorer restarted successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error restarting Explorer: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Set-WallpaperSecure {
    param(
        [string]$WallpaperPath
    )
    try {
        # Используем более надежный способ установки обоев
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
        # SystemParametersInfo с SPI_SETDESKWALLPAPER (20)
        $result = [Wallpaper]::SystemParametersInfo(20, 0, $WallpaperPath, 3)
        return $result -ne 0
    }
    catch {
        Write-Host "Error setting wallpaper: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Check-ProgramInstalled {
    param([string]$ProgramName)
    
    switch ($ProgramName) {
        "XTweaker" {
            return (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{74392878-CE70-4BDB-853F-55C4131EC5E9}" -ErrorAction SilentlyContinue) -ne $null
        }
        "XTweaker-Rebooted" {
            return (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AA2A0BA5-F86C-4C16-966C-370003F5161C}" -ErrorAction SilentlyContinue) -ne $null
        }
        "LunaClean" {
            return (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E7A543DC-8007-4C01-9C90-D772311F868F}" -ErrorAction SilentlyContinue) -ne $null
        }
        "RedLauncher" {
            return (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{6D2543EA-ECED-4559-9B80-06704B072012}" -ErrorAction SilentlyContinue) -ne $null
        }
        "Not11" {
            return (Test-Path "C:\Windows\System32\Not11\backup") -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -like "*ExplorerPatcher*"})
        }
        default {
            return $false
        }
    }
}

function Uninstall-Program {
    param([string]$ProgramName)
    
    switch ($ProgramName) {
        "XTweaker" {
            $uninstallInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{74392878-CE70-4BDB-853F-55C4131EC5E9}" -ErrorAction SilentlyContinue
            if ($uninstallInfo -and $uninstallInfo.UninstallString) {
                $uninstallCmd = $uninstallInfo.UninstallString -replace '"', ''
                Start-Process -FilePath $uninstallCmd -ArgumentList "/VERYSILENT" -Wait
                Write-Host "XTweaker Legacy uninstalled!" -ForegroundColor Green
            }
        }
        "XTweaker-Rebooted" {
            $uninstallInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AA2A0BA5-F86C-4C16-966C-370003F5161C}" -ErrorAction SilentlyContinue
            if ($uninstallInfo -and $uninstallInfo.UninstallString) {
                $uninstallCmd = $uninstallInfo.UninstallString -replace '"', ''
                Start-Process -FilePath $uninstallCmd -ArgumentList "/VERYSILENT" -Wait
                Write-Host "XTweaker Rebooted uninstalled!" -ForegroundColor Green
            }
        }
        "LunaClean" {
            $uninstallInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E7A543DC-8007-4C01-9C90-D772311F868F}" -ErrorAction SilentlyContinue
            if ($uninstallInfo -and $uninstallInfo.UninstallString) {
                $uninstallCmd = $uninstallInfo.UninstallString -replace '"', ''
                Start-Process -FilePath $uninstallCmd -ArgumentList "/VERYSILENT" -Wait
                Write-Host "LunaClean uninstalled!" -ForegroundColor Green
            }
        }
        "RedLauncher" {
            $uninstallInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{6D2543EA-ECED-4559-9B80-06704B072012}" -ErrorAction SilentlyContinue
            if ($uninstallInfo -and $uninstallInfo.UninstallString) {
                $uninstallCmd = $uninstallInfo.UninstallString -replace '"', ''
                Start-Process -FilePath $uninstallCmd -ArgumentList "/VERYSILENT" -Wait
                Write-Host "RedLauncher uninstalled!" -ForegroundColor Green
            }
        }
        "Not11" {
            Write-Host "Uninstalling Not11..." -ForegroundColor White
            
            # Восстанавливаем обои из бэкапа
            $backupDir = "C:\Windows\System32\Not11\backup"
            $wallpaperDir = "C:\Windows\Web\Wallpaper\Windows"
            
            if (Test-Path "$backupDir\img0.jpg") {
                Copy-Item -Path "$backupDir\img0.jpg" -Destination "$wallpaperDir\img0.jpg" -Force
            }
            if (Test-Path "$backupDir\img19.jpg") {
                Copy-Item -Path "$backupDir\img19.jpg" -Destination "$wallpaperDir\img19.jpg" -Force
            }
            
            # Удаляем папку Not11
            Remove-Item -Path "C:\Windows\System32\Not11" -Recurse -Force -ErrorAction SilentlyContinue
            
            # Удаляем ExplorerPatcher
            $epUninstaller = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -like "*ExplorerPatcher*"}
            if ($epUninstaller -and $epUninstaller.UninstallString) {
                $uninstallCmd = $epUninstaller.UninstallString -replace '"', ''
                Start-Process -FilePath $uninstallCmd -ArgumentList "/VERYSILENT" -Wait
            }
            
            Write-Host "Not11 uninstalled! Please reboot to apply changes." -ForegroundColor Green
        }
    }
}

function Show-InstallOptions {
    param([string]$ProgramName)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor White
    Write-Host "    $ProgramName is already installed   " -ForegroundColor White
    Write-Host "========================================" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Reinstall" -ForegroundColor White
    Write-Host "2. Uninstall" -ForegroundColor White
    Write-Host "0. Back to menu" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Enter option number"
    
    switch ($choice) {
        "1" { return "reinstall" }
        "2" { return "uninstall" }
        "0" { return "back" }
        default { return "back" }
    }
}

# Menu selection function
function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor White
    Write-Host "         Software by BlueZero            " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor White
    Write-Host ""
    Write-Host "Select software to install:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. XTweaker Legacy" -ForegroundColor White -NoNewline
    Write-Host " (requires Java 8)" -ForegroundColor DarkGray
    Write-Host "2. XTweaker Rebooted " -ForegroundColor White -NoNewline
    Write-Host "(Beta v1.0, requires Java 8)" -ForegroundColor DarkGray
    Write-Host "3. LunaClean" -ForegroundColor White
    Write-Host "4. Not11" -ForegroundColor White
    Write-Host "5. RedLauncher " -ForegroundColor White -NoNewline
    Write-Host "(coming soon)" -ForegroundColor DarkGray
    Write-Host "6. LunaOS " -ForegroundColor White -NoNewline
    Write-Host "(coming soon)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "0. Exit" -ForegroundColor Gray
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor White
    
    # Check administrator rights
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "WARNING: Running without administrator privileges!" -ForegroundColor Red
        Write-Host "Some functions may not work correctly." -ForegroundColor White
        Write-Host ""
    }
}

# Function to show error for unreleased programs
function Show-NotReleased {
    param([string]$ProgramName)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor White
    Write-Host "           PROGRAM IN DEVELOPMENT       " -ForegroundColor White
    Write-Host "========================================" -ForegroundColor White
    Write-Host ""
    Write-Host "$ProgramName is not released yet!" -ForegroundColor Yellow
    Write-Host "This program is currently in development." -ForegroundColor White
    Write-Host "Follow updates on GitHub!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor White
    Read-Host "Press Enter to return to menu"
}

function Install-XTweakerLegacy {
    # Проверяем, установлена ли программа
    if (Check-ProgramInstalled "XTweaker") {
        $action = Show-InstallOptions "XTweaker Legacy"
        switch ($action) {
            "uninstall" { 
                Uninstall-Program "XTweaker"
                Read-Host "Press Enter to return to menu"
                return
            }
            "back" { return }
            "reinstall" { 
                Write-Host "Reinstalling XTweaker Legacy..." -ForegroundColor White
                Uninstall-Program "XTweaker"
                Start-Sleep -Seconds 2
            }
        }
    }
    
    Write-Host "=== Installing XTweaker Legacy ===" -ForegroundColor Green
    
    if (!(Check-Java)) {
        Write-Host "Java Runtime Environment 8 not found!" -ForegroundColor White
        $installJava = Get-UserConfirmation "Do you want to install Java 8 automatically?"
        
        if ($installJava) {
            if (!(Install-Java)) {
                Write-Host "Continuing installation without Java (may not work correctly)..." -ForegroundColor White
            }
        } else {
            Write-Host "WARNING: Java 8 is required for XTweaker Legacy to work!" -ForegroundColor Red
            Write-Host "The program may not start without Java." -ForegroundColor White
        }
    }
    
    Show-Progress -PercentComplete 10 -Status "Downloading XTweaker Legacy..."
    $setupPath = "C:\Windows\Temp\XTweakerLegacySetup.exe"
    $url = "https://github.com/timinside/xtweaker/releases/latest/download/XTweakerSetup.exe"
    
    if (Download-File -Url $url -OutputPath $setupPath) {
        Show-Progress -PercentComplete 50 -Status "Running installer..."
        Start-Process -FilePath $setupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 100 -Status "XTweaker Legacy installed!"
        Remove-Item -Path $setupPath -Force -ErrorAction SilentlyContinue
        Write-Host "XTweaker Legacy successfully installed!" -ForegroundColor Green
    } else {
        Write-Host "XTweaker Legacy installation error!" -ForegroundColor Red
    }
    Read-Host "Press Enter to return to menu"
}

function Install-LunaClean {
    # Проверяем, установлена ли программа
    if (Check-ProgramInstalled "LunaClean") {
        $action = Show-InstallOptions "LunaClean"
        switch ($action) {
            "uninstall" { 
                Uninstall-Program "LunaClean"
                Read-Host "Press Enter to return to menu"
                return
            }
            "back" { return }
            "reinstall" { 
                Write-Host "Reinstalling LunaClean..." -ForegroundColor White
                Uninstall-Program "LunaClean"
                Start-Sleep -Seconds 2
            }
        }
    }
    
    Write-Host "=== Installing LunaClean ===" -ForegroundColor Green
    
    Show-Progress -PercentComplete 10 -Status "Downloading LunaClean..."
    $setupPath = "C:\Windows\Temp\LunaCleanSetup.exe"
    $url = "https://github.com/timinside/lunaclean/releases/latest/download/Setup.exe"
    
    if (Download-File -Url $url -OutputPath $setupPath) {
        Show-Progress -PercentComplete 50 -Status "Running installer..."
        Start-Process -FilePath $setupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 100 -Status "LunaClean installed!"
        Remove-Item -Path $setupPath -Force -ErrorAction SilentlyContinue
        Write-Host "LunaClean successfully installed!" -ForegroundColor Green
    } else {
        Write-Host "LunaClean installation error!" -ForegroundColor Red
    }
    Read-Host "Press Enter to return to menu"
}

function Install-XTweakerRebooted {
    # Проверяем, установлена ли программа
    if (Check-ProgramInstalled "XTweaker-Rebooted") {
        $action = Show-InstallOptions "XTweaker Rebooted"
        switch ($action) {
            "uninstall" { 
                Uninstall-Program "XTweaker-Rebooted"
                Read-Host "Press Enter to return to menu"
                return
            }
            "back" { return }
            "reinstall" { 
                Write-Host "Reinstalling XTweaker Rebooted..." -ForegroundColor White
                Uninstall-Program "XTweaker-Rebooted"
                Start-Sleep -Seconds 2
            }
        }
    }
    
    Write-Host "=== Installing XTweaker Rebooted ===" -ForegroundColor Green
    
    if (!(Check-Java)) {
        Write-Host "Java Runtime Environment 8 not found!" -ForegroundColor White
        $installJava = Get-UserConfirmation "Do you want to install Java 8 automatically?"
        
        if ($installJava) {
            if (!(Install-Java)) {
                Write-Host "Continuing installation without Java (may not work correctly)..." -ForegroundColor White
            }
        } else {
            Write-Host "WARNING: Java 8 is required for XTweaker Rebooted to work!" -ForegroundColor Red
            Write-Host "The program may not start without Java." -ForegroundColor White
        }
    }
    
    Show-Progress -PercentComplete 10 -Status "Downloading XTweaker Rebooted..."
    $setupPath = "C:\Windows\Temp\XTweakerRebootedSetup.exe"
    $url = "https://github.com/timinside/XTweakerRebooted/releases/latest/download/XTweakerSetup.exe"
    
    if (Download-File -Url $url -OutputPath $setupPath) {
        Show-Progress -PercentComplete 50 -Status "Running installer..."
        Start-Process -FilePath $setupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 100 -Status "XTweaker Rebooted installed!"
        Remove-Item -Path $setupPath -Force -ErrorAction SilentlyContinue
        Write-Host "XTweaker Rebooted successfully installed!" -ForegroundColor Green
    } else {
        Write-Host "XTweaker Rebooted installation error!" -ForegroundColor Red
    }
    Read-Host "Press Enter to return to menu"
}

function Install-Not11 {
    # Проверяем, установлена ли программа
    if (Check-ProgramInstalled "Not11") {
        $action = Show-InstallOptions "Not11"
        switch ($action) {
            "uninstall" { 
                Uninstall-Program "Not11"
                Read-Host "Press Enter to return to menu"
                return
            }
            "back" { return }
            "reinstall" { 
                Write-Host "Reinstalling Not11..." -ForegroundColor Yellow
                Uninstall-Program "Not11"
                Start-Sleep -Seconds 3
            }
        }
    }
    
    Write-Host "=== Installing Not11 ===" -ForegroundColor Green
    
    if (!(Check-Java)) {
        Write-Host "Java Runtime Environment 8 not found!" -ForegroundColor Yellow
        $installJava = Get-UserConfirmation "Do you want to install Java 8 automatically?"
        
        if ($installJava) {
            if (!(Install-Java)) {
                Write-Host "Continuing installation without Java (may not work correctly)..." -ForegroundColor Yellow
            }
        } else {
            Write-Host "WARNING: Java 8 is required for Not11 to work!" -ForegroundColor Yellow
            Write-Host "The program may not start without Java." -ForegroundColor Yellow
        }
    }
    
    try {
        Show-Progress -PercentComplete 3 -Status "Creating directories..."
        $not11Dir = "C:\Windows\System32\Not11"
        $backupDir = "$not11Dir\backup"
        
        if (!(Test-Path $not11Dir)) {
            New-Item -ItemType Directory -Path $not11Dir -Force | Out-Null
        }
        if (!(Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }

        Show-Progress -PercentComplete 8 -Status "Downloading files..."
        
        $epSetupPath = "C:\Windows\Temp\ep_setup.exe"
        if (!(Download-File -Url "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe" -OutputPath $epSetupPath)) {
            throw "Failed to download Required Software"
        }
        Show-Progress -PercentComplete 15 -Status "Downloading files..."

        $tweaks1Path = "C:\Windows\Temp\Not11-Tweaks1.reg"
        if (!(Download-File -Url "https://raw.githubusercontent.com/timinside/Not11/refs/heads/data/Tweaks.reg" -OutputPath $tweaks1Path)) {
            throw "Failed to download Tweaks.reg"
        }
        Show-Progress -PercentComplete 19 -Status "Downloading files..."

        $tweaks2Path = "C:\Windows\Temp\Not11-Tweaks2.reg"
        if (!(Download-File -Url "https://raw.githubusercontent.com/timinside/Not11/refs/heads/data/FixTaskbar.reg" -OutputPath $tweaks2Path)) {
            throw "Failed to download FixTaskbar.reg"
        }
        Show-Progress -PercentComplete 22 -Status "Downloading files..."

        Show-Progress -PercentComplete 25 -Status "Installing required software..."
        Start-Process -FilePath $epSetupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 32 -Status "Waiting for confirmation..."

        Write-Host ""
        $useAlternative = Get-UserConfirmation "Use alternative taskbar modification method? (not recommended!)"
        
        if ($useAlternative) {
            Write-Host "Applying alternative tweaks..." -ForegroundColor White
            Start-Process -FilePath "reg" -ArgumentList "import `"$tweaks2Path`"" -Wait
        } else {
            Write-Host "Applying standard tweaks..." -ForegroundColor White
            Start-Process -FilePath "reg" -ArgumentList "import `"$tweaks1Path`"" -Wait
        }
        Show-Progress -PercentComplete 50 -Status "Registry changes applied..."

        # Перезапускаем проводник после применения reg файлов
        Restart-Explorer
        Show-Progress -PercentComplete 56 -Status "Explorer restarted..."

        $shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ExplorerPatcher"
        if (Test-Path $shortcutPath) {
            Remove-Item -Path $shortcutPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        Show-Progress -PercentComplete 60 -Status "Installing wallpapers..."
        $wallpaperDir = "C:\Windows\Web\Wallpaper\Windows"
        $img0Path = "$wallpaperDir\img0.jpg"
        $img19Path = "$wallpaperDir\img19.jpg"
        $win10Path = "$wallpaperDir\win10.jpg"
        
        # Создаем резервные копии оригинальных обоев
        if (Test-Path $img0Path) {
            Copy-Item -Path $img0Path -Destination "$backupDir\img0.jpg" -Force
        }
        if (Test-Path $img19Path) {
            Copy-Item -Path $img19Path -Destination "$backupDir\img19.jpg" -Force
        }
        Show-Progress -PercentComplete 70 -Status "Backups created..."

        # Скачиваем новые обои с именем win10.jpg
        $newWallpaperUrl = "https://raw.githubusercontent.com/timinside/Not11/refs/heads/data/img0.jpg"
        $tempWallpaper = "C:\Windows\Temp\win10_wallpaper.jpg"
        
        if (Download-File -Url $newWallpaperUrl -OutputPath $tempWallpaper) {
            # Предоставляем права на изменение файлов обоев
            try {
                takeown /f $img0Path /A 2>$null
                icacls $img0Path /grant "Administrators:(F)" 2>$null
                takeown /f $img19Path /A 2>$null  
                icacls $img19Path /grant "Administrators:(F)" 2>$null
            }
            catch {
                Write-Host "Warning: Could not set file permissions" -ForegroundColor Yellow
            }
            
            # Копируем новые обои
            Copy-Item -Path $tempWallpaper -Destination $img0Path -Force
            Copy-Item -Path $tempWallpaper -Destination $img19Path -Force
            Copy-Item -Path $tempWallpaper -Destination $win10Path -Force
            Remove-Item -Path $tempWallpaper -Force -ErrorAction SilentlyContinue
        }
        Show-Progress -PercentComplete 85 -Status "Wallpapers installed..."

        # Устанавливаем обои через безопасный метод
        if (Set-WallpaperSecure -WallpaperPath $win10Path) {
            Write-Host "Wallpaper set successfully!" -ForegroundColor Green
        } else {
            # Fallback метод через реестр
            try {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $win10Path -Force
                Start-Process -FilePath "RUNDLL32.EXE" -ArgumentList "user32.dll,UpdatePerUserSystemParameters" -Wait
            }
            catch {
                Write-Host "Warning: Could not set wallpaper automatically" -ForegroundColor Yellow
            }
        }
        Show-Progress -PercentComplete 90 -Status "Wallpaper settings applied..."

        Show-Progress -PercentComplete 99 -Status "Updating desktop..."

        Show-Progress -PercentComplete 100 -Status "Installation completed!"
        Write-Host ""
        Write-Host "=== Not11 successfully installed! ===" -ForegroundColor Green

        Remove-Item -Path $epSetupPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tweaks1Path -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tweaks2Path -Force -ErrorAction SilentlyContinue

        # Offer reboot
        Write-Host ""
        $needReboot = Get-UserConfirmation "A reboot is required to apply all changes. Reboot now?"
        
        if ($needReboot) {
            Write-Host "Rebooting system..." -ForegroundColor Yellow
            Start-Process -FilePath "shutdown" -ArgumentList "/r /t 5" -NoNewWindow
            Write-Host "System will reboot in 5 seconds..." -ForegroundColor Red
            exit
        } else {
            Write-Host "WARNING: Please reboot to apply changes!" -ForegroundColor Red -BackgroundColor Yellow
        }

    } catch {
        Write-Host ""
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Installation interrupted." -ForegroundColor Yellow
    }
    
    if (!$needReboot) {
        Read-Host "Press Enter to return to menu"
    }
}

do {
    Show-Menu
    $choice = Read-Host "Enter option number"
    
    switch ($choice) {
        "1" { Install-XTweakerLegacy }
        "2" { Install-XTweakerRebooted }
        "3" { Install-LunaClean }
        "4" { Install-Not11 }
        "5" { Show-NotReleased "RedLauncher" }
        "6" { Show-NotReleased "LunaOS" }
        "0" { 
            Write-Host "Thank you for using Software by BlueZero!" -ForegroundColor White
            exit 
        }
        default { 
            Write-Host "Invalid choice! Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true)
