$tempPath = "C:\Program Files\GoBobDev\XTweaker\Temp"
$filename = Join-Path -Path $tempPath -ChildPath "XTweakerSetup.exe"
$url = "https://github.com/GoBobDev/XTweaker/releases/latest/download/XTweakerSetup.exe"

# URLs for Java installers based on system architecture
$urlJava64 = "https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u441-b07/7ed26d28139143f38c58992680c214a5/jre-8u441-windows-i586-iftw.exe?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u441-b07/7ed26d28139143f38c58992680c214a5/jre-8u441-windows-i586-iftw.exe&BHost=javadl.sun.com&File=jre-8u441-windows-i586-iftw.exe&AuthParam=1743505136_98a4d3172be87a30df7f0d818809414f&ext=.exe"
$urlJava32 = "https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u441-b07/7ed26d28139143f38c58992680c214a5/jre-8u441-windows-i586-iftw.exe?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u441-b07/7ed26d28139143f38c58992680c214a5/jre-8u441-windows-i586-iftw.exe&BHost=javadl.sun.com&File=jre-8u441-windows-i586-iftw.exe&AuthParam=1743505136_98a4d3172be87a30df7f0d818809414f&ext=.exe"

# Determine system architecture
function Get-SystemArchitecture {
    if ([Environment]::Is64BitOperatingSystem) {
        return "64-bit"
    } else {
        return "32-bit"
    }
}

$architecture = Get-SystemArchitecture
if ($architecture -eq "64-bit") {
    $urlJava = $urlJava64
} else {
    $urlJava = $urlJava32
}

$filenameJava = Join-Path -Path $tempPath -ChildPath "JavaRuntimeSetup.exe"

function Write-Log {
    param (
        [string]$message
    )
    Write-Host "[INFO] $message"
}

function Add-DefenderExclusion {
    param (
        [string]$path
    )
    try {
        Start-Process -FilePath "powershell" -ArgumentList "-Command `"Add-MpPreference -ExclusionPath '$path'`"" -Verb RunAs -Wait
    } catch {
        Write-Log "File ExclusionPath Add (MS Defender) failed: $_"
        exit 1
    }
}

function Remove-DefenderExclusion {
    param (
        [string]$path
    )
    try {
        Start-Process -FilePath "powershell" -ArgumentList "-Command `"Remove-MpPreference -ExclusionPath '$path'`"" -Verb RunAs -Wait
    } catch {
        Write-Log "File ExclusionPath Removing (MS Defender) failed: $_"
    }
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return $principal.IsInRole($adminRole)
}

function Is-JavaInstalled {
    try {
        # Check if Java is in the PATH
        Get-Command java -ErrorAction Stop
        return $true
    } catch {
        # Check registry for Java installation
        $javaRegistryPath = "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment"
        if (Test-Path $javaRegistryPath) {
            return $true
        } else {
            return $false
        }
    }
}

if (-not (Test-Admin)) {
    Write-Log "You need to run PowerShell as Administrator!"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

try {
    # Create directory if it doesn't exist
    if (-not (Test-Path -Path $tempPath)) {
        New-Item -Path $tempPath -ItemType Directory
    }

    Add-DefenderExclusion -path $filename

    Write-Log "Downloading XTweaker..."
    Invoke-WebRequest -Uri $url -OutFile $filename -ErrorAction Stop

    Write-Log "System architecture detected: $architecture"
    Write-Log "Searching if Java installed..."
    if (-not (Is-JavaInstalled)) {
        Write-Log "Java not installed. Downloading Java Runtime for $architecture..."
        Invoke-WebRequest -Uri $urlJava -OutFile $filenameJava -ErrorAction Stop

        Write-Log "Installing Java..."
        # Use the silent flag for installation
        Start-Process -FilePath $filenameJava -ArgumentList '/s' -Verb RunAs -Wait

        # Clean up Java installer
        $removeCommandJava = "Remove-Item -Path '$filenameJava' -ErrorAction Stop"
        Start-Process -FilePath "powershell" -ArgumentList "-Command $removeCommandJava" -Verb RunAs -Wait
    } else {
        Write-Log "Java is already installed."
    }

    # Install XTweaker silently
    Write-Log "Installing XTweaker..."
    Start-Process -FilePath $filename -ArgumentList '/VERYSILENT /TASKS="desktopicon"' -Verb RunAs -Wait

    # Clean up XTweaker installer
    $removeCommandXTweaker = "Remove-Item -Path '$filename' -ErrorAction Stop"
    Start-Process -FilePath "powershell" -ArgumentList "-Command $removeCommandXTweaker" -Verb RunAs -Wait

    Remove-DefenderExclusion -path $filename

    Write-Log "Installation completed. Thank you for selecting us."

} catch {
    Write-Log "Error occurred: $_"
}
