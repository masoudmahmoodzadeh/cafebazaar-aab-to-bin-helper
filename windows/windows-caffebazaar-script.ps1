Add-Type -AssemblyName System.Windows.Forms
Import-Module CredentialManager -ErrorAction SilentlyContinue

# ==============================
# Colored Message Helpers
# ==============================

function Title($msg)    { Write-Host $msg -ForegroundColor Cyan }
function Info($msg)     { Write-Host $msg -ForegroundColor White }
function Success($msg)  { Write-Host $msg -ForegroundColor Green }
function Warn($msg)     { Write-Host $msg -ForegroundColor Yellow }
function ErrorMsg($msg) { Write-Host $msg -ForegroundColor Red }
function Step($msg)     { Write-Host $msg -ForegroundColor Magenta }

# ==============================
# File & Folder Pickers
# ==============================

function PickFile($title, $filter) {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = $title
    $dialog.Filter = $filter
    $dialog.ShowDialog() | Out-Null
    return $dialog.FileName
}

function PickFolder($title) {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $title
    $dialog.ShowDialog() | Out-Null
    return $dialog.SelectedPath
}

# ==============================
# Secure Password Handling
# ==============================

function ReadPassword($message) {
    $secure = Read-Host $message -AsSecureString
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    )
}

function SecureToPlain($secure) {
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    )
}

function GetCredentialTarget($keystorePath) {
    $hash = (Get-FileHash $keystorePath -Algorithm SHA256).Hash.Substring(0,16)
    return "AAB_BIN_SIGNER_$hash"
}

function GetSavedCredential($target) {
    try {
        return Get-StoredCredential -Target $target
    } catch {
        return $null
    }
}

function SaveCredential($target,$alias,$ksPass,$keyPass) {

    $combined = "$alias|$ksPass|$keyPass"

    New-StoredCredential `
        -Target $target `
        -UserName "AABSigner" `
        -Password $combined `
        -Persist LocalMachine | Out-Null
}

# ==============================
# Script Start
# ==============================

Write-Host ""
Title "CafeBazaar aab to bin Signer"
Write-Host ""

# Select AAB
Info "Select AAB file..."
$aab = PickFile "Select AAB file" "AAB files (*.aab)|*.aab"
if (-not $aab) { Warn "Operation cancelled."; exit }

# Select keystore
Info "Select Keystore (.jks)..."
$keystore = PickFile "Select Keystore (.jks)" "Keystore (*.jks)|*.jks"
if (-not $keystore) { Warn "Operation cancelled."; exit }

# Select bundlesigner
Info "Select bundlesigner.jar..."
$bundlesigner = PickFile "Select bundlesigner.jar" "Jar files (*.jar)|*.jar"
if (-not $bundlesigner) { Warn "Operation cancelled."; exit }

# Select output folder
Info "Select output folder..."
$outFolder = PickFolder "Select output folder"
if (-not $outFolder) { Warn "Operation cancelled."; exit }

$aabBaseName = [System.IO.Path]::GetFileNameWithoutExtension($aab)
$finalBinPath = Join-Path $outFolder ($aabBaseName + ".bin")

# ==============================
# Credential Handling
# ==============================

$credTarget = GetCredentialTarget $keystore
$saved = GetSavedCredential $credTarget

if ($saved) {

    Success "Using saved credentials..."

    $plain = SecureToPlain $saved.Password
    $parts = $plain.Split("|")

    $alias = $parts[0]
    $ksPass = $parts[1]
    $keyPass = $parts[2]

}
else {

    Warn "Enter keystore credentials"

    $alias = Read-Host "Key alias"
    $ksPass = ReadPassword "Keystore password"
    $keyPass = ReadPassword "Key password"

    SaveCredential $credTarget $alias $ksPass $keyPass
    Success "Credentials saved securely."
}

# ==============================
# Signing Process
# ==============================

Write-Host ""
Step "Signing bundle..."
Write-Host ""

try {

    java -jar "$bundlesigner" genbin `
      -v `
      --bundle "$aab" `
      --bin "$outFolder" `
      --ks "$keystore" `
      --ks-key-alias "$alias" `
      --ks-pass "pass:$ksPass" `
      --key-pass "pass:$keyPass" `
      --pass-encoding utf-8 `
      --v2-signing-enabled true `
      --v3-signing-enabled false

}
catch {
    ErrorMsg "Signing failed!"
    pause
    exit
}

# ==============================
# Check Output
# ==============================

Write-Host ""
Step "Checking output..."
Write-Host ""

$generatedBin = Get-ChildItem $outFolder -Filter *.bin |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($generatedBin) {

    if ($generatedBin.FullName -ne $finalBinPath) {

        if (Test-Path $finalBinPath) {
            Remove-Item $finalBinPath -Force
        }

        Rename-Item $generatedBin.FullName ($aabBaseName + ".bin")
    }

    Success "BIN file created successfully!"
    Info $finalBinPath

    explorer.exe /select,"$finalBinPath"

}
else {

    ErrorMsg "BIN file not found."
    Warn "Check output folder:"
    Info $outFolder
}

Write-Host ""
pause
