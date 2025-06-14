# BlueZero Software Installer - PowerShell версия
# Требует запуска от администратора

param(
    [switch]$Force
)

# Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Скрипт должен быть запущен от имени администратора!" -ForegroundColor Red
    Write-Host "Перезапускаем с правами администратора..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs "-File `"$PSCommandPath`" $args"
    exit
}

# Функция для отображения прогресс-бара
function Show-Progress {
    param(
        [int]$PercentComplete,
        [string]$Status,
        [string]$Activity = "BlueZero Software Installer"
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    Write-Host "[$PercentComplete%] $Status" -ForegroundColor Cyan
}

# Функция для скачивания файлов
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
        Write-Host "Ошибка скачивания $Url : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Функция для подтверждения действий
function Get-UserConfirmation {
    param([string]$Message)
    $choice = Read-Host "$Message (y/n)"
    return ($choice -eq 'y' -or $choice -eq 'Y' -or $choice -eq 'да' -or $choice -eq 'Да')
}

# Функция проверки Java
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

# Функция установки Java
function Install-Java {
    Write-Host "Java Runtime Environment 1.8.0 не найдена!" -ForegroundColor Red
    $installJava = Get-UserConfirmation "Хотите скачать и установить Java 8?"
    
    if ($installJava) {
        Write-Host "Перенаправляем на страницу загрузки Java..." -ForegroundColor Yellow
        Start-Process "https://www.java.com/ru/download/"
        Write-Host "После установки Java перезапустите установщик." -ForegroundColor Yellow
        Read-Host "Нажмите Enter для выхода"
        exit
    } else {
        Write-Host "Установка прервана. Java 8 необходима для работы большинства программ BlueZero." -ForegroundColor Red
        return $false
    }
}

# Функция меню выбора
function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host "         Software by BlueZero            " -ForegroundColor Blue
    Write-Host "         Universal Installer             " -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Выберите программу для установки:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. XTweaker Legacy" -ForegroundColor White -NoNewline
    Write-Host " (требует Java 8)" -ForegroundColor DarkGray
    Write-Host "2. XTweaker Rebooted " -ForegroundColor Red -NoNewline
    Write-Host "(скоро, требует Java 8)" -ForegroundColor DarkGray
    Write-Host "3. LunaClean" -ForegroundColor White
    Write-Host "4. Not11" -ForegroundColor White -NoNewline
    Write-Host " (требует Java 8)" -ForegroundColor DarkGray
    Write-Host "5. RedLauncher " -ForegroundColor Red -NoNewline
    Write-Host "(скоро, требует Java 8)" -ForegroundColor DarkGray
    Write-Host "6. LunaOS " -ForegroundColor Red -NoNewline
    Write-Host "(скоро, требует Java 8)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "0. Выход" -ForegroundColor Gray
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Blue
}

# Функция показа ошибки для нерелизнутых программ
function Show-NotReleased {
    param([string]$ProgramName)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "           ОШИБКА УСТАНОВКИ            " -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "$ProgramName еще не вышел!" -ForegroundColor Red
    Write-Host "Данная программа находится в разработке." -ForegroundColor Yellow
    Write-Host "Следите за обновлениями на GitHub!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Read-Host "Нажмите Enter для возврата в меню"
}

# Функция установки XTweaker Legacy
function Install-XTweakerLegacy {
    Write-Host "=== Установка XTweaker Legacy ===" -ForegroundColor Green
    
    if (!(Check-Java)) {
        if (!(Install-Java)) { return }
    }
    
    Show-Progress -PercentComplete 10 -Status "Скачиваем XTweaker Legacy..."
    $setupPath = "C:\Windows\Temp\XTweakerLegacySetup.exe"
    $url = "https://github.com/timinside/xtweaker/releases/latest/download/XTweakerSetup.exe"
    
    if (Download-File -Url $url -OutputPath $setupPath) {
        Show-Progress -PercentComplete 50 -Status "Запускаем установщик..."
        Start-Process -FilePath $setupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 100 -Status "XTweaker Legacy установлен!"
        Remove-Item -Path $setupPath -Force -ErrorAction SilentlyContinue
        Write-Host "XTweaker Legacy успешно установлен!" -ForegroundColor Green
    } else {
        Write-Host "Ошибка установки XTweaker Legacy!" -ForegroundColor Red
    }
    Read-Host "Нажмите Enter для возврата в меню"
}

# Функция установки LunaClean
function Install-LunaClean {
    Write-Host "=== Установка LunaClean ===" -ForegroundColor Green
    
    Show-Progress -PercentComplete 10 -Status "Скачиваем LunaClean..."
    $setupPath = "C:\Windows\Temp\LunaCleanSetup.exe"
    $url = "https://github.com/timinside/lunaclean/releases/latest/download/Setup.exe"
    
    if (Download-File -Url $url -OutputPath $setupPath) {
        Show-Progress -PercentComplete 50 -Status "Запускаем установщик..."
        Start-Process -FilePath $setupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 100 -Status "LunaClean установлен!"
        Remove-Item -Path $setupPath -Force -ErrorAction SilentlyContinue
        Write-Host "LunaClean успешно установлен!" -ForegroundColor Green
    } else {
        Write-Host "Ошибка установки LunaClean!" -ForegroundColor Red
    }
    Read-Host "Нажмите Enter для возврата в меню"
}

# Функция установки Not11
function Install-Not11 {
    Write-Host "=== Установка Not11 ===" -ForegroundColor Green
    
    if (!(Check-Java)) {
        if (!(Install-Java)) { return }
    }
    
    try {
        # Создание директории
        Show-Progress -PercentComplete 3 -Status "Создание директорий..."
        $not11Dir = "C:\Windows\System32\Not11"
        $backupDir = "$not11Dir\backup"
        
        if (!(Test-Path $not11Dir)) {
            New-Item -ItemType Directory -Path $not11Dir -Force | Out-Null
        }
        if (!(Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }

        # Скачивание файлов
        Show-Progress -PercentComplete 8 -Status "Скачиваем файлы..."
        
        # ExplorerPatcher
        $epSetupPath = "C:\Windows\Temp\ep_setup.exe"
        if (!(Download-File -Url "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe" -OutputPath $epSetupPath)) {
            throw "Не удалось скачать ExplorerPatcher"
        }
        Show-Progress -PercentComplete 15 -Status "ExplorerPatcher скачан..."

        # Реестровые файлы
        $tweaks1Path = "C:\Windows\Temp\Not11-Tweaks1.reg"
        if (!(Download-File -Url "https://raw.githubusercontent.com/timinside/Not11/refs/heads/data/Tweaks.reg" -OutputPath $tweaks1Path)) {
            throw "Не удалось скачать Tweaks.reg"
        }
        Show-Progress -PercentComplete 19 -Status "Tweaks.reg скачан..."

        $tweaks2Path = "C:\Windows\Temp\Not11-Tweaks2.reg"
        if (!(Download-File -Url "https://raw.githubusercontent.com/timinside/Not11/refs/heads/data/FixTaskbar.reg" -OutputPath $tweaks2Path)) {
            throw "Не удалось скачать FixTaskbar.reg"
        }
        Show-Progress -PercentComplete 22 -Status "FixTaskbar.reg скачан..."

        # Установка ExplorerPatcher
        Show-Progress -PercentComplete 25 -Status "Устанавливаем ExplorerPatcher..."
        Start-Process -FilePath $epSetupPath -ArgumentList "/VERYSILENT" -Wait
        Show-Progress -PercentComplete 32 -Status "ExplorerPatcher установлен..."

        # Выбор метода изменения панели задач
        Write-Host ""
        $useAlternative = Get-UserConfirmation "Использовать альтернативный метод изменения панели задач? (не рекомендуем!)"
        
        if ($useAlternative) {
            Write-Host "Применяем альтернативные твики..." -ForegroundColor Yellow
            Start-Process -FilePath "reg" -ArgumentList "import `"$tweaks2Path`"" -Wait
        } else {
            Write-Host "Применяем стандартные твики..." -ForegroundColor Green
            Start-Process -FilePath "reg" -ArgumentList "import `"$tweaks1Path`"" -Wait
        }
        Show-Progress -PercentComplete 56 -Status "Твики реестра применены..."

        # Удаление ярлыка ExplorerPatcher
        $shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ExplorerPatcher"
        if (Test-Path $shortcutPath) {
            Remove-Item -Path $shortcutPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Установка обоев
        Show-Progress -PercentComplete 60 -Status "Устанавливаем обои..."
        
        # Создание резервных копий
        $wallpaperDir = "C:\Windows\Web\Wallpaper\Windows"
        $img0Path = "$wallpaperDir\img0.jpg"
        $img19Path = "$wallpaperDir\img19.jpg"
        
        if (Test-Path $img0Path) {
            Copy-Item -Path $img0Path -Destination "$backupDir\img0.jpg" -Force
        }
        if (Test-Path $img19Path) {
            Copy-Item -Path $img19Path -Destination "$backupDir\img19.jpg" -Force
        }
        Show-Progress -PercentComplete 70 -Status "Резервные копии созданы..."

        # Скачивание новых обоев
        $newWallpaperUrl = "https://raw.githubusercontent.com/timinside/Not11/refs/heads/data/img0.jpg"
        $tempWallpaper = "C:\Windows\Temp\new_wallpaper.jpg"
        
        if (Download-File -Url $newWallpaperUrl -OutputPath $tempWallpaper) {
            Copy-Item -Path $tempWallpaper -Destination $img0Path -Force
            Copy-Item -Path $tempWallpaper -Destination $img19Path -Force
            Remove-Item -Path $tempWallpaper -Force -ErrorAction SilentlyContinue
        }
        Show-Progress -PercentComplete 85 -Status "Обои установлены..."

        # Применение обоев
        $regCommand = "reg add `"HKEY_CURRENT_USER\Control Panel\Desktop`" /v Wallpaper /t REG_SZ /d `"$img0Path`" /f"
        Start-Process -FilePath "cmd" -ArgumentList "/c $regCommand" -Wait
        Show-Progress -PercentComplete 90 -Status "Настройки обоев применены..."

        # Обновление рабочего стола
        Start-Process -FilePath "RUNDLL32.EXE" -ArgumentList "user32.dll,UpdatePerUserSystemParameters" -Wait
        Show-Progress -PercentComplete 99 -Status "Обновление рабочего стола..."

        # Завершение
        Show-Progress -PercentComplete 100 -Status "Установка завершена!"
        Write-Host ""
        Write-Host "=== Not11 успешно установлен! ===" -ForegroundColor Green
        
        # Очистка временных файлов
        Remove-Item -Path $epSetupPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tweaks1Path -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tweaks2Path -Force -ErrorAction SilentlyContinue

        # Предложение перезагрузки
        Write-Host ""
        $needReboot = Get-UserConfirmation "Для применения всех изменений требуется перезагрузка. Перезагрузить сейчас?"
        
        if ($needReboot) {
            Write-Host "Перезагружаем систему..." -ForegroundColor Yellow
            Start-Process -FilePath "shutdown" -ArgumentList "/r /t 5" -NoNewWindow
            Write-Host "Система будет перезагружена через 5 секунд..." -ForegroundColor Red
            exit
        } else {
            Write-Host "ВНИМАНИЕ: Пожалуйста, выполните перезагрузку для применения изменений!" -ForegroundColor Red -BackgroundColor Yellow
        }

    } catch {
        Write-Host ""
        Write-Host "ОШИБКА: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Установка прервана." -ForegroundColor Yellow
    }
    
    if (!$needReboot) {
        Read-Host "Нажмите Enter для возврата в меню"
    }
}

# Основной цикл программы
do {
    Show-Menu
    $choice = Read-Host "Введите номер опции"
    
    switch ($choice) {
        "1" { Install-XTweakerLegacy }
        "2" { Show-NotReleased "XTweaker Rebooted" }
        "3" { Install-LunaClean }
        "4" { Install-Not11 }
        "5" { Show-NotReleased "RedLauncher" }
        "6" { Show-NotReleased "LunaOS" }
        "0" { 
            Write-Host "Спасибо за использование BlueZero Software Installer!" -ForegroundColor Blue
            exit 
        }
        default { 
            Write-Host "Неверный выбор! Попробуйте снова." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true)